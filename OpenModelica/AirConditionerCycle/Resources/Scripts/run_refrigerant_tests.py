"""Simulate the four refrigerants with each compressor and verify their output."""
import argparse
import csv
import math
from pathlib import Path
import tempfile

from rotary_checks import ROTARY_FILTER, check_rotary, read_rows, require
from run_tests import run_omc

FLUIDS = ("R290", "R32", "R410A", "CO2")
ROTARY_STOP = {"R290": 0.21, "R32": 0.21, "R410A": 0.21, "CO2": 0.23}
STANDARD_FILTER = (
    "cycle[.](Q_cooling|Q_rejected|P_el|COP|pLow|pHigh|T1|T2|T3|T4|x4|h1|h2|h3|h4|"
    "compressor[.](m_flow|P_shaft)|evaporator[.](U|T_sat|charge|liquidFraction)|"
    "condenser[.](U|T_sat|charge|liquidFraction))"
)


def case_name(fluid, compressor):
    return fluid + ("Subcritical" if fluid == "CO2" else "") + compressor


def standard_result(path, fluid):
    rows = read_rows(path)
    require(len(rows) >= 1201 and rows[0]["time"] == 0 and rows[-1]["time"] == 600,
            "Incomplete 600 s trajectory")
    integral = max_mass_error = max_energy_error = 0.0
    for i, row in enumerate(rows):
        c = {k[6:]: v for k, v in row.items() if k.startswith("cycle.")}
        require(all(math.isfinite(v) for v in c.values()), "Non-finite cycle result")
        require(c["pHigh"] > c["pLow"] > 0 and 0 < c["x4"] < 1, "Cycle pressure or valve quality")
        require(c["Q_rejected"] > 0 and c["Q_cooling"] > 0 and c["P_el"] > 0, "Heat or power sign")
        require(abs(c["COP"] - c["Q_cooling"]/c["P_el"]) < 1e-6, "COP")
        require(abs(c["h3"]-c["h4"]) < 0.01 and c["h2"] > c["h1"] > c["h4"], "Enthalpy order")
        require(0 < c["evaporator.liquidFraction"] < 1 and 0 < c["condenser.liquidFraction"] < 1,
                "Two-phase inventory")
        if fluid == "CO2":
            require(c["condenser.T_sat"] < 304.1282, "CO2 must condense below its critical temperature")
        mass = c["condenser.charge"] + c["evaporator.charge"]
        energy = c["condenser.U"] + c["evaporator.U"]
        rate = c["Q_cooling"] - c["Q_rejected"] + c["compressor.P_shaft"]
        if i == 0:
            initial_mass, initial_energy = mass, energy
        else:
            dt = row["time"] - rows[i-1]["time"]
            require(0 <= dt <= 0.500001, "Standard case output interval")
            integral += dt*(rate + previous_rate)/2
        previous_rate = rate
        max_mass_error = max(max_mass_error, abs(mass-initial_mass))
        max_energy_error = max(max_energy_error, abs(energy-initial_energy-integral))
    require(max_mass_error < 1e-6 and max_energy_error < 12,
            f"Standard cycle balance: {max_mass_error:g} kg, {max_energy_error:g} J")
    print(f"{fluid:5} standard   COP {c['COP']:.4f}, max balance residuals "
          f"{max_mass_error:.2e} kg / {max_energy_error:.2f} J")
    return dict(cooling_kW=c["Q_cooling"]/1000, electric_kW=c["P_el"]/1000, COP=c["COP"],
                mass_flow_kg_s=c["compressor.m_flow"], low_MPa=c["pLow"]/1e6, high_MPa=c["pHigh"]/1e6)


def verify(case_files, summary_csv=None):
    report = []
    for fluid in FLUIDS:
        for compressor in ("Standard", "Rotary"):
            name = case_name(fluid, compressor)
            path = case_files[name]
            point = dict(example=name, refrigerant=fluid, compressor=compressor,
                         indoor_C=25, outdoor_C=-10 if fluid == "CO2" else 35, command_rpm=3000)
            if compressor == "Standard":
                point.update(stop_s=600, sample="final", **standard_result(path, fluid))
            else:
                print(f"{fluid:5} rotary", end="  ")
                # The CO2 condenser in this cycle must operate below the critical pressure.
                pressure_limit = 7.3773e6 if fluid == "CO2" else math.inf
                result = check_rotary(path, None, ROTARY_STOP[fluid], pressure_limit)
                point.update(stop_s=ROTARY_STOP[fluid], sample="last_complete_revolution", **result)
            report.append(point)
    if summary_csv:
        fields = list(dict.fromkeys(k for row in report for k in row))
        with summary_csv.open("w", encoding="utf-8", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=fields)
            writer.writeheader()
            writer.writerows(report)
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--omc", default="omc")
    parser.add_argument("--csv", type=Path, help="write a one-row-per-case summary")
    args = parser.parse_args()
    cases = []
    for fluid in FLUIDS:
        stop = ROTARY_STOP[fluid]
        cases.extend([(fluid + "." + case_name(fluid, "Standard"), 600, 1200, STANDARD_FILTER),
                      (fluid + "." + case_name(fluid, "Rotary"), stop, round(stop/0.000025), ROTARY_FILTER)])
    with tempfile.TemporaryDirectory() as tmp:
        work = Path(tmp)
        run_omc(args.omc, work, cases, "AirConditionerCycle.Examples.RefrigerantTests")
        names = [path.rsplit(".", 1)[-1] for path, *_ in cases]
        verify({name: work/f"{name}_res.csv" for name in names}, args.csv)
    print("All eight refrigerant cases passed.")


if __name__ == "__main__":
    main()
