within AirConditionerCycle.Components.Scroll;
model ClearancePath "隣接室間のラップ歯先すきま・側面すきまの等価オリフィス"
  import SI = Modelica.Units.SI;
  parameter SI.Length tipGap(min=0)=4e-6;
  parameter SI.Length flankGap(min=0)=5e-6;
  parameter SI.Length tipLength(min=0)=0.055 "対称二室を合計した有効シール線長";
  parameter SI.Height wrapHeight(min=1e-5)=0.024;
  parameter Integer flankCount(min=1)=2 "対称二室の有効側面通路数";
  parameter Real tipCd(min=0,max=1)=0.45, flankCd(min=0,max=1)=0.55;
  input Boolean active;
  input SI.AbsolutePressure pA,pB;
  input SI.Density rhoA,rhoB;
  input SI.SpecificEnthalpy hA,hB;
  SI.MassFlowRate tipFlow,flankFlow,m_flow "A→B が正";
  SI.Power enthalpyFlow;
protected
  Real flux(unit="kg/(m2.s)");
equation
  flux=if not active then 0 else noEvent(if pA>=pB then Rotary.BaseClasses.massFlux(pA,pB,rhoA)
    else -Rotary.BaseClasses.massFlux(pB,pA,rhoB));
  tipFlow=tipCd*tipLength*tipGap*flux;
  flankFlow=flankCd*flankCount*wrapHeight*flankGap*flux;
  m_flow=tipFlow+flankFlow;
  enthalpyFlow=m_flow*noEvent(if m_flow>=0 then hA else hB);
  annotation(Icon(graphics={Rectangle(extent={{-75,56},{75,-56}},lineColor={74,99,107},fillColor={225,236,239},fillPattern=FillPattern.Solid),
    Line(points={{-60,-20},{2,-20},{2,18},{60,18}},color={29,118,140},thickness=2,arrow={Arrow.None,Arrow.Filled})}));
end ClearancePath;
