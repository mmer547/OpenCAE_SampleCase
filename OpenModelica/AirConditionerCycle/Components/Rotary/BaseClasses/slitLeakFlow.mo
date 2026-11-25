within AirConditionerCycle.Components.Rotary.BaseClasses;
function slitLeakFlow "薄い気体すきまの符号付き質量流量。A→Bが正"
  import SI = Modelica.Units.SI;
  input SI.Length gap;
  input SI.Length width;
  input SI.Length lengthEquivalent;
  input SI.PressureDifference dp "pA - pB";
  input SI.Density meanDensity "上流の温度と圧縮係数を一定とした流路平均密度";
  input SI.DynamicViscosity viscosity "上流の気体粘度";
  input Real signedNozzleFlux(unit="kg/(m2.s)") "同じ両端状態でのノズル流束";
  output SI.MassFlowRate flowRate;
protected
  SI.MassFlowRate viscousFlow;
  SI.MassFlowRate nozzleLimit;
algorithm
  if gap <= 0 then
    flowRate := 0;
  else
    assert(lengthEquivalent > 0 and viscosity > 0, "Open gas slit requires positive flow length and viscosity.");
    viscousFlow := width*gap^3*meanDensity*dp/(12*viscosity*lengthEquivalent);
    nozzleLimit := width*gap*abs(signedNozzleFlux);
    flowRate := min(nozzleLimit,max(-nozzleLimit,viscousFlow));
  end if;
  annotation(Inline=true);
end slitLeakFlow;
