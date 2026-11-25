within AirConditionerCycle.Examples.RefrigerantTests.R410A;
model R410ATwinCooling
  extends CoolingCycles.TwinRotaryCooling(cycle(redeclare package Medium=Media.R410A));
end R410ATwinCooling;
