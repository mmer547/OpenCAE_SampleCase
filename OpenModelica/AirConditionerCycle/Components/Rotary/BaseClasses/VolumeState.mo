within AirConditionerCycle.Components.Rotary.BaseClasses;
model VolumeState "均質な冷媒容積の質量・エネルギー収支"
  import SI = Modelica.Units.SI;
  replaceable package Medium = AirConditionerCycle.Media.R134a constrainedby
    Modelica.Media.Interfaces.PartialTwoPhaseMedium annotation(choicesAllMatching=true);
  parameter Medium.AbsolutePressure p_start;
  parameter Medium.SpecificEnthalpy h_start;
  input SI.Volume V;
  input SI.VolumeFlowRate dV "容積の時間変化率";
  input SI.MassFlowRate dm "全ポートからの正味の流入";
  input SI.Power H_flow "流入エンタルピー流率の合計（流出は負）";
  input SI.HeatFlowRate Q_flow "冷媒へ流入する熱";
  Medium.AbsolutePressure p(start=p_start, fixed=true, stateSelect=StateSelect.prefer);
  Medium.SpecificEnthalpy h(start=h_start, fixed=true, stateSelect=StateSelect.prefer);
  Medium.ThermodynamicState state;
  Medium.Density rho;
  Medium.Temperature T;
  SI.Mass mass;
  SI.Energy U;
equation
  state = Medium.setState_ph(p,h);
  rho = Medium.density(state);
  T = Medium.temperature(state);
  mass = rho*V;
  U = mass*h - p*V;
  V*(Medium.density_derp_h(state)*der(p) + Medium.density_derh_p(state)*der(h))
    + rho*dV = dm;
  // Equivalent to der(U) = H_flow + Q_flow - p*dV.
  mass*der(h) - V*der(p) = H_flow - h*dm + Q_flow;
end VolumeState;
