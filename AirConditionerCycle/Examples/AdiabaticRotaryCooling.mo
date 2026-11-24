within AirConditionerCycle.Examples;
model AdiabaticRotaryCooling "断熱ロータリーを組み込んだ冷凍サイクル"
  extends RotaryCooling(cycle(redeclare model Compressor =
    Components.Rotary.AdiabaticRollingPistonCompressor));
  annotation(experiment(StartTime=0,StopTime=0.21,Interval=0.000025,Tolerance=1e-7));
end AdiabaticRotaryCooling;
