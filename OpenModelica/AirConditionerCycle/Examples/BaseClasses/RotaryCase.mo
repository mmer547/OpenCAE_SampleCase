within AirConditionerCycle.Examples.BaseClasses;
partial model RotaryCase
  extends PartialRotaryCase(cycle(compressor(shell(Twall_start=wallStart,Tambient=outdoorTemperature))));
  parameter Modelica.Units.SI.Temperature wallStart=330.15;
end RotaryCase;
