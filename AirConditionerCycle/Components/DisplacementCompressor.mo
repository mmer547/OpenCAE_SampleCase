within AirConditionerCycle.Components;
model DisplacementCompressor "押しのけ容積と体積効率を用いた圧縮機"
  extends PartialIsentropicCompressor;
  parameter Modelica.Units.SI.Volume V_disp(min=1e-12)=28e-6 "1回転当たり押しのけ容積";
  parameter Modelica.Units.SI.Frequency speed(min=0.01)=50 "毎秒回転数";
  parameter Real etaVol(min=0.01, max=1)=0.80 "体積効率";
equation
  m_flow = etaVol*V_disp*speed*Medium.density(suction);
  annotation(defaultComponentName="compressor");
end DisplacementCompressor;
