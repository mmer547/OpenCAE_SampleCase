within AirConditionerCycle.Components.Rotary.Nobel;
model PistonBlade "一体ローラ・ブレードの幾何と軸トルク"
  extends BaseClasses.PartialChamberGeometry;
  import SI = Modelica.Units.SI;
  parameter SI.Length pivotOffset(min=0)=0.003 "シリンダ内壁から固定ブッシュ中心までの距離";
  final parameter SI.Length B=R+pivotOffset "シリンダ中心からブッシュ中心までの距離";
  Modelica.Mechanics.Rotational.Interfaces.Flange_b pivot
    annotation(Placement(transformation(extent={{39,-110},{59,-90}})));
  SI.Angle beta "ブレード中心線の揺動角";
  SI.Length distanceToPivot "ローラ中心からブッシュ中心まで";
protected
  SI.Length q "ローラ中心位置とブレード単位方向の外積";
  SI.Length chord "ブレード方向へのシリンダ交点の投影長";
  SI.Length bladeRadius "ローラ中心からブレードとシリンダ内壁の交点まで";
  Real dBeta "揺動角の軸角微分";
  SI.Length dDistance, dq, dBladeRadius "それぞれの長さの軸角微分";
equation
  distanceToPivot = sqrt((B-e*cos(shaft.phi))^2+(e*sin(shaft.phi))^2);
  beta = Modelica.Math.atan2(-e*sin(shaft.phi), B-e*cos(shaft.phi));
  pivot.phi = beta;
  follower.s = distanceToPivot - (B-e);
  q = B*sin(beta);
  chord = sqrt(R^2-q^2);
  bladeRadius = chord-B*cos(beta)+distanceToPivot;
  dDistance = B*e*sin(shaft.phi)/distanceToPivot;
  dBeta = (e^2-B*e*cos(shaft.phi))/distanceToPivot^2;
  dq = B*cos(beta)*dBeta;
  dBladeRadius = -q*dq/chord + B*sin(beta)*dBeta + dDistance;
  // Oriented area bounded by the bore arc, roller arc and zero-thickness blade.
  swept = height/2*((R^2-r^2)*(angle-beta) + R^2*asin(q/R) + bladeRadius*q);
  dV_dAngle = height/2*((R^2-r^2)*(1-dBeta) + R^2*dq/chord + dBladeRadius*q + bladeRadius*dq);
  shaft.tau = -(a.effort-b.effort)*dVA_dAngle - follower.f*dDistance - pivot.tau*dBeta;
  annotation(Icon(graphics={
    Ellipse(extent={{-76,69},{63,-70}},lineColor={48,76,90},lineThickness=1),
    Ellipse(extent={{-60,58},{44,-46}},lineColor={48,76,90},fillColor={151,189,203},fillPattern=FillPattern.Solid),
    Polygon(points={{33,32},{82,12},{87,23},{38,43},{33,32}},lineColor={48,76,90},fillColor={151,189,203},fillPattern=FillPattern.Solid),
    Ellipse(extent={{-22,21},{6,-7}},lineColor={48,76,90},fillColor={248,250,251},fillPattern=FillPattern.Solid),
    Text(extent={{-98,-70},{98,-95}},textString="%name",textColor={31,61,76})}));
end PistonBlade;
