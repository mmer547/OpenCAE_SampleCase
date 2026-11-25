within AirConditionerCycle.Examples.RefrigerantTests.CO2;
model CO2SubcriticalTwinCooling
  extends CoolingCycles.TwinRotaryCooling(outdoor(T=263.15), cycle(redeclare package Medium=Media.CO2,
    evaporator(T_start=263.15), condenser(T_start=281.15)));
end CO2SubcriticalTwinCooling;
