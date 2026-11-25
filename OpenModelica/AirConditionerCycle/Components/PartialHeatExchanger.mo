within AirConditionerCycle.Components;
partial model PartialHeatExchanger "飽和二相の冷媒保有量と熱交換器の熱容量"
  extends Interfaces.PartialTwoPort;
  import SI = Modelica.Units.SI;
  parameter SI.Volume V(min=1e-8) "冷媒側の内容積";
  parameter SI.ThermalConductance G(min=1e-6) "空気から熱交換器への熱コンダクタンス";
  parameter SI.HeatCapacity C(min=1e-6) "飽和温度に追従する壁の熱容量";
  parameter SI.Temperature T_start "初期飽和温度";
  parameter Real fill_start(min=0.001, max=0.999) "初期液体体積率";
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a air "空気側の熱ポート"
    annotation(Placement(transformation(extent={{-10,90},{10,110}})));
  Medium.AbsolutePressure p(start=Medium.saturationPressure(T_start), fixed=true,
    stateSelect=StateSelect.prefer) "冷媒の飽和圧力";
  Medium.Temperature T_sat "飽和温度・壁温";
  SI.Mass mLiquid(start=0.2, nominal=0.25, stateSelect=StateSelect.prefer) "飽和液の質量";
  SI.Mass mVapour "飽和蒸気の質量";
  SI.Mass charge "熱交換器内の冷媒質量";
  SI.Energy U "冷媒内部エネルギーと壁の顕熱（壁の基準温度 0 °C）";
  Real liquidFraction(unit="1") "液体体積率";
protected
  Medium.SaturationProperties sat;
  Medium.Density rhoL;
  Medium.Density rhoV;
  Medium.SpecificEnthalpy hL;
  Medium.SpecificEnthalpy hV;
  SI.MassFlowRate dmV "飽和蒸気の質量変化率";
initial equation
  mLiquid = fill_start*V*rhoL;
equation
  inlet.p = p;
  outlet.p = p;
  sat = Medium.setSat_p(p);
  rhoL = Medium.bubbleDensity(sat);
  rhoV = Medium.dewDensity(sat);
  hL = Medium.bubbleEnthalpy(sat);
  hV = Medium.dewEnthalpy(sat);
  T_sat = Medium.saturationTemperature_sat(sat);
  liquidFraction = mLiquid/(V*rhoL);
  mVapour = V*(1 - liquidFraction)*rhoV;
  charge = mLiquid + mVapour;
  U = mLiquid*hL + mVapour*hV - p*V + C*(T_sat - 273.15);
  air.Q_flow = G*(air.T - T_sat);

  // Differentiate V = mLiquid/rhoL + mVapour/rhoV at constant volume.
  der(mLiquid)/rhoL + dmV/rhoV =
    (mLiquid*Medium.dBubbleDensity_dPressure(sat)/rhoL^2
     + mVapour*Medium.dDewDensity_dPressure(sat)/rhoV^2)*der(p);
  der(mLiquid) + dmV = inlet.m_flow + outlet.m_flow;
  // dU/dt = air heat + net enthalpy flow. The coefficients are saturation derivatives.
  hL*der(mLiquid) + hV*dmV +
    (mLiquid*Medium.dBubbleEnthalpy_dPressure(sat) + mVapour*Medium.dDewEnthalpy_dPressure(sat)
     - V + C*Medium.saturationTemperature_derp_sat(sat))*der(p) =
    air.Q_flow + inlet.m_flow*h_in + outlet.m_flow*outlet.h_outflow;
  assert(noEvent(liquidFraction > 0 and liquidFraction < 1),
    "Two-phase inventory exhausted. Check initial charge, airflow, valve sizing and operating range.");
  annotation(Icon(coordinateSystem(preserveAspectRatio=true), graphics={
    Rectangle(extent={{-74,43},{74,-43}}, radius=9, lineColor={60,85,102},
      fillColor={244,248,250}, fillPattern=FillPattern.Solid, lineThickness=0.8),
    Line(points={{-100,0},{-60,0},{-49,26},{-30,-26},{-10,26},{10,-26},{30,26},{49,-26},{60,0},{100,0}},
      color={48,78,96}, thickness=1.5),
    Text(extent={{-145,-54},{145,-84}}, textString="%name", textColor={28,51,67})}));
end PartialHeatExchanger;
