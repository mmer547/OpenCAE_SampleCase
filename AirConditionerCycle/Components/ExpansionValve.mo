within AirConditionerCycle.Components;
model ExpansionValve "蒸発器液位で開度を調整する等エンタルピー膨張弁"
  extends Interfaces.PartialTwoPort;
  parameter Modelica.Units.SI.Area Amax(min=1e-12)=1.5e-6 "全開時の流路面積";
  parameter Real Cd(min=0.01, max=1)=0.72 "流量係数";
  parameter Real levelSet(min=0, max=1)=0.20 "蒸発器の目標液体体積率";
  parameter Real bias(min=0, max=1)=0.5 "目標液位での開度";
  parameter Real gain(min=0)=4 "液位偏差に対する比例ゲイン";
  Modelica.Blocks.Interfaces.RealInput level(unit="1") "蒸発器の液体体積率"
    annotation(Placement(transformation(origin={0,100}, extent={{-10,-10},{10,10}}, rotation=-90)));
  Real opening(unit="1", min=0, max=1) "弁開度";
  Modelica.Units.SI.PressureDifference dp "弁の圧力降下";
equation
  inlet.m_flow + outlet.m_flow = 0;
  opening = min(1, max(0, bias + gain*(levelSet - level)));
  m_flow = Cd*Amax*opening*sqrt(2*Medium.density_ph(inlet.p, h_in)*max(dp, 0));
  dp = inlet.p - outlet.p;
  outlet.h_outflow = h_in;
  assert(noEvent(dp > 0), "The expansion valve requires a positive pressure drop.");
  annotation(defaultComponentName="valve",
    Icon(coordinateSystem(preserveAspectRatio=true), graphics={
      Line(points={{-100,0},{-56,0}}, color={36,63,83}, thickness=1.3),
      Line(points={{56,0},{100,0}}, color={36,63,83}, thickness=1.3),
      Polygon(points={{-58,37},{58,-37},{58,37},{-58,-37},{-58,37}},
        lineColor={36,63,83}, fillColor={204,218,226}, fillPattern=FillPattern.Solid, lineThickness=1),
      Line(points={{0,0},{0,51}}, color={36,63,83}, thickness=1.3),
      Ellipse(extent={{-20,68},{20,47}}, lineColor={36,63,83},
        fillColor={84,130,156}, fillPattern=FillPattern.Solid),
      Text(extent={{-145,-57},{145,-87}}, textString="%name", textColor={28,51,67})}));
end ExpansionValve;
