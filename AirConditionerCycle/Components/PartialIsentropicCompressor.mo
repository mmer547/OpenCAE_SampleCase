within AirConditionerCycle.Components;
partial model PartialIsentropicCompressor "断熱圧縮およびモーター効率"
  extends Interfaces.PartialCompressor;
  parameter Real etaIs(min=0.01, max=1)=0.72 "等エントロピー効率";
  parameter Real etaMotor(min=0.01, max=1)=0.90 "モーター効率";
  Medium.ThermodynamicState suction "吸入状態";
  Medium.SpecificEnthalpy h_is "吐出圧力まで等エントロピー圧縮した比エンタルピー";
  Modelica.Units.SI.Power P_shaft "断熱圧縮で冷媒に加わる動力";
equation
  inlet.m_flow + outlet.m_flow = 0;
  suction = Medium.setState_ph(inlet.p, h_in);
  h_is = Medium.isentropicEnthalpy(outlet.p, suction);
  outlet.h_outflow = h_in + (h_is - h_in)/etaIs;
  P_shaft = m_flow*(outlet.h_outflow - h_in);
  P_el = P_shaft/etaMotor;
  assert(noEvent(outlet.p > inlet.p), "The compressor requires discharge pressure above suction pressure.");
end PartialIsentropicCompressor;
