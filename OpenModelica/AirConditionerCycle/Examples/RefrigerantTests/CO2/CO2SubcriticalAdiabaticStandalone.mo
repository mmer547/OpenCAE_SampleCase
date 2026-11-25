within AirConditionerCycle.Examples.RefrigerantTests.CO2;
model CO2SubcriticalAdiabaticStandalone "CO2 断熱ロータリー単体"
  extends CompressorTests.AdiabaticRotaryStandalone(redeclare package Medium=Media.CO2,
    suctionPressure=Medium.saturationPressure(263.15), dischargePressure=Medium.saturationPressure(281.15));
  annotation(experiment(StartTime=0,StopTime=0.23,Interval=0.0000125,Tolerance=3e-8));
end CO2SubcriticalAdiabaticStandalone;
