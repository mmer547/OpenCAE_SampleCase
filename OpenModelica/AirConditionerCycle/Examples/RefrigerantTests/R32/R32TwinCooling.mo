within AirConditionerCycle.Examples.RefrigerantTests.R32;
model R32TwinCooling
  extends CoolingCycles.TwinRotaryCooling(cycle(redeclare package Medium=Media.R32));
end R32TwinCooling;
