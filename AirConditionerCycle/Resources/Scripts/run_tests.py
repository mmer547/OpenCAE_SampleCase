"""Build the three cooling examples with omc and check the simulated trajectories."""
import argparse
import csv
import math
import os
from pathlib import Path
import subprocess
import tempfile

EXAMPLES = ("RatedCooling", "OutdoorTemperatureRamp", "CompressorReplacement")
PACKAGE = Path(__file__).resolve().parents[2] / "package.mo"


def run_omc(compiler, work):
    commands = []
    for env, setter in (("CC", "setCompiler"), ("CXX", "setCXXCompiler")):
        if os.environ.get(env):
            commands.append(f'{setter}(getEnvironmentVar("{env}"));')
    package = PACKAGE.as_posix().replace('"', '\\"')
    for call in ('loadModel(Modelica, {"4.1.0"})',
                 'loadModel(ExternalMedia, {"4.1.1"})', f'loadFile("{package}")'):
        commands.append(f'if not {call} then print(getErrorString()); exit(1); end if;')
    for name in EXAMPLES:
        commands.append(f'simulate(AirConditionerCycle.Examples.{name}, stopTime=600, '
                        f'numberOfIntervals=300, tolerance=1e-7, method="dassl", '
                        f'outputFormat="csv", fileNamePrefix="{name}");')
        commands.append('getErrorString();')
    (work / "tests.mos").write_text("\n".join(commands) + "\n", encoding="utf-8")
    job = subprocess.run([compiler, "tests.mos"], cwd=work, stdout=subprocess.PIPE,
                         stderr=subprocess.STDOUT, encoding="utf-8", errors="replace")
    if job.returncode or job.stdout.count("The simulation finished successfully.") != len(EXAMPLES):
        raise SystemExit(job.stdout)
    print(subprocess.check_output([compiler, "--version"], text=True).strip())


def require(ok, message):
    if not ok:
        raise ValueError(message)


def check_trajectory(name, path):
    with path.open(newline="", encoding="utf-8-sig") as f:
        records = list(csv.DictReader(f))
    require(len(records) >= 301, f"{name}: incomplete trajectory")
    history = []
    initial_mass = initial_energy = previous_power = integrated_energy = 0.0
    mass_error = energy_error = 0.0
    for record in records:
        t = float(record["time"])
        r = {k[6:]: float(v) for k, v in record.items() if k.startswith("cycle.")}
        context = f"{name} at {t:g} s"
        require(all(math.isfinite(v) for v in r.values()), f"{context}: non-finite value")
        require(r["pHigh"] > r["pLow"] > 0 and 0 < r["x4"] < 1, f"{context}: phase or pressure")
        require(r["Q_cooling"] > 0 and r["P_el"] > 0 and r["Q_rejected"] > 0, f"{context}: heat or power sign")
        require(abs(r["h3"] - r["h4"]) < 0.01 and r["h2"] > r["h1"] > r["h4"], f"{context}: enthalpy")
        require(abs(r["T1"] - r["evaporator.T_sat"] - 5) < 0.01, f"{context}: suction superheat")
        require(abs(r["condenser.T_sat"] - r["T3"] - 5) < 0.01, f"{context}: liquid subcooling")
        require(abs(r["T4"] - r["evaporator.T_sat"]) < 0.01, f"{context}: valve outlet saturation")
        require(abs(r["COP"] - r["Q_cooling"]/r["P_el"]) < 1e-6, f"{context}: COP")

        mass = r["evaporator.charge"] + r["condenser.charge"]
        energy = r["evaporator.U"] + r["condenser.U"]
        power = r["Q_cooling"] - r["Q_rejected"] + r["compressor.P_shaft"]
        if history:
            dt = t - history[-1]["time_s"]
            require(0 <= dt <= 2.001, f"{context}: missing sample")
            integrated_energy += dt*(previous_power + power)/2
        else:
            initial_mass, initial_energy = mass, energy
        previous_power = power
        mass_error = max(mass_error, abs(mass - initial_mass))
        energy_error = max(energy_error, abs(energy - initial_energy - integrated_energy))

        # omc may omit parameter aliases in CSV for the fixed-flow compressor.
        flow = r["compressor.P_shaft"]/(r["h2"] - r["h1"])
        if name == "CompressorReplacement":
            require(abs(flow - 0.016) < 1e-8, f"{context}: replacement flow law")
        point = dict(example=name, time_s=t, outdoor_C=r.get("outdoorAir.T", 308.15)-273.15,
                     pLow_MPa=r["pLow"]/1e6, pHigh_MPa=r["pHigh"]/1e6,
                     cooling_kW=r["Q_cooling"]/1000, rejected_kW=r["Q_rejected"]/1000,
                     electric_kW=r["P_el"]/1000, COP=r["COP"], compressor_kg_s=flow,
                     valve_kg_s=r["valve.m_flow"], opening=r["valve.opening"], x4=r["x4"],
                     charge_kg=mass)
        for i in range(1, 5):
            point[f"T{i}_C"] = r[f"T{i}"] - 273.15
            point[f"h{i}_kJ_kg"] = r[f"h{i}"]/1000
        history.append(point)

    require(history[0]["time_s"] == 0 and history[-1]["time_s"] == 600, f"{name}: time range")
    require(mass_error < 1e-6, f"{name}: charge drift {mass_error:g} kg")
    # This includes the quadrature error of the 2 s trapezoidal integration.
    require(energy_error < 12, f"{name}: energy residual {energy_error:g} J")
    end = history[-1]
    print(f"{name:24}  {end['cooling_kW']:.4f} kW   COP {end['COP']:.4f}   "
          f"max |dm| {mass_error:.2e} kg   max |dE| {energy_error:.2f} J")
    return history


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--omc", default="omc", help="OpenModelica compiler executable")
    parser.add_argument("--csv", type=Path, help="save selected time series for all three cases")
    args = parser.parse_args()
    with tempfile.TemporaryDirectory() as tmp:
        work = Path(tmp)
        run_omc(args.omc, work)
        runs = [check_trajectory(name, work / f"{name}_res.csv") for name in EXAMPLES]
    rated, hot, swapped = [run[-1] for run in runs]
    require(2.85 < rated["cooling_kW"] < 3.15 and 3.9 < rated["COP"] < 4.2, "Rated operating point")
    require(abs(hot["outdoor_C"]-40) < 1e-6 and hot["pHigh_MPa"] > rated["pHigh_MPa"]*1.1
            and hot["COP"] < rated["COP"], "Outdoor ramp response")
    require(abs(swapped["valve_kg_s"]-0.016) < 1e-6 and swapped["cooling_kW"] < rated["cooling_kW"],
            "Replacement operating point")
    if args.csv:
        with args.csv.open("w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=rated.keys())
            writer.writeheader()
            for run in runs:
                writer.writerows(run)
    print("All three examples passed.")


if __name__ == "__main__":
    main()
