within AirConditionerCycle.Components.Rotary;
model Shell "密閉高圧シェル。ガス容積・筐体熱容量・外気放熱"
  import SI = Modelica.Units.SI;
  extends BaseClasses.FixedVolume(V=0.00085, p_start=1164500, h_start=444000);
  parameter SI.HeatCapacity Cwall(min=1)=1100;
  parameter SI.ThermalConductance Ggas(min=0)=8;
  parameter SI.ThermalConductance Gambient(min=0)=1.8;
  parameter SI.Temperature Tambient=308.15;
  parameter SI.Temperature Twall_start=330.15;
  SI.Temperature Twall(start=Twall_start, fixed=true);
  SI.HeatFlowRate Q_ambient "筐体から外気への放熱（正）";
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a wall
    annotation(Placement(transformation(extent={{-10,-110},{10,-90}})));
equation
  inlet.p = gas.p;
  outlet.p = gas.p;
  outlet.h_outflow = gas.h;
  Q_gas = Ggas*(Twall - gas.T);
  Q_ambient = Gambient*(Twall - Tambient);
  wall.T = Twall;
  Cwall*der(Twall) = wall.Q_flow - Q_gas - Q_ambient;
  annotation(Icon(graphics={
    Rectangle(extent={{-35,51},{35,-51}}, radius=16, lineColor={132,77,50}, lineThickness=1),
    Line(points={{-24,0},{24,0}}, color={132,77,50}, thickness=1)}));
end Shell;
