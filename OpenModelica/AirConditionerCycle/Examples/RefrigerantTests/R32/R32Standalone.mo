within AirConditionerCycle.Examples.RefrigerantTests.R32;
model R32Standalone "R32 ロータリー圧縮機単体"
  extends CompressorTests.RotaryCompressorStandalone(redeclare package Medium=Media.R32);
end R32Standalone;
