within AirConditionerCycle.Examples.LossStudies;
model RotaryCompressorLossTest "R134a 詳細圧縮機単体の損失評価"
  extends CompressorTests.RotaryCompressorStandalone(useDetailedLosses=true);
  annotation(Documentation(info="<html><p>compressor.losses.power と meanPower が瞬時・直前1回転のチャネル別値 [W] です。銅損・鉄損・機械摩擦の発熱はシェルに入り、流路圧損は上流体積流量×差圧で表示します。meanLeakRate は kg/s。効率は1回転完了後に更新します。</p></html>"));
end RotaryCompressorLossTest;
