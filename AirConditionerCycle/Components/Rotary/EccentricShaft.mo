within AirConditionerCycle.Components.Rotary;
model EccentricShaft "偏心軸。軸受摩擦トルクと発熱"
  import SI = Modelica.Units.SI;
  parameter SI.Length eccentricity(min=1e-5)=0.0045 "ローラ中心の偏心量";
  parameter SI.Torque bearingFriction(min=0)=0.11;
  parameter SI.RotationalDampingConstant viscous(min=0)=0.00008;
  Modelica.Mechanics.Rotational.Interfaces.Flange_a drive
    annotation(Placement(transformation(extent={{-110,-10},{-90,10}})));
  Modelica.Mechanics.Rotational.Interfaces.Flange_b crank
    annotation(Placement(transformation(extent={{90,-10},{110,10}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_b heat
    annotation(Placement(transformation(extent={{-10,-110},{10,-90}})));
  SI.AngularVelocity w;
  SI.Torque frictionTorque;
equation
  drive.phi = crank.phi;
  w = der(drive.phi);
  frictionTorque = bearingFriction*tanh(w/1.0) + viscous*w;
  drive.tau + crank.tau = frictionTorque;
  heat.Q_flow = -frictionTorque*w;
  annotation(Icon(graphics={
    Polygon(points={{-92,-10},{-32,-10},{-32,-34},{32,-34},{32,-10},{92,-10},{92,10},{32,10},{32,35},{-32,35},{-32,10},{-92,10},{-92,-10}},
    lineColor={48,76,90}, fillColor={151,181,196}, fillPattern=FillPattern.Solid, lineThickness=1),
    Ellipse(extent={{-14,30},{14,2}},lineColor={48,76,90},fillColor={225,233,237},fillPattern=FillPattern.Solid),
    Text(extent={{-145,-60},{145,-90}},textString="%name",textColor={31,61,76})}));
end EccentricShaft;
