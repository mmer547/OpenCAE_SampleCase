within AirConditionerCycle.Components.Scroll;
model PocketSet "外周吸入口、四室対、中央吐出室と隣接室間の漏れ"
  extends Interfaces.PartialTwoPort;
  import SI = Modelica.Units.SI;
  parameter SI.AbsolutePressure pLow_start=370000, pHigh_start=1175000;
  parameter SI.SpecificEnthalpy hLow_start=407200,hHigh_start=445000;
  parameter SI.Area suctionArea(min=1e-8)=0.00011, dischargeArea(min=1e-8)=0.000095 "流量係数を含む面積";
  parameter SI.Volume centralVolume(min=1e-7)=10e-6;
  parameter SI.Height wrapHeight(min=1e-5)=0.024;
  Rotary.BaseClasses.VolumePort chamber[4] annotation(Placement(transformation(extent={{-70,-106},{-50,-86}})));
  Modelica.Blocks.Interfaces.RealInput volumeRate[4](each unit="m3/s") annotation(Placement(transformation(extent={{-12,-106},{8,-86}},rotation=0)));
  Modelica.Blocks.Interfaces.IntegerInput stage[4] annotation(Placement(transformation(extent={{50,-106},{70,-86}})));
  Modelica.Blocks.Interfaces.RealInput portOpening(unit="1") annotation(Placement(transformation(extent={{76,-74},{96,-54}})));
  Rotary.BaseClasses.GasPocket pocket[4](redeclare each final package Medium=Medium,
    p_start={pHigh_start,pLow_start,sqrt(pLow_start*pHigh_start),pHigh_start},
    h_start={hHigh_start,hLow_start,(hHigh_start+hLow_start)/2,hHigh_start},each Q_flow=0)
    annotation(Placement(transformation(extent={{-42,2},{-12,32}})));
  Rotary.BaseClasses.VolumeState center(redeclare final package Medium=Medium,p_start=pHigh_start,
    h_start=hHigh_start,V=centralVolume,dV=0,Q_flow=0,dm=sum(toCenter)+outlet.m_flow,
    H_flow=sum(centralH)+outlet.m_flow*center.h) annotation(Placement(transformation(extent={{24,2},{54,32}})));
  ClearancePath seal[4](each final wrapHeight=wrapHeight) annotation(Placement(transformation(extent={{-14,-58},{14,-30}})));
  SI.MassFlowRate fromSuction[4],toCenter[4] "中央向きを正、吐出口開口時の逆流を許容";
  SI.MassFlowRate tipLeakRate=sum(noEvent(abs(seal[i].tipFlow)) for i in 1:4);
  SI.MassFlowRate flankLeakRate=sum(noEvent(abs(seal[i].flankFlow)) for i in 1:4);
protected
  SI.Power centralH[4];
  final parameter Integer next[4]={2,3,4,1}, previous[4]={4,1,2,3};
equation
  outlet.p=center.p;
  outlet.h_outflow=center.h;
  m_flow=sum(fromSuction);
  for i in 1:4 loop
    connect(chamber[i],pocket[i].boundary);
    pocket[i].dV=volumeRate[i];
    fromSuction[i]=if stage[i]==1 then portOpening*suctionArea*noEvent(Rotary.BaseClasses.massFlux(inlet.p,pocket[i].p,
      Medium.density_ph(inlet.p,h_in))) else 0;
    toCenter[i]=if stage[i]==4 then portOpening*dischargeArea*noEvent(if pocket[i].p>=center.p then
      Rotary.BaseClasses.massFlux(pocket[i].p,center.p,pocket[i].rho) else
      -Rotary.BaseClasses.massFlux(center.p,pocket[i].p,center.rho)) else 0;
    centralH[i]=toCenter[i]*noEvent(if toCenter[i]>=0 then pocket[i].h else center.h);
    seal[i].active=stage[i]<4;
    seal[i].pA=pocket[i].p; seal[i].pB=pocket[next[i]].p;
    seal[i].rhoA=pocket[i].rho; seal[i].rhoB=pocket[next[i]].rho;
    seal[i].hA=pocket[i].h; seal[i].hB=pocket[next[i]].h;
    pocket[i].dm=fromSuction[i]-toCenter[i]+seal[previous[i]].m_flow-seal[i].m_flow;
    pocket[i].H_flow=fromSuction[i]*h_in-centralH[i]+seal[previous[i]].enthalpyFlow-seal[i].enthalpyFlow;
  end for;
  annotation(Icon(graphics={Ellipse(extent={{-72,68},{72,-68}},lineColor={31,74,87},fillColor={225,240,238},fillPattern=FillPattern.Solid),
    Line(points={{-62,0},{-56,30},{-31,47},{1,48},{30,30},{36,3},{23,-17},{-1,-21},{-16,-8},{-12,8},{2,11},{10,3}},smooth=Smooth.Bezier,color={26,104,119},thickness=2)}));
end PocketSet;
