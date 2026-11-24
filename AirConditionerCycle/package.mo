within ;
package AirConditionerCycle "空調機の蒸気圧縮冷凍サイクル"
  extends Modelica.Icons.Package;
  annotation(version="1.1.0", uses(Modelica(version="4.1.0"), ExternalMedia(version="4.1.1")),
    Documentation(info="<html><p>R134a の冷房サイクルです。Examples.RatedCooling で定格運転、Examples.OutdoorTemperatureRamp で外気温上昇時の応答を確認できます。Examples.RotaryCooling では部品別のロータリー圧縮機を試せます。CoolingCycle のダイアグラムから各機器を開けます。</p></html>"));
end AirConditionerCycle;
