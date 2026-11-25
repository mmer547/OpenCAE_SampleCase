within AirConditionerCycle.Examples.RefrigerantTests.R32;
model R32Rotary
  extends BaseClasses.RotaryCase(redeclare package Refrigerant=Media.R32,
    shellPressureRatio=1.012,mufflerPressureRatio=1.025,pocketAPressureRatio=1.03,
    wallStart=Refrigerant.temperature_ph(pH,hD));
end R32Rotary;
