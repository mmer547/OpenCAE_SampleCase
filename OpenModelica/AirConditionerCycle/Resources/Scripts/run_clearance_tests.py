"""Compare signed cylinder leakage paths with independent standalone mass and energy balances."""
import argparse
import csv
import math
import re
import tempfile
from pathlib import Path

from rotary_checks import read_rows, require
from run_tests import run_omc

# Effective gas clearances in micrometres, ordered as radial, top face and bottom face.
GAPS = {"Base": (0, 0, 0), "Radial": (5, 0, 0), "Faces": (0, 8, 8),
        "Both": (5, 8, 8), "Top": (0, 8, 0), "Bottom": (0, 0, 8)}
PATHS = ("vaneTipLeakAB", "radialLeakAB", "topFaceLeakAB", "bottomFaceLeakAB")
FIELDS = ("dischargeFlow|compressor[.](charge|E|m_flow|P_el|driveLoss|outlet[.]h_outflow|"
          "losses[.]meanLeakRate|((upper|lower)[.])?(roller[.]revolutions|"
          "cylinder[.](leakAB|vaneTipLeakAB|radialLeakAB|topFaceLeakAB|bottomFaceLeakAB|pocket[AB][.]p)))")


def verify(trajectory, solver_log, model, case, medium, stop):
    rows = read_rows(trajectory)
    match = re.search(r"^time=[^,]+,hSuction=([^,\s]+)", solver_log, re.MULTILINE)
    require(match is not None, "Missing suction boundary enthalpy")
    h_in = float(match[1])
    banks = ["compressor."] if model == "Single" else ["compressor.upper.", "compressor.lower."]
    rev_key = banks[0] + "roller.revolutions"
    require(rows[0]["time"] == 0 and rows[-1]["time"] == stop, "Incomplete time span")
    mass_integral = energy_integral = mass_error = energy_error = 0.0
    last = None
    enabled = (True, *(v > 0 for v in GAPS[case]))
    for row in rows:
        require(all(math.isfinite(v) for v in row.values()), "Nonfinite result")
        for bank in banks:
            prefix = bank + "cylinder."
            dp = row[prefix+"pocketA.p"] - row[prefix+"pocketB.p"]
            flows = [row[prefix+k] for k in PATHS]
            require(abs(sum(flows)-row[prefix+"leakAB"]) < 1e-10, "Incorrect total leakage")
            for flow, active in zip(flows, enabled):
                require(flow*dp >= -1e-10 and (active or abs(flow) < 1e-14), "Direction or closed slit")
        delivery = row["dischargeFlow"]
        dm = row["compressor.m_flow"] - delivery
        power = (row["compressor.P_el"] - row["compressor.driveLoss"] +
                 row["compressor.m_flow"]*h_in - delivery*row["compressor.outlet.h_outflow"])
        if last is not None:
            dt = row["time"]-last[0]
            require(0 <= dt <= 2.51e-5, "Missing output samples")
            mass_integral += dt*(dm+last[1])/2
            energy_integral += dt*(power+last[2])/2
        last = row["time"], dm, power
        mass_error = max(mass_error, abs(row["compressor.charge"]-rows[0]["compressor.charge"]-mass_integral))
        energy_error = max(energy_error, abs(row["compressor.E"]-rows[0]["compressor.E"]-energy_integral))
    require(mass_error < 1e-6 and energy_error < 0.15, f"Boundary residual {mass_error} kg, {energy_error} J")

    rev = int(rows[-1][rev_key])
    require(rev >= (10 if stop == 0.23 else 2), "Too few complete revolutions")
    first = next(i for i,r in enumerate(rows) if r[rev_key] == rev-1)
    last_index = next(i for i,r in enumerate(rows) if r[rev_key] == rev)
    turn = rows[first:last_index+1]

    def mean(quantity):
        return sum((b["time"]-a["time"])*(quantity(a)+quantity(b))/2 for a,b in zip(turn,turn[1:])) / (
            turn[-1]["time"]-turn[0]["time"])

    flows = [1000*mean(lambda r: sum(abs(r[b+"cylinder."+key]) for b in banks)) for key in PATHS]
    require(all((flow > 0) == active for flow,active in zip(flows,enabled)), "Inactive or unexpected leakage path")
    require(abs(sum(flows) - 1000*rows[-1]["compressor.losses.meanLeakRate"]) < 0.002,
            "Path averages disagree with loss report")
    return dict(model=model, case=case, refrigerant=medium, stop_s=stop, turns=rev,
                radial_um=GAPS[case][0], top_um=GAPS[case][1], bottom_um=GAPS[case][2],
                tip_g_s=flows[0], radial_g_s=flows[1], top_g_s=flows[2], bottom_g_s=flows[3],
                total_leak_g_s=sum(flows), delivery_g_s=1000*mean(lambda r: r["dischargeFlow"]),
                electric_W=mean(lambda r: r["compressor.P_el"]), mass_error_kg=mass_error, energy_error_J=energy_error)


def simulate(omc, work, model, case, medium, stop):
    name = model + case + medium
    base = "RotaryClearanceStudy" if model == "Single" else "TwinRotaryClearanceStudy"
    radial, top, bottom = GAPS[case]
    cold = (", suctionPressure=Medium.saturationPressure(263.15), dischargePressure=Medium.saturationPressure(281.15)"
            if medium == "CO2" else "")
    source = work / "Study.mo"
    source.write_text(f"""within ;
package Study
  model {name}
    extends AirConditionerCycle.Examples.{base}(
      redeclare package Medium=AirConditionerCycle.Media.{medium}{cold},
      gaps(radialGap={radial}e-6,topGap={top}e-6,bottomGap={bottom}e-6));
  end {name};
end Study;
""", encoding="utf-8")
    log = run_omc(omc, work, [(name,stop,round(stop/0.000025),FIELDS)], "Study", ("hSuction",), model_file=source)
    return verify(work/f"{name}_res.csv", log, model, case, medium, stop)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--omc", default="omc")
    parser.add_argument("--smoke", action="store_true", help="short tests on four other fluids and separate end faces")
    parser.add_argument("--csv", type=Path)
    args = parser.parse_args()
    if args.smoke:
        runs = [(model, "Both", fluid, 0.045) for model in ("Single", "Twin")
                for fluid in ("R290", "R32", "R410A", "CO2")]
        runs += [("Single",case,"R134a",0.045) for case in ("Top","Bottom")]
    else:
        runs = [(model,case,"R134a",0.23) for model in ("Single","Twin") for case in ("Base","Radial","Faces","Both")]
    results = []
    with tempfile.TemporaryDirectory() as temp:
        for model,case,medium,stop in runs:
            row = simulate(args.omc,Path(temp),model,case,medium,stop)
            results.append(row)
            print(f"{model} {medium} {case}: total leakage {row['total_leak_g_s']:.4f} g/s, "
                  f"delivery {row['delivery_g_s']:.3f} g/s")
    if args.csv:
        with args.csv.open("w",encoding="utf-8",newline="") as stream:
            writer = csv.DictWriter(stream,fieldnames=results[0],lineterminator="\n")
            writer.writeheader()
            writer.writerows(results)


if __name__ == "__main__":
    main()
