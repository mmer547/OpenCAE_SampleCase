within AirConditionerCycle.Examples;
model NobelStandalone "ノーベルコンプレッサー単体の吸入・吐出境界試験"
  parameter Components.Rotary.BaseClasses.CylinderClearances gaps(radialGap=5e-6,topGap=8e-6,bottomGap=8e-6)
    "外周・両端面の比較用有効気体すきま";
  extends BaseClasses.PartialRotaryBench(
    redeclare final model Compressor = Components.Rotary.NobelCompressor,
    useDetailedLosses=true, compressor(cylinder(clearances=gaps)));
  annotation(experiment(StartTime=0,StopTime=0.23,Interval=0.000025,Tolerance=1e-7),
    Documentation(info="<html><p>一体ブレード角度 compressor.roller.beta、摺動・揺動損失 compressor.vane.slideLoss / pivotLoss、吐出流量 dischargeFlow を観察できます。gaps の各値を 0 にすると対応する漏れ経路が閉じます。</p></html>"));
end NobelStandalone;
