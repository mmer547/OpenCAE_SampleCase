"""Checks for the angle-resolved compressor and its wet-inlet component test."""
import csv
import math

ROTARY_FILTER = (
    "meanPower|meanDelivery|cycle[.](P_el|Q_cooling|Q_rejected|pLow|pHigh|h1|h2|"
    "evaporator[.](charge|U)|condenser[.](charge|U)|compressor[.](charge|E|m_flow|"
    "outlet[.]m_flow|roller[.](angle|revolutions|a[.]V|b[.]V)|cylinder[.](pocket[AB][.]p|m_flow)|"
    "reed[.](lift|m_flow)|motor[.]w|muffler[.]gas[.]p|shell[.](gas[.]p|Q_ambient)))"
)


def read_rows(path):
    with path.open(newline="", encoding="utf-8-sig") as stream:
        return [{k: float(v) for k, v in row.items()} for row in csv.DictReader(stream)]


def require(test, message):
    if not test:
        raise ValueError(message)


def check_rotary(path, waveform_csv, stop_time=0.21, high_pressure_limit=math.inf):
    rows = read_rows(path)
    expected_points = round(stop_time / 0.000025) + 1
    require(len(rows) >= expected_points and rows[0]["time"] == 0 and rows[-1]["time"] == stop_time,
            f"RotaryCooling: incomplete {stop_time} s trajectory")
    errors = [0.0, 0.0, 0.0]
    integral = [0.0, 0.0, 0.0]
    points = []
    for i, r in enumerate(rows):
        c = {k[len("cycle.compressor."):]: v for k, v in r.items() if k.startswith("cycle.compressor.")}
        t = r["time"]
        rev = int(c["roller.revolutions"])
        require(all(math.isfinite(x) for x in r.values()), f"Non-finite rotary output at {t} s")
        require(0 < r["cycle.pLow"] < r["cycle.pHigh"] < high_pressure_limit,
                f"Cycle pressures at {t} s")
        require(min(r["cycle.Q_cooling"], r["cycle.Q_rejected"], r["cycle.P_el"]) > 0,
                f"Heat or power sign at {t} s")
        mass = c["charge"] + r["cycle.evaporator.charge"] + r["cycle.condenser.charge"]
        energy = c["E"] + r["cycle.evaporator.U"] + r["cycle.condenser.U"]
        shaft_system_input = r["cycle.P_el"] - c["shell.Q_ambient"]
        rates = [c["m_flow"] + c["outlet.m_flow"],
                 shaft_system_input + c["m_flow"]*r["cycle.h1"] + c["outlet.m_flow"]*r["cycle.h2"],
                 shaft_system_input + r["cycle.Q_cooling"] - r["cycle.Q_rejected"]]
        stored = [c["charge"], c["E"], energy]
        total_volume = c["roller.a.V"] + c["roller.b.V"]
        if i == 0:
            initial_mass, initial_volume, initial_stored = mass, total_volume, stored
        else:
            dt = t - rows[i-1]["time"]
            require(0 <= dt <= 0.0000251, "RotaryCooling: output grid")
            for j, rate in enumerate(rates):
                integral[j] += dt*(rate + last_rates[j])/2
                errors[j] = max(errors[j], abs(stored[j] - initial_stored[j] - integral[j]))
        last_rates = rates
        require(abs(mass-initial_mass) < 1e-6, f"Cycle refrigerant charge at {t} s")
        require(abs(total_volume-initial_volume) < 1e-12 and min(c["roller.a.V"],c["roller.b.V"]) > 0,
                f"Rolling piston volumes at {t} s")
        p_a, p_b = c["cylinder.pocketA.p"], c["cylinder.pocketB.p"]
        p_ch = p_b if rev % 2 == 0 else p_a
        reed_flow = c["reed.m_flow"]
        require(reed_flow >= -1e-9 and (p_ch >= c["muffler.gas.p"]-1 or reed_flow < 1e-8),
                f"Reed direction at {t} s")
        require(-1e-8 <= c["reed.lift"] <= 0.001001, f"Reed travel at {t} s")
        points.append(dict(time_s=t, revolution=rev, angle_deg=math.degrees(c["roller.angle"]),
                           volume_A_cm3=1e6*c["roller.a.V"], pressure_A_MPa=p_a/1e6,
                           volume_B_cm3=1e6*c["roller.b.V"], pressure_B_MPa=p_b/1e6,
                           compression_MPa=p_ch/1e6, muffler_MPa=c["muffler.gas.p"]/1e6,
                           shell_MPa=c["shell.gas.p"]/1e6, reed_mm=1000*c["reed.lift"],
                           reed_kg_s=reed_flow, delivery_kg_s=-c["outlet.m_flow"],
                           rpm=c["motor.w"]*60/(2*math.pi), electric_W=r["cycle.P_el"]))
    require(errors[0] < 2e-7 and max(errors[1:]) < 0.12,
            f"Compressor mass / compressor and cycle energy residuals: {errors}")

    completed = points[-1]["revolution"]
    require(completed >= 10, "Too few completed shaft revolutions")
    for rev in range(completed):
        turn = [p for p in points if p["revolution"] == rev]
        require(max(p["reed_mm"] for p in turn) > 0.4 and min(p["reed_mm"] for p in turn) < 0.05,
                f"Reed opening and closure, turn {rev+1}")
    start = next(i for i, p in enumerate(points) if p["revolution"] == completed-1)
    end = next(i for i, p in enumerate(points) if p["revolution"] == completed)
    turn = points[start:end+1]
    duration = turn[-1]["time_s"] - turn[0]["time_s"]
    for column, result, tolerance in (("electric_W", "meanPower", 0.25),
                                      ("delivery_kg_s", "meanDelivery", 0.00003)):
        average = sum((b["time_s"]-a["time_s"])*(b[column]+a[column])/2
                      for a, b in zip(turn, turn[1:]))/duration
        require(abs(average-rows[-1][result]) < tolerance, f"Revolution average: {result}")
    if waveform_csv:
        with waveform_csv.open("w", encoding="utf-8", newline="") as stream:
            writer = csv.DictWriter(stream, fieldnames=points[0])
            writer.writeheader()
            writer.writerows(p for p in points[:end+1] if p["revolution"] >= completed-2)
    print(f"RotaryCooling             {completed} complete rev, last full rev: "
          f"{rows[-1]['meanPower']:.2f} W, {rows[-1]['meanDelivery']:.5f} kg/s; "
          f"max cycle energy residual {errors[2]:.4f} J")
    return dict(completed_revolutions=completed, last_revolution_rpm=60/duration,
                electric_kW=rows[-1]["meanPower"]/1000, mass_flow_kg_s=rows[-1]["meanDelivery"])


def check_wet_inlet(path):
    rows = read_rows(path)
    require(rows[0]["time"] == 0 and rows[-1]["time"] == 0.5, "Wet inlet: time range")
    for r in rows:
        require(0 < r["accumulator.quality"] < 1 and r["accumulator.liquidMass"] > 0
                and abs(r["accumulator.outlet.h_outflow"] - r["hDew"]) < 0.02,
                f"Wet inlet: vapour separation at {r['time']} s")
    initial, final = (r["accumulator.liquidMass"]*1000 for r in (rows[0], rows[-1]))
    require(final > initial+0.5, "Wet inlet: retained liquid mass")
    print(f"AccumulatorWetInlet       retained liquid {initial:.3f} -> {final:.3f} g")
