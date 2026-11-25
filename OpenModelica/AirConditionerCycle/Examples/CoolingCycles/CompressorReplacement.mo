within AirConditionerCycle.Examples.CoolingCycles;
model CompressorReplacement "同じ配管・境界条件で圧縮機だけを差し替える"
  extends RatedCooling(cycle(redeclare model Compressor = BaseClasses.FixedFlowCompressor));
  annotation(experiment(StartTime=0, StopTime=600, Interval=2, Tolerance=1e-7));
end CompressorReplacement;
