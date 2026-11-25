within AirConditionerCycle.Examples.RefrigerantTests.R410A;
model R410AStandalone "R410A ロータリー圧縮機単体"
  extends CompressorTests.RotaryCompressorStandalone(redeclare package Medium=Media.R410A);
end R410AStandalone;
