within AirConditionerCycle.Components;
model Condenser "凝縮器（出口過冷却度指定）"
  extends PartialHeatExchanger(V=0.0012, fill_start=0.45, G=365, C=14000, T_start=318.15);
  parameter Modelica.Units.SI.TemperatureDifference subcooling(min=0.05)=5
    "飽和温度から出口液温までの温度差";
equation
  outlet.h_outflow = Medium.specificEnthalpy_pT(outlet.p, T_sat - subcooling);
  annotation(defaultComponentName="condenser",
    Icon(graphics={
      Line(points={{-31,48},{-31,84}}, color={191,70,38}, thickness=1.3, arrow={Arrow.None,Arrow.Filled}),
      Line(points={{31,48},{31,84}}, color={191,70,38}, thickness=1.3, arrow={Arrow.None,Arrow.Filled})}));
end Condenser;
