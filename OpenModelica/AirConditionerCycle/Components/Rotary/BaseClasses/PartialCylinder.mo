within AirConditionerCycle.Components.Rotary.BaseClasses;
partial model PartialCylinder "二つの作動室・吸入・漏れの質量とエンタルピー輸送"
  extends AirConditionerCycle.Interfaces.PartialTwoPort;
  import SI = Modelica.Units.SI;
  parameter SI.Area suctionArea(min=1e-8)=0.000095 "流量係数を含む吸入口面積";
  parameter BaseClasses.CylinderClearances clearances "追加の漏れ通路。すきまゼロで閉鎖";
  parameter SI.Length axialHeight(min=1e-6)=0.0455;
  parameter SI.Radius boreRadius(min=1e-5)=0.024;
  parameter SI.Length eccentricity(min=1e-6)=0.0045;
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
  Modelica.Blocks.Interfaces.RealInput volumeRateA(unit="m3/s")
    annotation(Placement(transformation(origin={75,-45},extent={{-9,-9},{9,9}},rotation=180)));
  Medium.AbsolutePressure pSuction;
  SI.MassFlowRate vaneTipLeakAB "ベーン先端。A→Bが正";
  SI.MassFlowRate radialLeakAB "ローラ外周から内壁までの半径すきま";
  SI.MassFlowRate topFaceLeakAB "上端面すきま";
  SI.MassFlowRate bottomFaceLeakAB "下端面すきま";
  SI.MassFlowRate leakAB "全経路の正味室間流量。A→Bが正";
protected
  SI.MassFlowRate dmPortA;
  SI.MassFlowRate dmPortB;
  SI.Power HLeakAB;
  final parameter SI.Length radialLength=3*Modelica.Constants.pi/8*
    sqrt(2*(boreRadius-eccentricity)*boreRadius/eccentricity*clearances.radialGap)
    "局所放物線すきまの等価長さ";
  Real nozzleFlux(unit="kg/(m2.s)") "A→Bが正";
  SI.PressureDifference dpAB;
  SI.Density meanGapDensity;
  SI.DynamicViscosity gapViscosity;
initial equation
  assert(boreRadius > eccentricity, "Cylinder bore radius must exceed eccentricity.");
equation
  connect(a,pocketA.boundary) annotation(Line(points={{-45,-100},{-45,-22}},color={113,76,151}));
  connect(b,pocketB.boundary) annotation(Line(points={{45,-100},{45,-22}},color={113,76,151}));
  pocketA.dV = volumeRateA;
  pocketB.dV = -volumeRateA;
  pSuction = if fillingA then pocketA.p else pocketB.p;
  m_flow = suctionArea*noEvent(BaseClasses.massFlux(inlet.p,pSuction,Medium.density_ph(inlet.p,h_in)));
  outlet.p = if fillingA then pocketB.p else pocketA.p;
  outlet.h_outflow = if fillingA then pocketB.h else pocketA.h;
  dpAB = pocketA.p - pocketB.p;
  nozzleFlux = noEvent(if dpAB >= 0 then
    BaseClasses.massFlux(pocketA.p,pocketB.p,pocketA.rho) else
    -BaseClasses.massFlux(pocketB.p,pocketA.p,pocketB.rho));
  vaneTipLeakAB = leakArea*nozzleFlux;
  if max(clearances.radialGap,max(clearances.topGap,clearances.bottomGap)) > 0 then
    meanGapDensity = noEvent(if dpAB >= 0 then pocketA.rho*(1+pocketB.p/pocketA.p)/2
      else pocketB.rho*(1+pocketA.p/pocketB.p)/2);
    gapViscosity = noEvent(if dpAB >= 0 then Medium.dynamicViscosity(pocketA.state)
      else Medium.dynamicViscosity(pocketB.state));
  else
    meanGapDensity = 0;
    gapViscosity = 0;
  end if;
  radialLeakAB = noEvent(BaseClasses.slitLeakFlow(clearances.radialGap,axialHeight,radialLength,
    dpAB,meanGapDensity,gapViscosity,nozzleFlux));
  topFaceLeakAB = noEvent(BaseClasses.slitLeakFlow(clearances.topGap,clearances.faceWidth,clearances.faceLength,
    dpAB,meanGapDensity,gapViscosity,nozzleFlux));
  bottomFaceLeakAB = noEvent(BaseClasses.slitLeakFlow(clearances.bottomGap,clearances.faceWidth,clearances.faceLength,
    dpAB,meanGapDensity,gapViscosity,nozzleFlux));
  leakAB = vaneTipLeakAB + radialLeakAB + topFaceLeakAB + bottomFaceLeakAB;
  HLeakAB = leakAB*noEvent(if leakAB >= 0 then pocketA.h else pocketB.h);
  dmPortA = if fillingA then m_flow else outlet.m_flow;
  dmPortB = if fillingA then outlet.m_flow else m_flow;
  pocketA.dm = dmPortA - leakAB;
  pocketB.dm = dmPortB + leakAB;
  pocketA.H_flow = dmPortA*(if fillingA then h_in else pocketA.h) - HLeakAB;
  pocketB.H_flow = dmPortB*(if fillingA then pocketB.h else h_in) + HLeakAB;
  annotation(Icon(graphics={
    Ellipse(extent={{-72,72},{72,-72}},lineColor={48,76,90},fillColor={215,232,239},fillPattern=FillPattern.Solid,lineThickness=1.5),
    Ellipse(extent={{-41,53},{69,-53}},lineColor={48,76,90},fillColor={163,187,202},fillPattern=FillPattern.Solid),
    Line(points={{-70,0},{-38,0}},color={149,91,57},thickness=2.5),
    Text(extent={{-145,118},{145,90}},textString="%name",textColor={31,61,76})}));
end PartialCylinder;
