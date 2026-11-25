"""Simulate the standalone and closed-cycle twin rotary examples and check the trajectories."""
import argparse
import csv
import math
from pathlib import Path
import re
import tempfile

from rotary_checks import read_rows, require
from run_tests import run_omc

FLUIDS = ("R134a", "R290", "R32", "R410A", "CO2")
BANK_FIELDS = ("(upper|lower)[.](crank[.]phi|reed[.](m_flow|lift|outlet[.]h_outflow)|"
               "roller[.](a[.]V|b[.]V|revolutions))")
FIELDS = ("(cycle[.])?compressor[.](charge|E|driveLoss|P_el|m_flow|outlet[.](m_flow|h_outflow)|"
          "muffler[.](inlet[.]m_flow|h_in)|" + BANK_FIELDS + ")|"
          "cycle[.](evaporator[.](charge|U)|condenser[.](charge|U)|pLow|pHigh|Q_cooling|Q_rejected)")


def verify(path, fluid, cycle, suction_enthalpy=None):
    rows = read_rows(path)
    stop = 0.21 if cycle else 0.23
    require(rows[0]["time"] == 0 and rows[-1]["time"] == stop, "Incomplete trajectory")
    prefix = "cycle.compressor." if cycle else "compressor."
    initial_mass = initial_energy = previous_rates = None
    last_time = mass_integral = energy_integral = mass_error = energy_error = 0.0
    for row in rows:
        require(all(math.isfinite(v) for v in row.values()), "Nonfinite result")
        c = {k[len(prefix):]: v for k, v in row.items() if k.startswith(prefix)}
        t = row["time"]
        require(abs(c["lower.crank.phi"]-c["upper.crank.phi"]-math.pi) < 1e-8, "Crank phase")
        flows = [c[f"{bank}.reed.m_flow"] for bank in ("upper", "lower")]
        require(min(flows) >= -1e-9 and abs(sum(flows)-c["muffler.inlet.m_flow"]) < 1e-9,
                "Reed flows at the discharge junction")
        inlet_power = sum(flow*c[f"{bank}.reed.outlet.h_outflow"] for bank, flow in zip(("upper", "lower"), flows))
        require(abs(inlet_power-sum(flows)*c["muffler.h_in"]) < 0.02, "Enthalpy mixing at the muffler")
        for bank in ("upper", "lower"):
            a, b = c[bank+".roller.a.V"], c[bank+".roller.b.V"]
            reference = rows[0][prefix+bank+".roller.a.V"] + rows[0][prefix+bank+".roller.b.V"]
            require(min(a,b) > 0 and abs(a+b-reference) < 1e-12, "Chamber volume")
        mass, energy = c["charge"], c["E"]
        net_power = c["P_el"] - c["driveLoss"]
        if cycle:
            mass += row["cycle.evaporator.charge"] + row["cycle.condenser.charge"]
            energy += row["cycle.evaporator.U"] + row["cycle.condenser.U"]
            mass_rate = 0
            energy_rate = net_power + row["cycle.Q_cooling"] - row["cycle.Q_rejected"]
            require(0 < row["cycle.pLow"] < row["cycle.pHigh"], "Pressure ordering")
            if fluid == "CO2":
                require(row["cycle.pHigh"] < 7.3773e6, "CO2 condenser above critical pressure")
        else:
            mass_rate = c["m_flow"] + c["outlet.m_flow"]
            energy_rate = net_power + c["m_flow"]*suction_enthalpy + c["outlet.m_flow"]*c["outlet.h_outflow"]
        if previous_rates is None:
            initial_mass, initial_energy = mass, energy
        else:
            dt = t-last_time
            require(0 <= dt <= 2.51e-5, "Incomplete output grid")
            mass_integral += dt*(previous_rates[0]+mass_rate)/2
            energy_integral += dt*(previous_rates[1]+energy_rate)/2
        mass_error = max(mass_error, abs(mass-initial_mass-mass_integral))
        energy_error = max(energy_error, abs(energy-initial_energy-energy_integral))
        previous_rates = (mass_rate, energy_rate)
        last_time = t
    require(mass_error < 1e-6 and energy_error < 0.15,
            f"Mass / energy balance residuals {mass_error:g} kg, {energy_error:g} J")

    rev_key = prefix + "upper.roller.revolutions"
    rev = int(rows[-1][rev_key])
    require(rev >= 8, "Too few complete turns at the commanded speed")
    first = next(i for i, row in enumerate(rows) if row[rev_key] == rev - 1)
    last = next(i for i, row in enumerate(rows) if row[rev_key] == rev)
    turn = rows[first:last + 1]
    duration = turn[-1]["time"] - turn[0]["time"]

    def mean(field):
        key = prefix + field
        integral = sum((b["time"] - a["time"]) * (a[key] + b[key]) / 2
                       for a, b in zip(turn, turn[1:]))
        return integral / duration

    upper_flow = mean("upper.reed.m_flow")
    lower_flow = mean("lower.reed.m_flow")
    delivery = -mean("outlet.m_flow")
    require(min(upper_flow, lower_flow, delivery) > 0, "Inactive cylinder or no delivery")
    peaks = [max(turn, key=lambda row: row[prefix + bank + ".reed.m_flow"])
             for bank in ("upper", "lower")]
    phase_key = prefix + "upper.crank.phi"
    separation = math.degrees(peaks[1][phase_key] - peaks[0][phase_key]) % 360
    require(140 < separation < 220, "Discharge pulses are not staggered")
    return dict(refrigerant=fluid, example=path.name.removesuffix("_res.csv"), turns=rev,
                upper_g_s=1000*upper_flow, lower_g_s=1000*lower_flow, delivery_g_s=1000*delivery,
                electric_W=mean("P_el"), peak_separation_deg=separation,
                max_mass_error_kg=mass_error, max_energy_error_J=energy_error)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--omc", default="omc")
    parser.add_argument("--fluid", choices=(*FLUIDS, "all"), default="R134a")
    parser.add_argument("--csv", type=Path, help="save one row per example")
    args = parser.parse_args()
    results = []
    with tempfile.TemporaryDirectory() as temp:
        work = Path(temp)
        for fluid in (FLUIDS if args.fluid == "all" else (args.fluid,)):
            namespace = "AirConditionerCycle.Examples"
            prefix = "TwinRotary"
            if fluid != "R134a":
                namespace += ".RefrigerantTests"
                prefix = ("CO2Subcritical" if fluid == "CO2" else fluid) + "Twin"
            for mode, stop in (("Standalone", 0.23), ("Cooling", 0.21)):
                name = prefix + mode
                cycle = mode == "Cooling"
                log = run_omc(args.omc, work, [(name, stop, round(stop/0.000025), FIELDS)],
                              namespace, () if cycle else ("hSuction",))
                h_suction = None
                if not cycle:
                    match = re.search(r"^time=[^,]+,hSuction=([^\s,]+)", log, re.MULTILINE)
                    require(match is not None, "Missing suction enthalpy from the standalone boundary")
                    h_suction = float(match[1])
                result = verify(work/f"{name}_res.csv", fluid, cycle, h_suction)
                print(f"{name}: {result['delivery_g_s']:.2f} g/s, {result['electric_W']:.1f} W")
                results.append(result)
    if args.csv:
        with args.csv.open("w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=results[0])
            writer.writeheader()
            writer.writerows(results)


if __name__ == "__main__":
    main()
