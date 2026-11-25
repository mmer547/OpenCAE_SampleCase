within AirConditionerCycle.Components;
model Evaporator "蒸発器（出口過熱度指定）"
  extends PartialHeatExchanger(V=0.0015, fill_start=0.20, G=165, C=9500, T_start=280.15);
  parameter Modelica.Units.SI.TemperatureDifference superheat(min=0.05)=5
    "出口蒸気温度と飽和温度の差";
  Modelica.Blocks.Interfaces.RealOutput level(unit="1") "膨張弁に送る液体体積率"
    annotation(Placement(transformation(origin={-66,62}, extent={{-8,-8},{8,8}}, rotation=90)));
equation
  level = liquidFraction;
  outlet.h_outflow = Medium.specificEnthalpy_pT(outlet.p, T_sat + superheat);
  annotation(defaultComponentName="evaporator",
    Icon(graphics={
      Line(points={{-31,84},{-31,48}}, color={12,119,173}, thickness=1.3, arrow={Arrow.None,Arrow.Filled}),
      Line(points={{31,84},{31,48}}, color={12,119,173}, thickness=1.3, arrow={Arrow.None,Arrow.Filled})}));
end Evaporator;
