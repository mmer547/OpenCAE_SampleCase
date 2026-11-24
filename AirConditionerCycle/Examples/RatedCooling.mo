within AirConditionerCycle.Examples;
model RatedCooling "定格冷房（室内25 °C、室外35 °C）"
  extends Modelica.Icons.Example;
  CoolingCycle cycle
    annotation(Placement(transformation(extent={{-22,-22},{22,22}})));
  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature room(T=298.15)
    annotation(Placement(transformation(extent={{-82,-10},{-62,10}})));
  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature outdoor(T=308.15)
    annotation(Placement(transformation(extent={{82,-10},{62,10}})));
equation
  connect(room.port, cycle.roomAir) annotation(Line(points={{-62,0},{-22,0}},color={164,45,45}));
  connect(cycle.outdoorAir, outdoor.port) annotation(Line(points={{22,0},{62,0}},color={164,45,45}));
  annotation(experiment(StartTime=0, StopTime=600, Interval=2, Tolerance=1e-7));
end RatedCooling;
