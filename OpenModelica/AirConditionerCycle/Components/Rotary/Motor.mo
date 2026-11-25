within AirConditionerCycle.Components.Rotary;
model Motor "回転子慣性とPI速度制御を持つ電動機"
  import SI = Modelica.Units.SI;
  extends BaseClasses.PartialMotor;
  parameter SI.Resistance phaseResistance20(min=0)=0.32 "20 °C における一相当たり抵抗";
  parameter Real resistanceCoefficient(unit="1/K",min=0)=0.00393;
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_b heat
    annotation(Placement(transformation(extent={{-10,-110},{10,-90}})));
equation
  phaseResistance = phaseResistance20*(1 + resistanceCoefficient*(heat.T-293.15));
  heat.Q_flow = driveTorque*w - P_el;
end Motor;
