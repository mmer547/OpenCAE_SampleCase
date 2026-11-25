within AirConditionerCycle.Examples.CoolingCycles;
model OutdoorTemperatureRamp "外気温を120秒から240秒で35 °Cから40 °Cへ上げる"
  extends Modelica.Icons.Example;
  CoolingCycle cycle
    annotation(Placement(transformation(extent={{-22,-22},{22,22}})));
  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature room(T=298.15)
    annotation(Placement(transformation(extent={{-82,-10},{-62,10}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedTemperature outdoor
    annotation(Placement(transformation(extent={{64,-10},{44,10}})));
  Modelica.Blocks.Sources.Ramp airTemperature(
    offset=308.15, height=5, duration=120, startTime=120, y(unit="K"))
    annotation(Placement(transformation(extent={{96,-8},{80,8}})));
equation
  connect(room.port, cycle.roomAir) annotation(Line(points={{-62,0},{-22,0}},color={164,45,45}));
  connect(cycle.outdoorAir, outdoor.port) annotation(Line(points={{22,0},{44,0}},color={164,45,45}));
  connect(airTemperature.y, outdoor.T) annotation(Line(points={{79.2,0},{66,0}},color={0,0,127}));
  annotation(experiment(StartTime=0, StopTime=600, Interval=2, Tolerance=1e-7));
end OutdoorTemperatureRamp;
