"""Power-path and full-revolution checks for the rolling-piston loss report."""
import math

from rotary_checks import read_rows, require

CHANNELS = ("copper", "iron", "auxiliary", "bearing", "vane", "oilFilm", "suctionDrop",
            "dischargeDrop", "leakageDrop", "indicated", "shellHeat", "electric", "isentropic")
REPORT = "compressor.losses."
LOSS_FIELDS = ("compressor[.](losses[.].*|motor[.](E_rotor|driveTorque|w|heat[.]Q_flow)|"
               "vane[.]E|shaft[.](heat[.]Q_flow|bearingTorque|oilFilmTorque)|shell[.](Twall|Q_gas)|"
               "cylinder[.](leakAB|pocket[AB][.]p)|roller[.]volumeRateA)")


def channel(row, signal, name):
    return row[f"{REPORT}{signal}[{REPORT}Channel.{name}]"]


def check_losses(path, adiabatic=False):
    rows = read_rows(path)
    previous_rates = None
    turn_integrals = {}
    drive_energy = max_drive_error = 0.0
    turn_start = 0.0
    previous_rev = 0
    for row in rows:
        # A constant auxiliary load is omitted as a parameter from the OpenModelica CSV.
        rates = {k: channel(row, "power", k) for k in CHANNELS if k != "auxiliary"}
        motor = row[REPORT+"motorLoss"]
        mechanical = row[REPORT+"mechanicalLoss"]
        rates["auxiliary"] = motor-rates["copper"]-rates["iron"]
        rates["delivery"] = row["dischargeFlow"]
        rates["leak"] = abs(row["compressor.cylinder.leakAB"])
        rates["theoretical"] = row[REPORT+"theoretical"]
        time = row["time"]
        require(all(v >= -1e-7 for k, v in rates.items() if k not in ("indicated", "shellHeat")),
                f"Unexpected sign of a compressor loss or mass flow at {time}")
        omega = row["compressor.motor.w"]
        require(abs(rates["electric"] - row["compressor.motor.driveTorque"]*omega - motor) < 1e-6,
                "Electrical-to-mechanical power split")
        if adiabatic:
            shaft_loss = row["compressor.shaft.frictionTorque"]*omega
            require(abs(row["compressor.driveLoss"]-motor-mechanical) < 1e-6
                    and abs(rates["vane"]-row["compressor.vane.friction"]*row["compressor.vane.v"]) < 1e-6
                    and abs(rates["shellHeat"]) < 1e-10, "Adiabatic drive losses and zero shell heat")
        else:
            shaft_loss = -row["compressor.shaft.heat.Q_flow"]
            require(abs(motor + row["compressor.motor.heat.Q_flow"]) < 1e-6, "Motor heat rejection")
        require(abs(rates["bearing"]+rates["oilFilm"] - shaft_loss) < 1e-6
                and abs(rates["oilFilm"]-row["compressor.shaft.oilFilmTorque"]*omega) < 1e-6
                and abs(mechanical-rates["bearing"]-rates["vane"]-rates["oilFilm"]) < 1e-6,
                "Mechanical dissipation and generated heat")
        dp = row["compressor.cylinder.pocketA.p"] - row["compressor.cylinder.pocketB.p"]
        require(abs(rates["indicated"] + dp*row["compressor.roller.volumeRateA"]) < 1e-5,
                "Indicated power from chamber pressure and volume")
        storage_rate = rates["electric"]-rates["indicated"]-motor-mechanical
        mechanical_energy = row["compressor.motor.E_rotor"]+row["compressor.vane.E"]
        if previous_rates is None:
            initial_mechanical_energy = mechanical_energy
            turn_integrals = dict.fromkeys(rates, 0.0)
        else:
            dt = time-previous_time
            for k in rates:
                turn_integrals[k] += dt*(previous_rates[k]+rates[k])/2
            drive_energy += dt*(previous_storage_rate+storage_rate)/2
            max_drive_error = max(max_drive_error, abs(mechanical_energy-initial_mechanical_energy-drive_energy))

        revolution = int(row["compressor.roller.revolutions"])
        if revolution != previous_rev:
            period = time-turn_start
            for k in CHANNELS:
                measured = turn_integrals[k]/period
                require(math.isclose(channel(row, "meanPower", k), measured, rel_tol=2e-3, abs_tol=0.5),
                        f"Revolution {revolution}, {k} average versus independent integration")
            require(abs(row[REPORT+"meanLeakRate"]-turn_integrals["leak"]/period) < 3e-6,
                    "Average absolute leakage")
            require(abs(row[REPORT+"volumetricEfficiency"]-turn_integrals["delivery"]/turn_integrals["theoretical"]) < 0.0015
                    and abs(row[REPORT+"isentropicEfficiency"]-turn_integrals["isentropic"]/turn_integrals["electric"]) < 0.0015,
                    "Full-revolution efficiency ratios")
            turn_start = time
            turn_integrals = dict.fromkeys(rates, 0.0)
        previous_rates, previous_storage_rate, previous_time, previous_rev = rates, storage_rate, time, revolution
    require(max_drive_error < 0.12, f"Electrical, friction, indicated and storage balance: {max_drive_error:g} J")
    last = rows[-1]
    result = {f"last_turn_{k}_W": channel(last, "meanPower", k) for k in CHANNELS}
    result.update(last_turn_motor_loss_W=sum(channel(last, "meanPower", k) for k in ("copper", "iron", "auxiliary")),
                  last_turn_mechanical_loss_W=sum(channel(last, "meanPower", k) for k in ("bearing", "vane", "oilFilm")),
                  last_turn_abs_leak_kg_s=last[REPORT+"meanLeakRate"],
                  last_turn_volumetric_efficiency=last[REPORT+"volumetricEfficiency"],
                  last_turn_isentropic_electric_efficiency=last[REPORT+"isentropicEfficiency"],
                  max_drive_balance_error_J=max_drive_error)
    return result
