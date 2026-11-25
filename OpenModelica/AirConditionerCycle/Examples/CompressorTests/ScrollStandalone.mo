within AirConditionerCycle.Examples.CompressorTests;
model ScrollStandalone "断熱スクロール圧縮機の吸入・吐出境界試験"
  extends BaseClasses.PartialCompressorBench(redeclare final model Compressor=Components.Scroll.ScrollCompressor,
    useDetailedLosses=true,compressor(speed=speed,useDetailedLosses=useDetailedLosses,
      pSuction_start=0.989*suctionPressure,pDischarge_start=1.012*dischargePressure,
      hSuction_start=hSuction,hDischarge_start=hDischargeStart));
  annotation(experiment(StopTime=0.12,Interval=0.000025,Tolerance=1e-7),
    Documentation(info="<html><p>compressor.wraps.stage、compressor.pockets.pocket[1].p、compressor.indicatedPower、compressor.pockets.tipLeakRate と flankLeakRate を観察できます。</p></html>"));
end ScrollStandalone;
