within AirConditionerCycle.Components.Rotary;
model Cylinder "交互に吸入・圧縮する二つの作動室と吸入ポート・内部漏れ"
  extends AirConditionerCycle.Interfaces.PartialTwoPort;
  import SI = Modelica.Units.SI;
  parameter SI.Area suctionArea(min=1e-8)=0.000095 "流量係数を含む吸入口面積";
  parameter SI.ThermalConductance Gwall(min=0)=0.45 "各室と筐体の熱コンダクタンス";
  BaseClasses.GasPocket pocketA(redeclare final package Medium=Medium,
    p_start=1175000,h_start=445000)
    annotation(Placement(transformation(origin={-45,0},extent={{-22,-22},{22,22}})));
  BaseClasses.GasPocket pocketB(redeclare final package Medium=Medium,
    p_start=370000,h_start=407200)
    annotation(Placement(transformation(origin={45,0},extent={{-22,-22},{22,22}})));
  BaseClasses.VolumePort a annotation(Placement(transformation(extent={{-55,-110},{-35,-90}})));
  BaseClasses.VolumePort b annotation(Placement(transformation(extent={{35,-110},{55,-90}})));
  Modelica.Blocks.Interfaces.BooleanInput fillingA
    annotation(Placement(transformation(origin={-76,-80},extent={{-9,-9},{9,9}}, rotation=90)));
  Modelica.Blocks.Interfaces.RealInput leakArea(unit="m2")
    annotation(Placement(transformation(origin={76,-80},extent={{-9,-9},{9,9}}, rotation=90)));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a wall
    annotation(Placement(transformation(extent={{-10,90},{10,110}})));
  Modelica.Blocks.Interfaces.RealInput volumeRateA(unit="m3/s")
    annotation(Placement(transformation(origin={75,-45},extent={{-9,-9},{9,9}},rotation=180)));
  Medium.AbsolutePressure pSuction;
  SI.MassFlowRate leakAB "正で室Aから室Bへ";
protected
  SI.MassFlowRate dmPortA;
  SI.MassFlowRate dmPortB;
  SI.Power HLeakAB;
equation
  connect(a,pocketA.boundary) annotation(Line(points={{-45,-100},{-45,-22}},color={113,76,151}));
  connect(b,pocketB.boundary) annotation(Line(points={{45,-100},{45,-22}},color={113,76,151}));
  pocketA.dV = volumeRateA;
  pocketB.dV = -volumeRateA;
  pSuction = if fillingA then pocketA.p else pocketB.p;
  m_flow = suctionArea*noEvent(BaseClasses.massFlux(inlet.p,pSuction,Medium.density_ph(inlet.p,h_in)));
  outlet.p = if fillingA then pocketB.p else pocketA.p;
  outlet.h_outflow = if fillingA then pocketB.h else pocketA.h;
  leakAB = leakArea*noEvent(if pocketA.p >= pocketB.p then
    BaseClasses.massFlux(pocketA.p,pocketB.p,pocketA.rho) else
    -BaseClasses.massFlux(pocketB.p,pocketA.p,pocketB.rho));
  HLeakAB = leakAB*noEvent(if leakAB >= 0 then pocketA.h else pocketB.h);
  dmPortA = if fillingA then m_flow else outlet.m_flow;
  dmPortB = if fillingA then outlet.m_flow else m_flow;
  pocketA.dm = dmPortA - leakAB;
  pocketB.dm = dmPortB + leakAB;
  pocketA.H_flow = dmPortA*(if fillingA then h_in else pocketA.h) - HLeakAB;
  pocketB.H_flow = dmPortB*(if fillingA then pocketB.h else h_in) + HLeakAB;
  pocketA.Q_flow = Gwall*(wall.T - pocketA.T);
  pocketB.Q_flow = Gwall*(wall.T - pocketB.T);
  wall.Q_flow = pocketA.Q_flow + pocketB.Q_flow;
  annotation(Icon(graphics={
    Ellipse(extent={{-72,72},{72,-72}},lineColor={48,76,90},fillColor={215,232,239},fillPattern=FillPattern.Solid,lineThickness=1.5),
    Ellipse(extent={{-41,53},{69,-53}},lineColor={48,76,90},fillColor={163,187,202},fillPattern=FillPattern.Solid),
    Line(points={{-70,0},{-38,0}},color={149,91,57},thickness=2.5),
    Text(extent={{-145,118},{145,90}},textString="%name",textColor={31,61,76})}));
end Cylinder;
