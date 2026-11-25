"""Verify the scroll compressor, its pocket cycle and the refrigerant circuit in OpenModelica."""
import argparse
import csv
import math
from pathlib import Path
import re
import tempfile

from rotary_checks import read_rows, require
from run_tests import run_omc

FLUIDS = ("R134a", "R290", "R32", "R410A", "CO2")
COMPRESSOR = ("(P_el|charge|E|driveLoss|indicatedPower|bearingLoss|motorLoss|oldhamLoss|meanDelivery|"
              "meanPower|m_flow|outlet[.](m_flow|h_outflow)|motor[.]w|orbit[.](x|y)|wraps[.]"
              "(stage.*|revolutions|volumeRate.*)|pockets[.](pocket.*[.](V|p)|toCenter.*|seal.*[.]"
              "(active|tipFlow|flankFlow|m_flow|pA|pB)|tipLeakRate|flankLeakRate))")


def verify(path, log, name, stop):
    cycle = name == "ScrollCooling"
    sealed = name == "Sealed"
    rows = read_rows(path)
    require(len(rows) >= round(stop/0.000025)+1 and rows[-1]["time"] == stop, "Incomplete run")
    prefix = "cycle.compressor." if cycle else "compressor."
    if not cycle:
        suction_h = float(re.search(r"^time=[^,]+,hSuction=([^,\s]+)", log, re.MULTILINE)[1])
    mass_error = energy_error = cycle_error = 0.0
    mass_in = energy_in = system_in = 0.0
    turn_tip = turn_flank = turn_flow = turn_power = 0.0
    completed = 0
    turn_time = 0.0
    minimum_center_flow = 0.0
    for index, row in enumerate(rows):
        require(all(math.isfinite(v) for v in row.values()), "Nonfinite result")
        c = {k[len(prefix):]: v for k,v in row.items() if k.startswith(prefix)}
        phase = [int(c[f"wraps.stage[{i}]"]) for i in range(1,5)]
        require(sorted(phase) == [1,2,3,4], "Every stage must be occupied once")
        volume = sum(c[f"pockets.pocket[{i}].V"] for i in range(1,5))
        work = 0.0
        for i, stage in enumerate(phase, 1):
            key = f"pockets.seal[{i}]."
            rate = c[f"wraps.volumeRate[{i}]"]
            pressure = c[f"pockets.pocket[{i}].p"]
            work -= pressure*rate
            require(pressure > 0 and c[f"pockets.pocket[{i}].V"] > 0, "Chamber state")
            require((rate if stage == 1 else -rate) >= -1e-10, "Stage volume direction")
            if index:
                period = row["time"]-rows[index-1]["time"]
                key_v = f"pockets.pocket[{i}].V"
                last_v = rows[index-1][prefix+key_v]
                last_rate = rows[index-1][prefix+f"wraps.volumeRate[{i}]"]
                require(abs(c[key_v]-last_v-period*(rate+last_rate)/2) < 1e-9,
                        "Volume jump or inconsistent volume derivative")
            require(bool(c[key+"active"]) == (stage < 4), "Seal adjacency")
            tip, flank, net = (c[key+k] for k in ("tipFlow","flankFlow","m_flow"))
            require(abs(tip+flank-net)<1e-11 and net*(c[key+"pA"]-c[key+"pB"])>=-1e-8,
                    "Leakage flow or direction")
            require((not sealed and stage < 4) or abs(net)<1e-13, "Closed leak path")
            central = c[f"pockets.toCenter[{i}]"]
            require(stage == 4 or abs(central)<1e-12, "Discharge port timing")
            minimum_center_flow = min(minimum_center_flow, central)
        require(abs(work-c["indicatedPower"])<1e-5 and
                abs(c["driveLoss"]-sum(c[k] for k in ("bearingLoss","motorLoss","oldhamLoss")))<1e-6
                and min(c["bearingLoss"],c["motorLoss"],c["oldhamLoss"])>=-1e-8, "Shaft work and losses")
        require(abs(math.hypot(c["orbit.x"],c["orbit.y"])-(math.pi*.0023-.003))<1e-10, "Orbit radius")
        dmass = c["m_flow"] + c["outlet.m_flow"]
        h_in = row["cycle.h1"] if cycle else suction_h
        energy_rate = c["P_el"]-c["driveLoss"]+c["m_flow"]*h_in+c["outlet.m_flow"]*c["outlet.h_outflow"]
        sys_energy = sys_mass = sys_rate = 0.0
        if cycle:
            require(min(row["cycle.Q_cooling"],row["cycle.Q_rejected"])>0 and row["cycle.pHigh"]>row["cycle.pLow"]>0,
                    "Cycle pressures and heat rates")
            sys_energy = c["E"]+row["cycle.evaporator.U"]+row["cycle.condenser.U"]
            sys_mass = c["charge"]+row["cycle.evaporator.charge"]+row["cycle.condenser.charge"]
            sys_rate = c["P_el"]-c["driveLoss"]+row["cycle.Q_cooling"]-row["cycle.Q_rejected"]
        current=(dmass,energy_rate,sys_rate,c["pockets.tipLeakRate"],c["pockets.flankLeakRate"],
                 -c["outlet.m_flow"],c["P_el"])
        if index == 0:
            initial_volume, m0, E0, systemE0, systemM0 = volume,c["charge"],c["E"],sys_energy,sys_mass
        else:
            dt=row["time"]-rows[index-1]["time"]
            require(0 <= dt <= 2.51e-5, "Output time grid")
            a,b,d,tip,flank,flow,power=(dt*(left+right)/2 for left,right in zip(previous,current))
            mass_in+=a
            energy_in+=b
            system_in+=d
            turn_tip+=tip
            turn_flank+=flank
            turn_flow+=flow
            turn_power+=power
        previous=current
        require(abs(volume-initial_volume)<1e-12, "Sum of pocket volumes")
        mass_error=max(mass_error,abs(c["charge"]-m0-mass_in),abs(sys_mass-systemM0))
        energy_error=max(energy_error,abs(c["E"]-E0-energy_in))
        cycle_error=max(cycle_error,abs(sys_energy-systemE0-system_in))
        rev=int(c["wraps.revolutions"])
        if rev != completed:
            require(rev == completed+1, "Orbit count")
            duration=row["time"]-turn_time
            mean_tip,mean_flank,delivery,electric=(v/duration for v in (turn_tip,turn_flank,turn_flow,turn_power))
            turn_tip=turn_flank=turn_flow=turn_power=0.0
            turn_time=row["time"]
            completed=rev
    require(completed>=4 and mass_error<3e-7 and max(energy_error,cycle_error)<0.15,
            f"Balance or phase count {completed}, {mass_error:g} kg, {energy_error:g}, {cycle_error:g} J")
    require(delivery>0 and electric>0 and abs(delivery-c["meanDelivery"])<3e-5
            and abs(electric-c["meanPower"])<1.0, "Last-orbit output")
    require((mean_tip>0 and mean_flank>0) if not sealed else (mean_tip==mean_flank==0), "Seal activation")
    return dict(case=name,stop_s=stop,completed_orbits=completed,mean_rpm=60/duration,delivery_g_s=1000*delivery,
                electric_W=electric,tip_leak_g_s=1000*mean_tip,flank_leak_g_s=1000*mean_flank,
                min_center_flow_g_s=1000*minimum_center_flow,mass_residual_kg=mass_error,
                compressor_energy_residual_J=energy_error,cycle_energy_residual_J=cycle_error if cycle else "")


