within AirConditionerCycle.Examples.RefrigerantTests.R410A;
model R410AAdiabaticStandalone "R410A 断熱ロータリー単体"
  extends CompressorTests.AdiabaticRotaryStandalone(redeclare package Medium=Media.R410A);
end R410AAdiabaticStandalone;
