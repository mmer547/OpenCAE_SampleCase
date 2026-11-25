within AirConditionerCycle.Examples.LossStudies;
model RotaryClearanceStudy "単気筒ロータリーの半径すきま・両端面すきまの感度試験"
  parameter Components.Rotary.BaseClasses.CylinderClearances gaps(radialGap=5e-6,topGap=8e-6,bottomGap=8e-6)
    "比較用の仮定寸法。各すきまを0にするとその経路が閉じる";
  extends CompressorTests.AdiabaticRotaryStandalone(compressor(cylinder(clearances=gaps)));
  annotation(experiment(StartTime=0,StopTime=0.23,Interval=0.000025,Tolerance=1e-7),
    Documentation(info="<html><p>R134a の圧縮機単体試験です。gaps で各通路を設定し、各シリンダの radialLeakAB、topFaceLeakAB、bottomFaceLeakAB とベーン先端の vaneTipLeakAB を比較します。寸法は感度検討用です。</p></html>"));
end RotaryClearanceStudy;
