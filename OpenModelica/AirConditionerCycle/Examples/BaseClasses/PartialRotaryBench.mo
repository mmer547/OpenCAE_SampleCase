within AirConditionerCycle.Examples.BaseClasses;
partial model PartialRotaryBench "詳細ロータリー圧縮機の単体試験（吸入・吐出圧力を指定）"
  extends PartialCompressorBench(
    redeclare replaceable model Compressor = Components.Rotary.RollingPistonCompressor
      constrainedby Components.Rotary.BaseClasses.PartialRollingPiston,
    compressor(speed=speed,useDetailedLosses=useDetailedLosses,
      accumulator(inletCheckValve=true,p_start=0.989*suctionPressure,h_start=hSuction),
      suctionPipe(outlet(p(start=0.989*suctionPressure))),
      cylinder(inlet(p(start=0.989*suctionPressure)),
        pocketA(p_start=1.030*dischargePressure,h_start=hDischargeStart),
        pocketB(p_start=0.988*suctionPressure,h_start=hSuction)),
      muffler(p_start=1.025*dischargePressure,h_start=hDischargeStart),
      shell(p_start=1.012*dischargePressure,h_start=hDischargeStart)));
end PartialRotaryBench;
