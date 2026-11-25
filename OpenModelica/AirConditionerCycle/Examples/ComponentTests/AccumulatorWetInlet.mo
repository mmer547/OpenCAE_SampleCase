within AirConditionerCycle.Examples.ComponentTests;
model AccumulatorWetInlet "湿り吸入時のアキュームレータの液保持試験"
  extends Modelica.Icons.Example;
  package Medium = AirConditionerCycle.Media.R134a(
    ThermoStates=Modelica.Media.Interfaces.Choices.IndependentVariables.ph);
  parameter Medium.AbsolutePressure feedPressure=375000;
  parameter Real feedQuality(min=0,max=1)=0.80;
  final parameter Medium.SpecificEnthalpy wetEnthalpy=(1-feedQuality)*Medium.bubbleEnthalpy(Medium.setSat_p(feedPressure))
       + feedQuality*Medium.dewEnthalpy(Medium.setSat_p(feedPressure));
  inner Modelica.Fluid.System system;
  Modelica.Fluid.Sources.Boundary_ph feed(redeclare package Medium=Medium,
    nPorts=1,p=feedPressure,h=wetEnthalpy)
    annotation(Placement(transformation(extent={{-85,-12},{-61,12}})));
  Components.Rotary.Accumulator accumulator(redeclare package Medium=Medium,
    h_start=wetEnthalpy)
    annotation(Placement(transformation(extent={{-20,-20},{20,20}})));
  Modelica.Fluid.Sources.MassFlowSource_h extraction(redeclare package Medium=Medium,
    nPorts=1,m_flow=-0.012)
    annotation(Placement(transformation(extent={{85,-12},{61,12}})));
  Medium.SpecificEnthalpy hDew=Medium.dewEnthalpy(Medium.setSat_p(accumulator.outlet.p));
equation
  connect(feed.ports[1],accumulator.inlet) annotation(Line(points={{-61,0},{-20,0}},color={23,117,162}));
  connect(accumulator.outlet,extraction.ports[1]) annotation(Line(points={{20,0},{61,0}},color={23,117,162}));
  annotation(experiment(StartTime=0,StopTime=0.5,Interval=0.001,Tolerance=1e-7));
end AccumulatorWetInlet;
