within AirConditionerCycle.Components.Rotary;
model EccentricShaft "偏心軸。軸受摩擦トルクと発熱"
  extends BaseClasses.ShaftMechanics;
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_b heat
    annotation(Placement(transformation(extent={{-10,-110},{10,-90}})));
equation
  heat.Q_flow = -frictionTorque*w;
end EccentricShaft;
