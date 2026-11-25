within AirConditionerCycle.Components.Rotary;
model Accumulator "吸入アキュームレータ。気液平衡・上部ガス取出し"
  import SI = Modelica.Units.SI;
  extends BaseClasses.FixedVolume(V=0.00055, p_start=370500, h_start=407250);
  parameter SI.Area inletArea(min=1e-8)=0.000065 "入口の有効流路面積";
  parameter Boolean inletCheckValve=false "入口で逆流を遮断する" annotation(Evaluate=true);
  Medium.SaturationProperties sat;
  SI.Mass liquidMass "容器内に分離保持した液冷媒";
  Real quality(unit="1") "容器内の蒸気質量率";
equation
  m_flow = inletArea*sqrt(2*Medium.density_ph(inlet.p,h_in))*
    Modelica.Fluid.Utilities.regRoot(
      if inletCheckValve then max(0,inlet.p-gas.p) else inlet.p-gas.p, 40);
  outlet.p = gas.p;
  sat = Medium.setSat_p(gas.p);
  quality = min(1, max(0, (gas.h - Medium.bubbleEnthalpy(sat))/
                           (Medium.dewEnthalpy(sat) - Medium.bubbleEnthalpy(sat))));
  liquidMass = gas.mass*(1-quality);
  outlet.h_outflow = max(gas.h, Medium.dewEnthalpy(sat));
  Q_gas = 0;
  assert(noEvent(gas.h > Medium.bubbleEnthalpy(sat)), "Accumulator has lost its vapour space.");
  annotation(Icon(graphics={
    Line(points={{-39,-17},{-16,-12},{12,-21},{39,-15}}, color={38,129,170}, thickness=1.2),
    Line(points={{37,0},{19,0},{19,39},{0,39},{0,24}}, color={44,72,88}, thickness=1.4)}));
end Accumulator;
