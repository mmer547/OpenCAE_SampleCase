"""Simulate the five cooling cycles with the adiabatic rolling-piston compressor."""
import argparse
import csv
import math
from pathlib import Path
import tempfile

from rotary_checks import ROTARY_FILTER, check_rotary
from run_refrigerant_tests import ROTARY_STOP, case_name
from run_tests import run_omc


def example(fluid):
    if fluid == "R134a":
        return "AirConditionerCycle.Examples", "AdiabaticRotaryCooling", 0.21
    return ("AirConditionerCycle.Examples.RefrigerantTests",
            case_name(fluid, "AdiabaticCooling"), ROTARY_STOP[fluid])


def verify_cycle(path, fluid, stop):
    pressure_limit = 7.3773e6 if fluid == "CO2" else math.inf
    result = check_rotary(path, None, stop, pressure_limit, boundary_loss="driveLoss")
    return dict(refrigerant=fluid, stop_s=stop, **result)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--omc", default="omc")
    parser.add_argument("--fluid", choices=("all", "R134a", *ROTARY_STOP), default="R134a")
    parser.add_argument("--csv", type=Path, help="save last complete revolution per fluid")
    args = parser.parse_args()
    fluids = ("R134a", *ROTARY_STOP) if args.fluid == "all" else (args.fluid,)
    results = []
    with tempfile.TemporaryDirectory() as tmp:
        work = Path(tmp)
        for fluid in fluids:
            namespace, name, stop = example(fluid)
            fields = ROTARY_FILTER + "|cycle[.]compressor[.]driveLoss"
            run_omc(args.omc, work, [(name, stop, round(stop/0.000025), fields)], namespace)
            results.append(verify_cycle(work/f"{name}_res.csv", fluid, stop))
    if args.csv:
        with args.csv.open("w", newline="", encoding="utf-8") as stream:
            writer = csv.DictWriter(stream, fieldnames=results[0])
            writer.writeheader()
            writer.writerows(results)


if __name__ == "__main__":
    main()
