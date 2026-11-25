within ;
package AirConditionerCycle "空調機の蒸気圧縮冷凍サイクル"
  extends Modelica.Icons.Package;
  annotation(version="1.7.0", uses(Modelica(version="4.1.0"), ExternalMedia(version="4.1.1")),
    Documentation(info="<html><p>シリンダの追加すきまは Examples.RotaryClearanceStudy と Examples.TwinRotaryClearanceStudy で比較できます。断熱2気筒は Examples.TwinRotaryStandalone と Examples.TwinRotaryCooling で実行できます。断熱単気筒ロータリーの単体試験は Examples.AdiabaticRotaryStandalone、冷凍サイクルは Examples.AdiabaticRotaryCooling です。Examples.RatedCooling で R134a の定格運転、Examples.OutdoorTemperatureRamp で外気温上昇時の応答を確認できます。Examples.RotaryCompressorLossTest で部品別の損失と回転平均を確認できます。Examples.RotaryCompressorStandalone でロータリー圧縮機単体、Examples.RotaryCooling で閉回路の冷房運転を実行できます。CoolingCycle のダイアグラムから各機器を開けます。Examples.RefrigerantTests に R290、R32、R410A、亜臨界 CO₂ の標準・ロータリー型の実行例を収録しています。</p></html>"));
end AirConditionerCycle;
