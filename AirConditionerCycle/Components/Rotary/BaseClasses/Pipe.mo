within AirConditionerCycle.Components.Rotary.BaseClasses;
partial model Pipe "直管摩擦と局部損失を持つ断熱配管"
  extends AirConditionerCycle.Interfaces.PartialTwoPort;
  import SI = Modelica.Units.SI;
  parameter SI.Length length(min=0);
  parameter SI.Diameter diameter(min=1e-5);
  parameter Real frictionFactor(min=0)=0.025 "Darcy 摩擦係数";
  parameter Real minorLoss(min=0)=1.5 "曲がり等の局部損失係数";
  final parameter SI.Area area=Modelica.Constants.pi*diameter^2/4;
  SI.PressureDifference dp;
equation
  inlet.m_flow + outlet.m_flow = 0;
  dp = inlet.p - outlet.p;
  dp = (frictionFactor*length/diameter + minorLoss)*m_flow*sqrt(m_flow^2 + 1e-8)/
       (2*Medium.density_ph(inlet.p,h_in)*area^2);
  outlet.h_outflow = h_in;
  annotation(Icon(graphics={
    Polygon(points={{-98,-12},{-42,-12},{-15,10},{16,10},{41,-12},{98,-12},{98,12},
      {51,12},{26,34},{-25,34},{-52,12},{-98,12},{-98,-12}},lineColor={45,70,82},
      fillColor={179,199,209},fillPattern=FillPattern.Solid,lineThickness=1),
    Text(extent={{-145,-48},{145,-78}}, textString="%name", textColor={31,61,76})}));
end Pipe;
