within AirConditionerCycle.Examples.RefrigerantTests.R32;
model R32AdiabaticCooling
  extends BaseClasses.AdiabaticRotaryCase(redeclare package Refrigerant=Media.R32,
    shellPressureRatio=1.012,mufflerPressureRatio=1.025,pocketAPressureRatio=1.03);
end R32AdiabaticCooling;
