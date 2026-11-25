within AirConditionerCycle.Components.Rotary;
model Roller "偏心ローラの厳密な三日月断面積と圧力トルク"
  import SI = Modelica.Units.SI;
  import Modelica.Constants.pi;
  parameter SI.Radius R(min=1e-4)=0.024 "シリンダ内半径";
  parameter SI.Length e(min=1e-5)=0.0045 "偏心量";
  parameter SI.Length height(min=1e-4)=0.0455 "シリンダ高さ";
  parameter Real clearanceRatio(min=0.001,max=0.2)=0.025 "各ポケットの隙間容積／押しのけ容積";
  final parameter SI.Radius r=R-e "ローラ半径";
  final parameter SI.Volume displacement=pi*height*(R^2-r^2);
  Modelica.Mechanics.Rotational.Interfaces.Flange_a shaft
    annotation(Placement(transformation(extent={{-110,-10},{-90,10}})));
  Modelica.Mechanics.Translational.Interfaces.Flange_b follower
    annotation(Placement(transformation(extent={{-10,-110},{10,-90}})));
  BaseClasses.VolumePort a annotation(Placement(transformation(extent={{-55,90},{-35,110}})));
  BaseClasses.VolumePort b annotation(Placement(transformation(extent={{35,90},{55,110}})));
  Modelica.Blocks.Interfaces.BooleanOutput fillingA
    annotation(Placement(transformation(extent={{90,35},{110,55}})));
  Integer revolutions(start=0,fixed=true) "完了回転数";
  Modelica.Blocks.Interfaces.RealOutput volumeRateA(unit="m3/s")
    annotation(Placement(transformation(extent={{90,65},{110,85}})));
  SI.Angle angle "軸角 0～2π";
protected
  SI.Length chord "ベーン中心線上のローラ半弦";
  SI.Length radiusAtVane;
  SI.Length dx_dAngle;
  SI.Volume swept;
  SI.Volume dV_dAngle "吸入側の容積変化量／rad";
  SI.Volume dVA_dAngle;
initial equation
  assert(e < R/2, "Geometry requires a roller enclosing the cylinder centre.");
equation
  revolutions = integer(shaft.phi/(2*pi));
  angle = shaft.phi - 2*pi*revolutions;
  fillingA = mod(revolutions, 2) == 0;
  chord = sqrt(r^2 - (e*sin(shaft.phi))^2);
  radiusAtVane = e*cos(shaft.phi) + chord;
  follower.s = R - radiusAtVane;
  dx_dAngle = e*sin(shaft.phi)*(1 + e*cos(shaft.phi)/chord);
  // Integral of (R^2 - local roller radius^2)/2 across the swept sector.
  swept = height/2*((R^2-r^2)*angle - e^2/2*sin(2*shaft.phi)
      - e*sin(shaft.phi)*chord - r^2*asin(e*sin(shaft.phi)/r));
  dV_dAngle = height/2*(R^2 - radiusAtVane^2);
  a.V = clearanceRatio*displacement + (if fillingA then swept else displacement-swept);
  b.V = (1+2*clearanceRatio)*displacement - a.V;
  dVA_dAngle = if fillingA then dV_dAngle else -dV_dAngle;
  volumeRateA = dVA_dAngle*der(shaft.phi);
  shaft.tau = -(a.effort-b.effort)*dVA_dAngle - follower.f*dx_dAngle;
  annotation(Icon(graphics={
    Ellipse(extent={{-69,68},{69,-68}},lineColor={48,76,90},lineThickness=1),
    Ellipse(extent={{-38,52},{66,-52}},lineColor={48,76,90},fillColor={169,195,209},fillPattern=FillPattern.Solid,lineThickness=1),
    Ellipse(extent={{1,13},{27,-13}},lineColor={48,76,90},fillColor={248,250,251},fillPattern=FillPattern.Solid),
    Text(extent={{-145,-73},{145,-101}},textString="%name",textColor={31,61,76})}));
end Roller;
