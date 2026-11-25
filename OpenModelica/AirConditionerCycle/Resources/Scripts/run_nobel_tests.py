"""Run Nobel compressor examples and check geometry, leakage, friction and boundary balances."""
import argparse
import csv
import math
from pathlib import Path
import tempfile

from rotary_checks import ROTARY_FILTER, check_rotary, read_rows, require
from run_standalone_tests import FIELDS, PARAMETERS, check_compressor
from run_tests import run_omc


NOBEL_FIELDS = (FIELDS + "|compressor[.](driveLoss|motor[.]E_rotor|vane[.](E|slideLoss|pivotLoss|frictionPower)|"
                "losses[.]power.*|roller[.](shaft[.]phi|beta|follower[.]s|volumeRateA|a[.]V|b[.]V)|"
                "cylinder[.](leakAB|vaneTipLeakAB|radialLeakAB|topFaceLeakAB|bottomFaceLeakAB))")
FLUIDS = ("R134a", "R290", "R32", "R410A", "CO2")


def polygon_volume(theta, beta, bore, eccentricity, pivot, height):
    """Independent oriented polygon approximation for the growing chamber (no dead volume)."""
    radius = bore-eccentricity
    cx, cy = eccentricity*math.cos(theta), eccentricity*math.sin(theta)
    # Intersect the ray from the bush back towards the roller with the cylinder bore.
    to_wall = pivot*math.cos(beta) - math.sqrt(bore**2-(pivot*math.sin(beta))**2)
    wall_angle = math.atan2(-to_wall*math.sin(beta), pivot-to_wall*math.cos(beta))
    points = []
    for x, y, r, start, end in ((0, 0, bore, wall_angle, theta), (cx, cy, radius, theta, beta)):
        for i in range(513):
            angle = start + (end-start)*i/512
            points.append((x+r*math.cos(angle), y+r*math.sin(angle)))
    twice_area = sum(x*v-y*u for (x,y),(u,v) in zip(points, points[1:]+points[:1]))
    return height*twice_area/2


def verify_mechanism(path):
    rows = read_rows(path)
    # Nominal dimensions of the packaged examples.
    bore, eccentricity, pivot, height = 0.024, 0.0045, 0.027, 0.0455
    swept = math.pi*height*(bore**2-(bore-eccentricity)**2)
    angles = []
    sample_at = 0.15
    samples = 0
    for row in rows:
        angle = row["compressor.roller.shaft.phi"]
        beta = row["compressor.roller.beta"]
        angles.append(beta)
        distance = math.hypot(pivot-eccentricity*math.cos(angle), eccentricity*math.sin(angle))
        stroke = row["compressor.roller.follower.s"]
        require(abs(stroke-(distance-pivot+eccentricity)) < 1e-10, "Blade stroke")
        require(abs(distance*math.sin(beta)+eccentricity*math.sin(angle)) < 1e-10, "Blade alignment")
        a, b = (row["compressor.roller."+ch+".V"] for ch in ("a", "b"))
        require(min(a,b) > 0 and abs(a+b-1.05*swept) < 1e-12, "Pocket volume sum")
        if sample_at <= angle < 2*math.pi:
            reference = polygon_volume(angle, beta, bore, eccentricity, pivot, height)
            require(abs(a-0.025*swept-reference) < 0.0001*swept, "Independent chamber geometry")
            sample_at += 0.3
            samples += 1
        frev = int(row["compressor.roller.revolutions"])
        require((-1)**frev*row["compressor.roller.volumeRateA"] >= -1e-10, "Volume rate direction")
        slide, rock = (row["compressor.vane."+loss] for loss in ("slideLoss", "pivotLoss"))
        require(min(slide,rock) >= -1e-10 and abs(slide+rock-row["compressor.vane.frictionPower"]) < 1e-8
                and abs(slide+rock-row["compressor.losses.power[compressor.losses.Channel.vane]"]) < 1e-8,
                "Bush friction accounting")
        tip, radial, top, bottom, total = (row["compressor.cylinder."+key] for key in
                ("vaneTipLeakAB", "radialLeakAB", "topFaceLeakAB", "bottomFaceLeakAB", "leakAB"))
        require(tip == 0 and abs(total-radial-top-bottom) < 1e-12, "Leakage paths")
    require(samples >= 20, "Too few independent geometric samples")
    for key in ("compressor.vane.slideLoss", "compressor.vane.pivotLoss", "compressor.cylinder.radialLeakAB",
                "compressor.cylinder.topFaceLeakAB", "compressor.cylinder.bottomFaceLeakAB"):
        require(max(abs(row[key]) for row in rows) > 0, f"Inactive {key}")
    limit = math.asin(eccentricity/pivot)
    require(abs(max(angles)-limit) < 2e-5 and abs(min(angles)+limit) < 2e-5, "Bush angle extrema")
    return dict(min_angle_deg=math.degrees(min(angles)), max_angle_deg=math.degrees(max(angles)))


def run_standalone(compiler, work, fluid):
    # A media redeclaration must happen before flattening. CO2 uses a subcritical discharge state.
    conditions = (", suctionPressure=Medium.saturationPressure(263.15), dischargePressure=Medium.saturationPressure(281.15)"
                  if fluid == "CO2" else "")
    name = "Nobel" + fluid
    source = work / "NobelBench.mo"
    source.write_text(f"""within ;
package NobelBench
  model {name}
    extends AirConditionerCycle.Examples.CompressorTests.NobelStandalone(
      redeclare package Medium=AirConditionerCycle.Media.{fluid}{conditions});
  end {name};
end NobelBench;
""", encoding="utf-8")
    intervals, tolerance = (18400, 3e-8) if fluid == "CO2" else (9200, 1e-7)
    log = run_omc(compiler, work, [(name, 0.23, intervals, NOBEL_FIELDS)], "NobelBench",
                  PARAMETERS, tolerance, model_file=source)
    path = work / f"{name}_res.csv"
    return dict(refrigerant=fluid, **check_compressor(path, log, intervals, "driveLoss"), **verify_mechanism(path))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--omc", default="omc")
    parser.add_argument("--fluid", choices=(*FLUIDS, "all"), default="R134a")
    parser.add_argument("--csv", type=Path, help="save one complete-turn summary per fluid")
    args = parser.parse_args()
    with tempfile.TemporaryDirectory() as folder:
        work = Path(folder)
        results = []
        for fluid in (FLUIDS if args.fluid == "all" else [args.fluid]):
            result = run_standalone(args.omc, work, fluid)
            print(f"{fluid}: {result['completed_revolutions']} revolutions, "
                  f"{result['last_turn_discharge_kg_s']*1000:.3f} g/s")
            results.append(result)
        name = "NobelCooling"
        run_omc(args.omc, work, [(name, 0.21, 8400, ROTARY_FILTER + "|cycle[.]compressor[.]driveLoss")],
                "AirConditionerCycle.Examples.CoolingCycles")
        check_rotary(work / f"{name}_res.csv", None, boundary_loss="driveLoss")
    if args.csv:
        with args.csv.open("w", encoding="utf-8", newline="") as stream:
            writer = csv.DictWriter(stream, fieldnames=results[0], lineterminator="\n")
            writer.writeheader()
            writer.writerows(results)


if __name__ == "__main__":
    main()
