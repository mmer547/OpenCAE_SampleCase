within AirConditionerCycle.Examples.RefrigerantTests.CO2;
model CO2SubcriticalTwinStandalone
  extends CompressorTests.TwinRotaryStandalone(redeclare package Medium=Media.CO2,
    suctionPressure=Medium.saturationPressure(263.15), dischargePressure=Medium.saturationPressure(281.15));
end CO2SubcriticalTwinStandalone;
