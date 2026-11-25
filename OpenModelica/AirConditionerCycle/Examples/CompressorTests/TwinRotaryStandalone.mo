within AirConditionerCycle.Examples.CompressorTests;
model TwinRotaryStandalone "180度位相差の断熱ツインロータリー単体試験"
  extends BaseClasses.PartialCompressorBench(
    redeclare final model Compressor = Components.Rotary.TwinRotaryCompressor,
    useDetailedLosses=true,compressor(speed=speed,useDetailedLosses=useDetailedLosses,
      pSuctionStart=suctionPressure,pDischargeStart=dischargePressure,
      hSuctionStart=hSuction,hDischargeStart=hDischargeStart));
  annotation(experiment(StartTime=0,StopTime=0.23,Interval=0.000025,Tolerance=1e-7),
    Documentation(info="<html><p>compressor.upper.reed.m_flow と compressor.lower.reed.m_flow が各気筒の吐出、dischargeFlow が共通吐出管での流量です。compressor.losses.meanPower は上側ローラを基準にした直前1回転の平均です。</p></html>"));
end TwinRotaryStandalone;
