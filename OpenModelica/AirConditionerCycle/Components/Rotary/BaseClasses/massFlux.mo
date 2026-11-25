within AirConditionerCycle.Components.Rotary.BaseClasses;
function massFlux "正方向の気体ノズル質量流束。臨界圧力比でチョーク"
  input Modelica.Units.SI.AbsolutePressure pUp;
  input Modelica.Units.SI.AbsolutePressure pDown;
  input Modelica.Units.SI.Density rhoUp;
  input Real gamma(min=1.01)=1.12 "気体ノズル近似の比熱比";
  output Real G(unit="kg/(m2.s)");
protected
  constant Real Gsmall(unit="kg/(m2.s)")=1 "ゼロ差圧付近の平滑化流束";
  Real ratio;
  Real gSquared(unit="kg2/(m4.s2)");
algorithm
  ratio := min(1, max((2/(gamma+1))^(gamma/(gamma-1)), pDown/pUp));
  gSquared := max(0, 2*rhoUp*pUp*gamma/(gamma-1)
                  *ratio^(2/gamma)*(1-ratio^((gamma-1)/gamma)));
  // Smooth the square root near zero differential pressure (flux scale 1 kg/m2/s).
  G := gSquared/sqrt(gSquared + Gsmall^2);
  annotation(Inline=true, smoothOrder=0);
end massFlux;
