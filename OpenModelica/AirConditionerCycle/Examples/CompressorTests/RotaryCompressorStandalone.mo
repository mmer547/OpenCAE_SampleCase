within AirConditionerCycle.Examples.CompressorTests;
model RotaryCompressorStandalone "詳細ロータリー圧縮機の単体試験（吸入・吐出圧力を指定）"
  extends BaseClasses.PartialRotaryBench(compressor(shell(
    Twall_start=Medium.temperature_ph(dischargePressure,hDischargeStart),Tambient=ambientTemperature)));
  parameter Modelica.Units.SI.Temperature ambientTemperature=308.15 "シェル周囲の温度";
  annotation(experiment(StartTime=0,StopTime=0.23,Interval=0.000025,Tolerance=1e-7),
    Documentation(info="<html><p>吸入リザーバ、11部品の単気筒ロータリー圧縮機、吐出リザーバを接続した開回路です。吸入圧力・吸入過熱度・吐出背圧・回転数指令・シェル周囲温度を設定できます。吸入境界と容器の差圧がゼロ以下では入口の逆止弁を閉じます。吐出の順方向流れでは、吐出ガス温度と質量流量は圧縮機が決定します。</p><p>既定の冷媒は R134a。運転中の状態から開始します。dischargeFlow、dischargeTemperature、compressor.P_el、compressor.reed.lift、compressor.cylinder.pocketA.p をプロットできます。</p></html>"));
end RotaryCompressorStandalone;
