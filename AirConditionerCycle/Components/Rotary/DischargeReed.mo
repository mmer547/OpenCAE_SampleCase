within AirConditionerCycle.Components.Rotary;
model DischargeReed "差圧で開く吐出リード弁。有限質量・剛性・減衰・リフト上限"
  extends AirConditionerCycle.Interfaces.PartialTwoPort;
  import SI = Modelica.Units.SI;
  parameter SI.Diameter portDiameter(min=1e-4)=0.009;
  parameter SI.Length liftMax(min=1e-5)=0.0010;
  parameter SI.Mass effectiveMass(min=1e-7)=0.00018;
  parameter SI.TranslationalSpringConstant k(min=1)=3800;
  parameter SI.Pressure crackingPressure(min=0)=4500;
  parameter Real dampingRatio(min=0.1)=1;
  parameter Real Cd(min=0.01,max=1)=0.78;
  final parameter SI.Area portArea=Modelica.Constants.pi*portDiameter^2/4;
  SI.Position lift(start=0,fixed=true);
  SI.Velocity v(start=0,fixed=true);
  SI.Position target;
  SI.Area effectiveArea;
equation
  inlet.m_flow + outlet.m_flow = 0;
  target = noEvent(min(liftMax,max(0,(inlet.p-outlet.p-crackingPressure)*portArea/k)));
  der(lift) = v;
  effectiveMass*der(v) = k*(target-lift) - 2*dampingRatio*sqrt(k*effectiveMass)*v;
  effectiveArea = Cd*min(portArea, Modelica.Constants.pi*portDiameter*noEvent(max(0,min(liftMax,lift))));
  m_flow = effectiveArea*noEvent(BaseClasses.massFlux(inlet.p,outlet.p,Medium.density_ph(inlet.p,h_in)));
  outlet.h_outflow = h_in;
  annotation(Icon(graphics={
    Line(points={{-98,0},{-20,0},{-20,-45},{24,-45},{24,0},{98,0}},color={48,76,90},thickness=1.5),
    Line(points={{-23,6},{-8,8},{14,20},{34,41}},color={163,87,46},thickness=2),
    Text(extent={{-145,-63},{145,-93}},textString="%name",textColor={31,61,76})}));
end DischargeReed;
