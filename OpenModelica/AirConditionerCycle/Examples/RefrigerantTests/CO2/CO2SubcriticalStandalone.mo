within AirConditionerCycle.Examples.RefrigerantTests.CO2;
model CO2SubcriticalStandalone "CO₂ ロータリー圧縮機単体・亜臨界圧力条件"
  extends CompressorTests.RotaryCompressorStandalone(redeclare package Medium=Media.CO2,
    suctionPressure=Medium.saturationPressure(263.15),dischargePressure=Medium.saturationPressure(281.15),
    ambientTemperature=263.15);
end CO2SubcriticalStandalone;
