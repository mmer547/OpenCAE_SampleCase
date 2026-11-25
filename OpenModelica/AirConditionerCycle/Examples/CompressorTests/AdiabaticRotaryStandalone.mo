within AirConditionerCycle.Examples.CompressorTests;
model AdiabaticRotaryStandalone "断熱ロータリー単体試験（詳細損失を表示）"
  extends BaseClasses.PartialRotaryBench(
    redeclare final model Compressor = Components.Rotary.AdiabaticRollingPistonCompressor,
    useDetailedLosses=true);
  annotation(experiment(StartTime=0,StopTime=0.23,Interval=0.000025,Tolerance=1e-7),
    Documentation(info="<html><p>吸入圧力・過熱度・吐出背圧・回転数を指定します。dischargeTemperature、dischargeFlow、compressor.driveLoss と compressor.losses.meanPower が主な観測量です。</p></html>"));
end AdiabaticRotaryStandalone;
