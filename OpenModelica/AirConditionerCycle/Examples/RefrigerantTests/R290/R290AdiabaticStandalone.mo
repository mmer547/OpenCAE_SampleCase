within AirConditionerCycle.Examples.RefrigerantTests.R290;
model R290AdiabaticStandalone "R290 断熱ロータリー単体"
  extends CompressorTests.AdiabaticRotaryStandalone(redeclare package Medium=Media.R290);
end R290AdiabaticStandalone;
