within AirConditionerCycle.Examples.RefrigerantTests.R32;
model R32AdiabaticStandalone "R32 断熱ロータリー単体"
  extends CompressorTests.AdiabaticRotaryStandalone(redeclare package Medium=Media.R32);
end R32AdiabaticStandalone;