def simulate(omc, work, name):
    cycle=name=="ScrollCooling"
    namespace="AirConditionerCycle.Examples"
    stop=.12 if name in ("ScrollStandalone","ScrollCooling") else .105
    source=None
    if name not in ("ScrollStandalone","ScrollCooling"):
        fluid="R134a" if name=="Sealed" else name
        changes=(", suctionPressure=Medium.saturationPressure(263.15), dischargePressure=Medium.saturationPressure(281.15)"
                 if fluid=="CO2" else "")
        if name=="Sealed":
            changes+=", compressor(pockets(seal(each tipGap=0,each flankGap=0)))"
        source=work/"Study.mo"
        source.write_text(f"""within ;
package Study
  model {name}
    extends AirConditionerCycle.Examples.ScrollStandalone(
      redeclare package Medium=AirConditionerCycle.Media.{fluid}{changes});
  end {name};
end Study;
""",encoding="utf-8")
        namespace="Study"
    fields=("cycle[.](pLow|pHigh|h1|h2|P_el|Q_cooling|Q_rejected|evaporator[.](U|charge)|condenser[.]"
            "(U|charge)|compressor[.]"+COMPRESSOR+")" if cycle else
            "dischargeFlow|dischargeTemperature|compressor[.]"+COMPRESSOR)
    log=run_omc(omc,work,[(name,stop,round(stop/.000025),fields)],namespace,() if cycle else ("hSuction",),
                model_file=source)
    return verify(work/f"{name}_res.csv",log,name,stop)


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--omc",default="omc")
    parser.add_argument("--fluid",choices=(*FLUIDS,"all"),default="R134a")
    parser.add_argument("--csv",type=Path)
    args=parser.parse_args()
    fluids=FLUIDS if args.fluid=="all" else (args.fluid,)
    cases=["ScrollStandalone" if fluid=="R134a" else fluid for fluid in fluids]+["ScrollCooling","Sealed"]
    results=[]
    with tempfile.TemporaryDirectory() as folder:
        for name in cases:
            row=simulate(args.omc,Path(folder),name)
            results.append(row)
            print(f"{name}: {row['completed_orbits']} orbits, {row['delivery_g_s']:.2f} g/s, {row['electric_W']:.1f} W")
    if args.csv:
        with args.csv.open("w",encoding="utf-8",newline="") as stream:
            writer=csv.DictWriter(stream,fieldnames=results[0],lineterminator="\n")
            writer.writeheader()
            writer.writerows(results)


if __name__=="__main__":
    main()
