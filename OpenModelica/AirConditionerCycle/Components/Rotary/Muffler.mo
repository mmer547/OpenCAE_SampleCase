within AirConditionerCycle.Components.Rotary;
model Muffler "吐出マフラ。膨張室の圧縮性と出口絞り"
  import SI = Modelica.Units.SI;
  extends BaseClasses.FixedVolume(V=0.000085, p_start=1173000, h_start=443000);
  parameter SI.Area exitArea(min=1e-8)=0.000045 "出口の有効流路面積";
equation
  inlet.p = gas.p;
  outlet.h_outflow = gas.h;
  gas.p - outlet.p = (-outlet.m_flow)*abs(outlet.m_flow)/(2*gas.rho*exitArea^2);
  Q_gas = 0;
  annotation(Icon(graphics={
    Line(points={{-18,-54},{-18,26}}, color={60,91,108}, thickness=1.4),
    Line(points={{18,54},{18,-26}}, color={60,91,108}, thickness=1.4)}));
end Muffler;
