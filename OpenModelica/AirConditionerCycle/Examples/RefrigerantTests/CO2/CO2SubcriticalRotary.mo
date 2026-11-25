within AirConditionerCycle.Examples.RefrigerantTests.CO2;
model CO2SubcriticalRotary "R744、外気 -10 °C の亜臨界試験"
  extends BaseClasses.RotaryCase(redeclare package Refrigerant=Media.CO2,
    outdoorTemperature=263.15,evaporatingStart=263.15,condensingStart=281.15,
    shellPressureRatio=1.012,mufflerPressureRatio=1.025,pocketAPressureRatio=1.03,
    wallStart=Refrigerant.temperature_ph(pH,hD));
  annotation(experiment(StartTime=0,StopTime=0.23,Interval=0.000025,Tolerance=1e-7));
end CO2SubcriticalRotary;
