within AirConditionerCycle.Examples.RefrigerantTests.R290;
model R290Standalone "R290 ロータリー圧縮機単体"
  extends CompressorTests.RotaryCompressorStandalone(redeclare package Medium=Media.R290);
end R290Standalone;
