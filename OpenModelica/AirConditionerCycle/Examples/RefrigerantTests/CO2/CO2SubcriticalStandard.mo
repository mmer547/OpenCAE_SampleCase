within AirConditionerCycle.Examples.RefrigerantTests.CO2;
model CO2SubcriticalStandard "R744、外気 -10 °C の亜臨界試験"
  extends BaseClasses.StandardCase(redeclare package Refrigerant=Media.CO2,
    outdoorTemperature=263.15,evaporatingStart=263.15,condensingStart=281.15);
end CO2SubcriticalStandard;
