within AirConditionerCycle.Interfaces;
partial model PartialTwoPort "純冷媒の順方向流れポート"
  replaceable package Medium = Media.R134a
    constrainedby Modelica.Media.Interfaces.PartialTwoPhaseMedium
    annotation(choicesAllMatching=true);
  Modelica.Fluid.Interfaces.FluidPort_a inlet(
    redeclare final package Medium = Medium, m_flow(min=0))
    annotation(Placement(transformation(extent={{-110,-10},{-90,10}})));
  Modelica.Fluid.Interfaces.FluidPort_b outlet(
    redeclare final package Medium = Medium, m_flow(max=0))
    annotation(Placement(transformation(extent={{90,-10},{110,10}})));
  Medium.MassFlowRate m_flow "入口の冷媒質量流量";
  Medium.SpecificEnthalpy h_in "流入比エンタルピー";
protected
  constant Boolean internalFlowPath=false "Composite models obtain outgoing streams from their internal ports";
initial equation
  assert(Medium.nXi == 0 and Medium.nC == 0, "Use a pure refrigerant with no trace substances.");
equation
  m_flow = inlet.m_flow;
  h_in = inStream(inlet.h_outflow);
  if not internalFlowPath then
    // Reverse flow is excluded. Give the unused reverse stream a defined value.
    inlet.h_outflow = Medium.h_default;
    inlet.Xi_outflow = fill(0, Medium.nXi);
    outlet.Xi_outflow = fill(0, Medium.nXi);
    inlet.C_outflow = fill(0, Medium.nC);
    outlet.C_outflow = fill(0, Medium.nC);
  end if;
  assert(noEvent(m_flow >= 0), "Flow reversal is outside the cooling-mode model.");
end PartialTwoPort;
