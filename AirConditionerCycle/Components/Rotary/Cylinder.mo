within AirConditionerCycle.Components.Rotary;
model Cylinder "交互に吸入・圧縮する二つの作動室と吸入ポート・内部漏れ"
  import SI = Modelica.Units.SI;
  extends BaseClasses.PartialCylinder;
  parameter SI.ThermalConductance Gwall(min=0)=0.45 "各室と筐体の熱コンダクタンス";
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a wall
    annotation(Placement(transformation(extent={{-10,90},{10,110}})));
equation
  pocketA.Q_flow = Gwall*(wall.T - pocketA.T);
  pocketB.Q_flow = Gwall*(wall.T - pocketB.T);
  wall.Q_flow = pocketA.Q_flow + pocketB.Q_flow;
end Cylinder;
