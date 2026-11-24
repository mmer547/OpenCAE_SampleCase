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
  parameter Boolean useOilFilm=false "ローラ両端面の公転によるせん断を加える" annotation(Evaluate=true);
  parameter SI.DynamicViscosity oilViscosity(min=0)=0.012 "運転温度での油粘度";
  parameter SI.Length filmThickness(min=1e-8)=12e-6 "片面の油膜厚さ";
  parameter SI.Radius faceRadius(min=1e-6)=0.0195 "ローラ外半径";
  parameter SI.Radius boreRadius(min=0)=0.009 "端面の内半径";
  SI.Torque bearingTorque, oilFilmTorque;
  SI.Power oilFilmLoss "ローラの公転すべりによる両端面の粘性散逸";
  SI.Torque frictionTorque;
initial equation
  assert(not useOilFilm or boreRadius < faceRadius, "The roller bore must lie inside its outer radius.");
equation
  drive.phi = crank.phi;
  w = der(drive.phi);
  bearingTorque = bearingFriction*tanh(w/1.0) + viscous*w;
  oilFilmTorque = if useOilFilm then 2*Modelica.Constants.pi*(faceRadius^2-boreRadius^2)
    *oilViscosity*eccentricity^2*w/filmThickness else 0;
  oilFilmLoss = oilFilmTorque*w;
  frictionTorque = bearingTorque + oilFilmTorque;
  drive.tau + crank.tau = frictionTorque;
  heat.Q_flow = -frictionTorque*w;
  annotation(Icon(graphics={
    Polygon(points={{-92,-10},{-32,-10},{-32,-34},{32,-34},{32,-10},{92,-10},{92,10},{32,10},{32,35},{-32,35},{-32,10},{-92,10},{-92,-10}},
    lineColor={48,76,90}, fillColor={151,181,196}, fillPattern=FillPattern.Solid, lineThickness=1),
    Ellipse(extent={{-14,30},{14,2}},lineColor={48,76,90},fillColor={225,233,237},fillPattern=FillPattern.Solid),
    Text(extent={{-145,-60},{145,-90}},textString="%name",textColor={31,61,76})}));
end EccentricShaft;
