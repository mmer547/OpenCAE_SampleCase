within AirConditionerCycle;
model CoolingCycle "冷房用の蒸気圧縮冷凍サイクル"
  import SI = Modelica.Units.SI;
  replaceable package Medium = Media.R134a
    constrainedby Modelica.Media.Interfaces.PartialTwoPhaseMedium
    annotation(choicesAllMatching=true);
  replaceable model Compressor = Components.DisplacementCompressor
    constrainedby Interfaces.PartialCompressor "差し替え可能な圧縮機モデル"
    annotation(choicesAllMatching=true);
  Compressor compressor(redeclare final package Medium = Medium)
    annotation(Placement(transformation(origin={-46,40}, extent={{-16,-16},{16,16}})));
  Components.Condenser condenser(redeclare final package Medium = Medium)
    annotation(Placement(transformation(origin={46,40}, extent={{-18,-18},{18,18}})));
  Components.ExpansionValve valve(redeclare final package Medium = Medium)
    annotation(Placement(transformation(origin={46,-40}, extent={{-16,-16},{16,16}}, rotation=180)));
  Components.Evaporator evaporator(redeclare final package Medium = Medium)
    annotation(Placement(transformation(origin={-46,-40}, extent={{-18,-18},{18,18}}, rotation=180)));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a roomAir
    annotation(Placement(transformation(extent={{-56,-106},{-36,-86}}),
      iconTransformation(extent={{-110,-10},{-90,10}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a outdoorAir
    annotation(Placement(transformation(extent={{36,86},{56,106}}),
      iconTransformation(extent={{90,-10},{110,10}})));
  output SI.HeatFlowRate Q_cooling "室内空気から取り去る熱量率";
  output SI.HeatFlowRate Q_rejected "室外空気へ放出する熱量率";
  output SI.Power P_el "圧縮機消費電力";
  output Real COP(unit="1") "空気側冷房能力 / 圧縮機消費電力（消費電力がゼロのときは0）";
  output SI.AbsolutePressure pLow "低圧側の絶対圧力";
  output SI.AbsolutePressure pHigh "高圧側の絶対圧力";
  output Medium.Temperature T1 "圧縮機入口";
  output Medium.Temperature T2 "圧縮機出口";
  output Medium.Temperature T3 "凝縮器出口";
  output Medium.Temperature T4 "膨張弁出口";
  output Medium.SpecificEnthalpy h1 "圧縮機入口";
  output Medium.SpecificEnthalpy h2 "圧縮機出口";
  output Medium.SpecificEnthalpy h3 "凝縮器出口";
  output Medium.SpecificEnthalpy h4 "膨張弁出口";
  output Real x4(unit="1") "膨張弁出口の冷媒乾き度";
protected
  Medium.ThermodynamicState valveExit;
equation
  connect(compressor.outlet, condenser.inlet) annotation(Line(
    points={{-30,40},{28,40}}, color={181,70,43}, thickness=0.8));
  connect(condenser.outlet, valve.inlet) annotation(Line(
    points={{64,40},{79,40},{79,-40},{62,-40}}, color={181,70,43}, thickness=0.8));
  connect(valve.outlet, evaporator.inlet) annotation(Line(
    points={{30,-40},{-28,-40}}, color={18,114,166}, thickness=0.8));
  connect(evaporator.outlet, compressor.inlet) annotation(Line(
    points={{-64,-40},{-79,-40},{-79,40},{-62,40}}, color={18,114,166}, thickness=0.8));
  connect(evaporator.level, valve.level) annotation(Line(
    points={{-34.12,-51.16},{-34.12,-67},{46,-67},{46,-56}}, color={0,0,127}, pattern=LinePattern.Dash));
  connect(evaporator.air, roomAir) annotation(Line(
    points={{-46,-58},{-46,-96}}, color={164,45,45}));
  connect(condenser.air, outdoorAir) annotation(Line(
    points={{46,58},{46,96}}, color={164,45,45}));

  Q_cooling = roomAir.Q_flow;
  Q_rejected = -outdoorAir.Q_flow;
  P_el = compressor.P_el;
  COP = if noEvent(P_el > 0) then Q_cooling/P_el else 0;
  pLow = compressor.inlet.p;
  pHigh = compressor.outlet.p;
  h1 = compressor.h_in;
  h2 = compressor.outlet.h_outflow;
  h3 = condenser.outlet.h_outflow;
  h4 = valve.outlet.h_outflow;
  T1 = Medium.temperature_ph(pLow, h1);
  T2 = Medium.temperature_ph(pHigh, h2);
  T3 = Medium.temperature_ph(pHigh, h3);
  valveExit = Medium.setState_ph(pLow, h4);
  T4 = Medium.temperature(valveExit);
  x4 = Medium.vapourQuality(valveExit);
  annotation(defaultComponentName="cycle",
    Icon(coordinateSystem(preserveAspectRatio=true), graphics={
      Rectangle(extent={{-92,70},{92,-70}}, radius=13, lineColor={45,68,85},
        fillColor={243,248,250}, fillPattern=FillPattern.Solid, lineThickness=1),
      Line(points={{-54,0},{-54,36},{52,36},{52,2}}, color={188,78,46},
        thickness=2, arrow={Arrow.None,Arrow.Filled}),
      Line(points={{52,-5},{52,-36},{-54,-36},{-54,-5}}, color={20,115,172},
        thickness=2, arrow={Arrow.None,Arrow.Filled}),
      Ellipse(extent={{-15,50},{15,22}}, lineColor={45,68,85},
        fillColor={206,223,233}, fillPattern=FillPattern.Solid),
      Polygon(points={{-8,44},{9,39},{9,33},{-8,28},{-8,44}}, lineColor={45,68,85},
        fillColor={84,130,156}, fillPattern=FillPattern.Solid),
      Text(extent={{-140,-74},{140,-100}}, textString="%name", textColor={28,51,67})}),
    Diagram(coordinateSystem(preserveAspectRatio=true), graphics={
      Text(extent={{-24,55},{24,44}}, textString="2", textColor={151,64,43}),
      Text(extent={{81,6},{95,-6}}, textString="3", textColor={151,64,43}),
      Text(extent={{-24,-44},{24,-55}}, textString="4", textColor={14,102,145}),
      Text(extent={{-95,6},{-81,-6}}, textString="1", textColor={14,102,145})}),
    Documentation(info="<html><p>Cooling mode with unidirectional flow. Heat ports connect to indoor and outdoor air temperature boundaries. COP uses indoor-air cooling and compressor electrical input. State points 1, 2, 3 and 4 follow refrigerant flow from compressor suction. The compressor type can be redeclared independently of the refrigerant connections.</p></html>"));
end CoolingCycle;
