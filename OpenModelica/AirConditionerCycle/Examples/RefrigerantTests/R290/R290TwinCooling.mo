within AirConditionerCycle.Examples.RefrigerantTests.R290;
model R290TwinCooling
  extends CoolingCycles.TwinRotaryCooling(cycle(redeclare package Medium=Media.R290));
end R290TwinCooling;
