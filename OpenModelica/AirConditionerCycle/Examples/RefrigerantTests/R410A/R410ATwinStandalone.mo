within AirConditionerCycle.Examples.RefrigerantTests.R410A;
model R410ATwinStandalone
  extends CompressorTests.TwinRotaryStandalone(redeclare package Medium=Media.R410A);
end R410ATwinStandalone;
