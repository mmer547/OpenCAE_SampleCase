within AirConditionerCycle.Examples;
model ScrollCooling "スクロール圧縮機を接続した冷房サイクル"
  extends RatedCooling(cycle(redeclare model Compressor=Components.Scroll.ScrollCompressor));
  annotation(experiment(StopTime=0.12,Interval=0.000025,Tolerance=1e-7));
end ScrollCooling;
