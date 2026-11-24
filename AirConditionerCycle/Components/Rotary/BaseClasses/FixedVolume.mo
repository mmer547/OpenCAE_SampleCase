within AirConditionerCycle.Components.Rotary.BaseClasses;
partial model FixedVolume "均一圧力の固定容積"
  extends AirConditionerCycle.Interfaces.PartialTwoPort;
  import SI = Modelica.Units.SI;
  parameter SI.Volume V(min=1e-8);
  parameter Medium.AbsolutePressure p_start;
  parameter Medium.SpecificEnthalpy h_start;
  SI.HeatFlowRate Q_gas "壁から冷媒への入熱";
  VolumeState gas(redeclare final package Medium=Medium, V=V, dV=0,
    p_start=p_start, h_start=h_start, dm=inlet.m_flow + outlet.m_flow,
    H_flow=inlet.m_flow*h_in + outlet.m_flow*outlet.h_outflow, Q_flow=Q_gas);
  annotation(Icon(graphics={
    Line(points={{-100,0},{-47,0}}, color={44,72,88}, thickness=1.2),
    Line(points={{47,0},{100,0}}, color={44,72,88}, thickness=1.2),
    Rectangle(extent={{-50,65},{50,-65}}, radius=20, lineColor={44,72,88},
      fillColor={229,238,242}, fillPattern=FillPattern.Solid, lineThickness=1),
    Text(extent={{-148,-75},{148,-103}}, textString="%name", textColor={31,61,76})}));
end FixedVolume;
