"""Simulate and verify the open-loop rolling-piston compressor examples."""
import argparse
import csv
import math
from pathlib import Path
import re
import tempfile

from rotary_checks import read_rows, require
from run_tests import run_omc
from loss_checks import LOSS_FIELDS, check_losses

EXAMPLES = {
    "R134a": "RotaryCompressorStandalone",
    "R290": "RefrigerantTests.R290Standalone",
    "R32": "RefrigerantTests.R32Standalone",
    "R410A": "RefrigerantTests.R410AStandalone",
    "CO2": "RefrigerantTests.CO2SubcriticalStandalone",
}
FIELDS = ("dischargeFlow|dischargeTemperature|compressor[.](P_el|m_flow|E|charge|outlet[.]h_outflow|"
          "shell[.]Q_ambient|reed[.](lift|m_flow)|roller[.]revolutions)")
# The OpenModelica CSV trajectory omits constant boundary parameters.
PARAMETERS = ("suctionPressure", "dischargePressure", "hSuction", "suctionTemperature")


def check_compressor(path, solver_log, intervals=9200):
    reported = re.search(r"^time=[^\n]*,suctionPressure=[^\n]+", solver_log, re.MULTILINE)
    require(reported is not None, "Missing reported boundary parameters")
    boundary = {name: float(value) for name, value in
                (field.split("=") for field in reported.group().strip().split(","))}
    require(0 < boundary["suctionPressure"] < boundary["dischargePressure"], "Compressor boundary pressures")
    rows = read_rows(path)
    require(len(rows) >= intervals+1 and rows[0]["time"] == 0 and rows[-1]["time"] == 0.23,
            "Incomplete 0.23 s simulation")
    initial = rows[0]
    max_mass_error = max_energy_error = 0.0
    mass_integral = energy_integral = 0.0
    turn_start = 0.0
    turn_electric = turn_delivery = turn_temperature = 0.0
    min_lift, max_lift = math.inf, -math.inf
    completed = 0
    for i, row in enumerate(rows):
        require(all(math.isfinite(x) for x in row.values()), "Non-finite compressor output")
        time = row["time"]
        inlet, delivery = row["compressor.m_flow"], row["dischargeFlow"]
        electric, temperature = row["compressor.P_el"], row["dischargeTemperature"]
        lift, reed_flow = row["compressor.reed.lift"], row["compressor.reed.m_flow"]
        require(inlet >= -1e-10 and delivery >= -1e-10 and reed_flow >= -1e-10, f"Reverse flow at {time}")
        require(-1e-8 <= lift <= 0.001001 and electric > 0 and temperature > 0, "Lift, power or temperature")
        mass_rate = inlet - delivery
        energy_rate = (electric - row["compressor.shell.Q_ambient"] + inlet*boundary["hSuction"]
                       - delivery*row["compressor.outlet.h_outflow"])
        if i:
            dt = time - previous["time"]
            require(0 <= dt <= 0.23/intervals + 1e-9, "Output time grid")
            mass_integral += dt*(last_mass_rate + mass_rate)/2
            energy_integral += dt*(last_energy_rate + energy_rate)/2
            turn_electric += dt*(previous["compressor.P_el"] + electric)/2
            turn_delivery += dt*(previous["dischargeFlow"] + delivery)/2
            turn_temperature += dt*(previous["dischargeTemperature"] + temperature)/2
        max_mass_error = max(max_mass_error, abs(row["compressor.charge"]-initial["compressor.charge"]-mass_integral))
        max_energy_error = max(max_energy_error, abs(row["compressor.E"]-initial["compressor.E"]-energy_integral))
        revolution = int(row["compressor.roller.revolutions"])
        if revolution != completed:
            require(revolution == completed+1 and min_lift < 0.00005 and max_lift > 0.0004,
                    f"Missing full reed operation on revolution {revolution}")
            period = time - turn_start
            mean_power = turn_electric/period
            mean_flow = turn_delivery/period
            mean_temperature = turn_temperature/period
            require(mean_flow > 0 and mean_power > 0, "Complete-turn delivery or power")
            completed, turn_start = revolution, time
            turn_electric = turn_delivery = turn_temperature = 0.0
            min_lift, max_lift = math.inf, -math.inf
        min_lift, max_lift = min(min_lift, lift), max(max_lift, lift)
        previous, last_mass_rate, last_energy_rate = row, mass_rate, energy_rate
    require(completed >= 10 and max_mass_error < 2e-7 and max_energy_error < 0.12,
            f"Compressor balance or rotation count: {max_mass_error:g} kg, {max_energy_error:g} J, {completed} turns")
    return dict(suction_MPa_abs=boundary["suctionPressure"]/1e6, discharge_MPa_abs=boundary["dischargePressure"]/1e6,
                suction_C=boundary["suctionTemperature"]-273.15, stop_s=rows[-1]["time"], completed_revolutions=completed,
                last_turn_rpm=60/period, last_turn_electric_kW=mean_power/1000, last_turn_discharge_kg_s=mean_flow,
                last_turn_discharge_C=mean_temperature-273.15, max_mass_error_kg=max_mass_error,
                max_energy_error_J=max_energy_error)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--omc", default="omc")
    parser.add_argument("--fluid", choices=(*EXAMPLES, "all"), default="R134a")
    parser.add_argument("--losses", action="store_true", help="run detailed loss examples and verify the loss breakdown")
    parser.add_argument("--csv", type=Path, help="save per-fluid boundary conditions and last-turn averages")
    args = parser.parse_args()
    fluids = EXAMPLES if args.fluid == "all" else [args.fluid]
    results = []
    with tempfile.TemporaryDirectory() as work:
        for fluid in fluids:
            name = "AirConditionerCycle.Examples." + EXAMPLES[fluid]
            fields = FIELDS
            if args.losses:
                name = name.removesuffix("Standalone") + "LossTest"
                fields += "|" + LOSS_FIELDS
            namespace, short = name.rsplit(".", 1)
            # Resolve the CO2 loss case's narrow flow pulses on the same grid as its experiment annotation.
            intervals, tolerance = (18400, 3e-8) if args.losses and fluid == "CO2" else (9200, 1e-7)
            log = run_omc(args.omc, Path(work), [(short, 0.23, intervals, fields)], namespace, PARAMETERS, tolerance)
            trajectory = Path(work)/f"{short}_res.csv"
            result = check_compressor(trajectory, log, intervals)
            if args.losses:
                result.update(check_losses(trajectory))
                require(all(result[f"last_turn_{k}_W"] > 0 for k in
                            ("copper", "iron", "bearing", "vane", "oilFilm", "suctionDrop", "dischargeDrop", "leakageDrop")),
                        "Expected loss sources to be active in the nominal test")
            results.append(dict(refrigerant=fluid, **result))
            print(f"{fluid}: {result['completed_revolutions']} turns, "
                  f"{result['last_turn_electric_kW']:.3f} kW, {result['last_turn_discharge_kg_s']:.5f} kg/s")
    if args.csv:
        with args.csv.open("w", newline="", encoding="utf-8") as stream:
            writer = csv.DictWriter(stream, fieldnames=results[0])
            writer.writeheader()
            writer.writerows(results)


if __name__ == "__main__":
    main()
