within AirConditionerCycle.Components.Rotary;
model Vane "ばね押付けベーン。往復質量・摺動摩擦・先端漏れ面積"
  extends BaseClasses.VaneMechanics;
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_b heat
    annotation(Placement(transformation(extent={{-10,-110},{10,-90}})));
equation
  heat.Q_flow = -friction*v;
end Vane;
