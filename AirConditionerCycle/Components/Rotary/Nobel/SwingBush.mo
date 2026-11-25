within AirConditionerCycle.Components.Rotary.Nobel;
model SwingBush "ブレードの相対摺動とブッシュの揺動抵抗"
  extends BaseClasses.PartialBladeGuide;
  import SI = Modelica.Units.SI;
  parameter SI.Force slidingFriction(min=0)=3 "ブレードとブッシュ間の等価摩擦力";
  parameter SI.TranslationalDampingConstant damping(min=0)=1.6;
  parameter SI.Torque pivotFriction(min=0)=0.015 "ブッシュ外周の等価摩擦トルク";
  parameter SI.RotationalDampingConstant pivotDamping(min=0)=0.0001;
  parameter SI.Inertia J(min=0)=0.000025 "一体ピストンの自転とブッシュの揺動の合成慣性";
  Modelica.Mechanics.Rotational.Interfaces.Flange_a pivot
    annotation(Placement(transformation(extent={{39,90},{59,110}})));
  SI.AngularVelocity w "ブッシュの揺動角速度";
  SI.Torque resistingTorque;
  SI.Power slideLoss, pivotLoss;
equation
  v = der(tip.s);
  w = der(pivot.phi);
  friction = damping*v + slidingFriction*tanh(v/0.02);
  resistingTorque = pivotDamping*w + pivotFriction*tanh(w/1.0);
  tip.f = friction;
  pivot.tau = J*der(w) + resistingTorque;
  slideLoss = friction*v;
  pivotLoss = resistingTorque*w;
  frictionPower = slideLoss + pivotLoss;
  E = J*w^2/2;
  leakArea = 0 "ローラとブレードが一体のため先端通路なし";
  annotation(Icon(graphics={
    Ellipse(extent={{-58,62},{58,-54}},lineColor={48,76,90},fillColor={207,179,122},fillPattern=FillPattern.Solid,lineThickness=1),
    Polygon(points={{-78,-11},{74,34},{78,20},{-74,-25},{-78,-11}},lineColor={48,76,90},fillColor={156,191,204},fillPattern=FillPattern.Solid),
    Text(extent={{-110,-64},{110,-92}},textString="%name",textColor={31,61,76})}));
end SwingBush;
