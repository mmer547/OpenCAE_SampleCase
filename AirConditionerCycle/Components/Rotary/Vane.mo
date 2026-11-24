within AirConditionerCycle.Components.Rotary;
model Vane "ばね押付けベーン。往復質量・摺動摩擦・先端漏れ面積"
  import SI = Modelica.Units.SI;
  parameter SI.Mass mass(min=1e-5)=0.009;
  parameter SI.TranslationalSpringConstant k(min=1)=1600;
  parameter SI.Length freeExtension=0.016 "ばね自然長に対応する伸び位置";
  parameter SI.TranslationalDampingConstant damping(min=0)=1.6;
  parameter SI.Force slidingFriction(min=0)=3;
  parameter SI.Length height(min=1e-4)=0.0455;
  parameter SI.Length tipGap(min=0)=3e-6 "有効先端すきま";
  Modelica.Mechanics.Translational.Interfaces.Flange_a tip
    annotation(Placement(transformation(extent={{-10,90},{10,110}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_b heat
    annotation(Placement(transformation(extent={{-10,-110},{10,-90}})));
  Modelica.Blocks.Interfaces.RealOutput leakArea(unit="m2")
    annotation(Placement(transformation(extent={{90,30},{110,50}})));
  SI.Velocity v;
  SI.Force friction;
  SI.Energy E "ベーンの運動・ばねエネルギー";
equation
  v = der(tip.s);
  friction = damping*v + slidingFriction*tanh(v/0.02);
  tip.f = mass*der(v) + k*(tip.s-freeExtension) + friction;
  E = mass*v^2/2 + k*(tip.s-freeExtension)^2/2;
  heat.Q_flow = -friction*v;
  leakArea = height*tipGap;
  annotation(Icon(graphics={
    Rectangle(extent={{-15,76},{15,-12}},lineColor={48,76,90},fillColor={166,192,204},fillPattern=FillPattern.Solid,lineThickness=1),
    Line(points={{0,-12},{-17,-21},{17,-30},{-17,-39},{17,-48},{0,-57},{0,-67}},color={48,76,90},thickness=1.3),
    Text(extent={{-145,-71},{145,-101}},textString="%name",textColor={31,61,76})}));
end Vane;
