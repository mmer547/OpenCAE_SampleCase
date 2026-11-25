within AirConditionerCycle.Examples.BaseClasses;
model FixedFlowCompressor "差し替え例で使用する一定質量流量圧縮機"
  extends Components.PartialIsentropicCompressor;
  parameter Medium.MassFlowRate m_set(min=1e-6)=0.016 "冷媒質量流量の設定値";
equation
  m_flow = m_set;
end FixedFlowCompressor;
