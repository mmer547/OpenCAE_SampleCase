within AirConditionerCycle.Interfaces;
partial model PartialCompressor "差し替え用の圧縮機インターフェース"
  extends PartialTwoPort;
  output Modelica.Units.SI.Power P_el "圧縮機の消費電力（正）";
  annotation(Icon(coordinateSystem(preserveAspectRatio=true), graphics={
    Line(points={{-100,0},{-68,0}}, color={36,63,83}, thickness=1.3),
    Line(points={{68,0},{100,0}}, color={36,63,83}, thickness=1.3),
    Ellipse(extent={{-69,69},{69,-69}}, lineColor={36,63,83},
      fillColor={228,239,245}, fillPattern=FillPattern.Solid, lineThickness=1.3),
    Polygon(points={{-47,-47},{-47,47},{51,18},{51,-18},{-47,-47}},
      lineColor={36,63,83}, fillColor={84,130,156}, fillPattern=FillPattern.Solid),
    Text(extent={{-145,-74},{145,-100}}, textString="%name", textColor={28,51,67})}),
    Documentation(info="<html><p>圧縮機の質量収支、流量特性、吐出エンタルピー outlet.h_outflow、消費電力 P_el を実装します。入口・出口圧力は熱交換器から与えられます。内部に冷媒を蓄える詳細モデルは独自の質量収支を持てます。</p></html>"));
end PartialCompressor;
