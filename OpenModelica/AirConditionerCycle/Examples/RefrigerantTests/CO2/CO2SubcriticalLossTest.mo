within AirConditionerCycle.Examples.RefrigerantTests.CO2;
model CO2SubcriticalLossTest "CO2Subcritical 損失評価"
  extends CO2SubcriticalStandalone(useDetailedLosses=true);
  annotation(experiment(StartTime=0,StopTime=0.23,Interval=0.0000125,Tolerance=3e-8));
end CO2SubcriticalLossTest;
