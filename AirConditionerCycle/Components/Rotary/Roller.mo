within AirConditionerCycle.Components.Rotary;
model Roller "偏心ローラの厳密な三日月断面積と圧力トルク"
  extends BaseClasses.PartialChamberGeometry;
  import SI = Modelica.Units.SI;
protected
  SI.Length chord "ベーン中心線上のローラ半弦";
  SI.Length radiusAtVane;
  SI.Length dx_dAngle;
equation
  chord = sqrt(r^2 - (e*sin(shaft.phi))^2);
  radiusAtVane = e*cos(shaft.phi) + chord;
  follower.s = R - radiusAtVane;
  dx_dAngle = e*sin(shaft.phi)*(1 + e*cos(shaft.phi)/chord);
  // Integral of (R^2 - local roller radius^2)/2 across the swept sector.
  swept = height/2*((R^2-r^2)*angle - e^2/2*sin(2*shaft.phi)
      - e*sin(shaft.phi)*chord - r^2*asin(e*sin(shaft.phi)/r));
  dV_dAngle = height/2*(R^2 - radiusAtVane^2);
  shaft.tau = -(a.effort-b.effort)*dVA_dAngle - follower.f*dx_dAngle;
  annotation(Icon(graphics={
    Ellipse(extent={{-69,68},{69,-68}},lineColor={48,76,90},lineThickness=1),
    Ellipse(extent={{-38,52},{66,-52}},lineColor={48,76,90},fillColor={169,195,209},fillPattern=FillPattern.Solid,lineThickness=1),
    Ellipse(extent={{1,13},{27,-13}},lineColor={48,76,90},fillColor={248,250,251},fillPattern=FillPattern.Solid),
    Text(extent={{-145,-73},{145,-101}},textString="%name",textColor={31,61,76})}));
end Roller;
