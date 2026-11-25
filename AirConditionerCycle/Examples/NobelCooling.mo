within AirConditionerCycle.Examples;
model NobelCooling "単気筒のノーベルコンプレッサーを搭載した冷房サイクル"
  extends RotaryCooling(cycle(redeclare model Compressor = Components.Rotary.NobelCompressor,
    compressor(useDetailedLosses=true,cylinder(clearances(radialGap=5e-6,topGap=8e-6,bottomGap=8e-6)))));
  annotation(experiment(StartTime=0,StopTime=0.21,Interval=0.000025,Tolerance=1e-7));
end NobelCooling;
