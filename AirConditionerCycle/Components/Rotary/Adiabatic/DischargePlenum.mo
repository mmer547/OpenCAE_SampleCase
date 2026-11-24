within AirConditionerCycle.Components.Rotary.Adiabatic;
model DischargePlenum "断熱高圧シェルのガス容積"
  extends BaseClasses.FixedVolume(V=0.00085, p_start=1164500, h_start=444000);
equation
  inlet.p = gas.p;
  outlet.p = gas.p;
  outlet.h_outflow = gas.h;
  Q_gas = 0;
end DischargePlenum;
