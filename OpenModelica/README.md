# OpenModelica のサンプルケース

## AirConditionerCycle — 冷凍サイクル

圧縮機、凝縮器、膨張弁、蒸発器を組み合わせた冷凍サイクルです。圧縮機を差し替えてサイクル全体を計算する例と、圧縮機単体の試験例を収録しています。[ライブラリの導入と OMEdit での実行方法](AirConditionerCycle/README.md)

初めて動かす場合は OMEdit でパッケージを開き、**Examples → CoolingCycles → RatedCooling** を実行します。圧縮機の単体試験は **Examples → CompressorTests** から選べます。[パッケージ](AirConditionerCycle/package.mo) ／ [全49例の索引](AirConditionerCycle/Examples/README.md) ／ [部品・コネクタと物理方程式（PDF）](AirConditionerCycle/PhysicalEquations.pdf)

## Compression_Chamber — 冷媒圧縮機の圧縮室

容積が周期的に変化する1室の質量・エネルギー収支を解き、吸入、漏れ、吐出弁を通る流れを計算します。[モデルファイル](Compression_Chamber/Compression_Chamber.mo)

- `Components` に圧縮室、吸入側境界、吐出弁、吐出圧力境界があり、`Interfaces` に各ポートの定義があります。
- `SystemParameters` で圧力、温度、流路面積、流量係数などを設定します。
- `Media` は CO₂、R32、R410A の物性計算に ExternalMedia の CoolProp バックエンドを使用します。

### OMEdit で圧縮室を計算する

1. Modelica 4.1.0 と ExternalMedia（CoolProp バックエンド）を用意します。
2. OMEdit で `Compression_Chamber/Compression_Chamber.mo` を読み込み、`Compression_Chamber.Examples.SimpleChamberTest` を実行します。
3. 圧縮室の圧力 `compressionChamber.p`、温度 `compressionChamber.T`、吐出質量流量 `dischargeValve.m_flow_out` をプロットします。

## Oil_Circuit — 油回路

容積式ポンプから送り出した油が流路抵抗と3本の並列オリフィスを通り、圧力境界へ戻る回路です。OMEdit で [OilCircuit.mo](Oil_Circuit/OilCircuit.mo) を読み込み、`OilCircuit.Tests.test1` を実行します。
