# 空調機・圧縮機の例題索引

OMEdit で `AirConditionerCycle/package.mo` を開き、ライブラリブラウザーの **AirConditionerCycle → Examples** から例題を選びます。以下の表ではリンクを開くと、その例題の Modelica ソースを読めます。[インストールと実行手順](../README.md#omedit-で動かす)

初めて冷房サイクルを動かす場合は **CoolingCycles → RatedCooling** を選びます。600 s まで計算し、`cycle.Q_cooling`、`cycle.P_el`、`cycle.COP` を表示します。室内 25 °C・室外 35 °C の R134a 参照計算では、600 s の冷房能力は 2.996 kW、電力は 0.745 kW、COP は 4.023 です。

圧縮機の中を見たい場合は **CompressorTests → AdiabaticRotaryStandalone** を選びます。吸入・吐出圧力を試験台で固定し、作動室圧力 `compressor.cylinder.pocketA.p` と吐出弁リフト `compressor.reed.lift` を同じ時間軸に表示すると、弁が開く時点の室圧を読めます。

## 冷房サイクルを動かす

**CoolingCycles** の8例では、蒸発器と凝縮器の状態から吸入・吐出圧力が決まります。標準・一定流量の例は600 s で冷房性能を比較します。軸角ごとに計算する詳細圧縮機は 0.12～0.21 s の例で、始動直後の各回転の挙動を観察できます。

| R134a の例題 | 調べられること | 最初に表示する変数 |
|---|---|---|
| [RatedCooling](CoolingCycles/RatedCooling.mo) | 室内 25 °C、室外 35 °C の定格冷房 | `cycle.Q_cooling`、`cycle.COP` |
| [OutdoorTemperatureRamp](CoolingCycles/OutdoorTemperatureRamp.mo) | 120～240 s で外気を 35 °C から 40 °C に上げたときの高圧と効率 | `cycle.pHigh`、`cycle.COP` |
| [CompressorReplacement](CoolingCycles/CompressorReplacement.mo) | 圧縮機を一定質量流量型に交換したときの能力と電力 | `cycle.Q_cooling`、`cycle.P_el` |
| [RotaryCooling](CoolingCycles/RotaryCooling.mo) | 熱連成ロータリーの吐出量と電気入力の1回転平均 | `meanDelivery`、`meanPower` |
| [AdiabaticRotaryCooling](CoolingCycles/AdiabaticRotaryCooling.mo) | 断熱単気筒ロータリーの駆動損失と平均電力 | `cycle.compressor.driveLoss`、`meanPower` |
| [TwinRotaryCooling](CoolingCycles/TwinRotaryCooling.mo) | 180°ずれた上下気筒の吐出タイミング | `cycle.compressor.upper.reed.lift`、`cycle.compressor.lower.reed.lift` |
| [NobelCooling](CoolingCycles/NobelCooling.mo) | ノーベルコンプレッサーの平均吐出量と電力 | `meanDelivery`、`meanPower` |
| [ScrollCooling](CoolingCycles/ScrollCooling.mo) | スクロール圧縮機の平均吐出量と電力 | `cycle.compressor.meanDelivery`、`cycle.compressor.meanPower` |

## 圧縮機だけを運転する

**CompressorTests** の5例では、吸入側と吐出側にそれぞれ境界を接続します。R134a の既定値は蒸発 7 °C、凝縮 45 °C に相当する絶対圧、吸入過熱度 5 K、回転数指令 3,000 rpm です。`dischargeFlow` [kg/s] は吐出管から境界へ流れるときが正、`dischargeTemperature` [K] はその出口の冷媒温度です。

| R134a の例題 | 方式と観察点 |
|---|---|
| [RotaryCompressorStandalone](CompressorTests/RotaryCompressorStandalone.mo) | 熱連成単気筒。シェル壁温 `compressor.shell.Twall` と吐出冷媒温度を比較 |
| [AdiabaticRotaryStandalone](CompressorTests/AdiabaticRotaryStandalone.mo) | 断熱単気筒。作動室圧力、弁リフト、機外への散逸動力 `compressor.driveLoss` を確認 |
| [TwinRotaryStandalone](CompressorTests/TwinRotaryStandalone.mo) | 断熱2気筒。`compressor.upper.reed.m_flow` と `compressor.lower.reed.m_flow` を重ね、共通吐出管の流量と比較 |
| [NobelStandalone](CompressorTests/NobelStandalone.mo) | 一体ブレードの揺動角 `compressor.roller.beta`、ブッシュの摺動損失 `compressor.vane.slideLoss` と揺動損失 `compressor.vane.pivotLoss` |
| [ScrollStandalone](CompressorTests/ScrollStandalone.mo) | 室対1の行程 `compressor.wraps.stage[1]` と室圧 `compressor.pockets.pocket[1].p`。歯先・側面の漏れを個別に確認 |

## 損失・すきま・部品を調べる

| フォルダと例題 | 条件と結果の読み方 |
|---|---|
| LossStudies ／ [RotaryCompressorLossTest](LossStudies/RotaryCompressorLossTest.mo) | 熱連成単気筒の詳細損失を有効化。`compressor.losses.power` が瞬時値、`compressor.losses.meanPower` が完了した直前1回転のチャネル別平均 |
| LossStudies ／ [RotaryClearanceStudy](LossStudies/RotaryClearanceStudy.mo) | 断熱単気筒。`gaps.radialGap`、`gaps.topGap`、`gaps.bottomGap` を変え、`compressor.losses.meanLeakRate` で室間漏れを比較 |
| LossStudies ／ [TwinRotaryClearanceStudy](LossStudies/TwinRotaryClearanceStudy.mo) | 同じ3種類のすきまを上下気筒に指定。上下の漏れ量と共通吐出管の `dischargeFlow` を比較 |
| ComponentTests ／ [AccumulatorWetInlet](ComponentTests/AccumulatorWetInlet.mo) | 入口乾き度 0.80 の湿り冷媒を供給。`accumulator.liquidMass` [kg] で液保持量、`accumulator.outlet.h_outflow` と `hDew` [J/kg] で出口の蒸気状態を確認 |

すきまを一つずつ閉じた参照条件、漏れ流量の正方向、上下端面の数え方は物理方程式ガイドにあります。[シリンダすきまの比較試験](../PhysicalEquations.md#シリンダすきまの比較試験)

## 冷媒を変えて比較する

**RefrigerantTests** では、列が冷媒、行が試験内容です。クラス名は冷媒名（CO₂ は `CO2Subcritical`）と表の末尾名をつなげます。例えば R32 の断熱2気筒単体は **RefrigerantTests → R32 → R32TwinStandalone** です。CO₂ は亜臨界条件で、冷房回路の初期蒸発・凝縮温度は −10 °C・8 °C、単体試験は同じ温度に相当する飽和圧力と吸入過熱度 5 K を使います。[各冷媒の境界条件と参照値](../RefrigerantTests.md)

| 試験内容 | クラス名の末尾 | R290 | R32 | R410A | CO₂ |
|---|---|---|---|---|---|
| 標準圧縮機の冷房回路 | `Standard` | [R290](RefrigerantTests/R290/R290Standard.mo) | [R32](RefrigerantTests/R32/R32Standard.mo) | [R410A](RefrigerantTests/R410A/R410AStandard.mo) | [CO₂](RefrigerantTests/CO2/CO2SubcriticalStandard.mo) |
| 熱連成単気筒の冷房回路 | `Rotary` | [R290](RefrigerantTests/R290/R290Rotary.mo) | [R32](RefrigerantTests/R32/R32Rotary.mo) | [R410A](RefrigerantTests/R410A/R410ARotary.mo) | [CO₂](RefrigerantTests/CO2/CO2SubcriticalRotary.mo) |
| 断熱単気筒の冷房回路 | `AdiabaticCooling` | [R290](RefrigerantTests/R290/R290AdiabaticCooling.mo) | [R32](RefrigerantTests/R32/R32AdiabaticCooling.mo) | [R410A](RefrigerantTests/R410A/R410AAdiabaticCooling.mo) | [CO₂](RefrigerantTests/CO2/CO2SubcriticalAdiabaticCooling.mo) |
| 断熱2気筒の冷房回路 | `TwinCooling` | [R290](RefrigerantTests/R290/R290TwinCooling.mo) | [R32](RefrigerantTests/R32/R32TwinCooling.mo) | [R410A](RefrigerantTests/R410A/R410ATwinCooling.mo) | [CO₂](RefrigerantTests/CO2/CO2SubcriticalTwinCooling.mo) |
| 熱連成単気筒の単体運転 | `Standalone` | [R290](RefrigerantTests/R290/R290Standalone.mo) | [R32](RefrigerantTests/R32/R32Standalone.mo) | [R410A](RefrigerantTests/R410A/R410AStandalone.mo) | [CO₂](RefrigerantTests/CO2/CO2SubcriticalStandalone.mo) |
| 断熱単気筒の単体運転 | `AdiabaticStandalone` | [R290](RefrigerantTests/R290/R290AdiabaticStandalone.mo) | [R32](RefrigerantTests/R32/R32AdiabaticStandalone.mo) | [R410A](RefrigerantTests/R410A/R410AAdiabaticStandalone.mo) | [CO₂](RefrigerantTests/CO2/CO2SubcriticalAdiabaticStandalone.mo) |
| 断熱2気筒の単体運転 | `TwinStandalone` | [R290](RefrigerantTests/R290/R290TwinStandalone.mo) | [R32](RefrigerantTests/R32/R32TwinStandalone.mo) | [R410A](RefrigerantTests/R410A/R410ATwinStandalone.mo) | [CO₂](RefrigerantTests/CO2/CO2SubcriticalTwinStandalone.mo) |
| 熱連成単気筒の詳細損失 | `LossTest` | [R290](RefrigerantTests/R290/R290LossTest.mo) | [R32](RefrigerantTests/R32/R32LossTest.mo) | [R410A](RefrigerantTests/R410A/R410ALossTest.mo) | [CO₂](RefrigerantTests/CO2/CO2SubcriticalLossTest.mo) |

ノーベルとスクロールの OMEdit 例題は R134a です。両方式の R290・R32・R410A・CO₂ での単体試験は、`AirConditionerCycle` ディレクトリで次のコマンドを実行します。`--fluid all` は R134a も含む5冷媒を順に実行します。[ノーベルの計算条件と試験結果](../NobelCompressor.md) ／ [スクロールの計算条件と試験結果](../ScrollCompressor.md)

```sh
python3 Resources/Scripts/run_nobel_tests.py --fluid all
python3 Resources/Scripts/run_scroll_tests.py --fluid all
```

## 1.7.0 の例題を参照している場合

1.8.0 では例題のクラス名に用途別フォルダが加わりました。以下は `AirConditionerCycle.Examples.` に続く部分です。`BaseClasses` には試験台・一定流量圧縮機・冷媒別の基底例を収録しています。[全移動先の対応表](../Resources/Scripts/Conversion/ConvertExamplesFrom_1_7.mos) ／ [共通クラス](BaseClasses/package.mo)

| 1.7.0 の参照 | 1.8.0 の参照 |
|---|---|
| `RatedCooling` | `CoolingCycles.RatedCooling` |
| `ScrollStandalone` | `CompressorTests.ScrollStandalone` |
| `RefrigerantTests.R32TwinStandalone` | `RefrigerantTests.R32.R32TwinStandalone` |
| `FixedFlowCompressor` | `BaseClasses.FixedFlowCompressor` |

`uses(AirConditionerCycle(version="1.7.0"))` を持つ自作パッケージは、OMShell で本体 1.8.0 と自作パッケージを読み込み、次のコマンドを実行します。`MyPackage` は自作パッケージのクラス名に置き換えます。変換後は自作モデルをチェックして保存します。Python やシミュレーション用の `.mos` に直接記述したクラス名は、上の対応表で更新します。

```modelica
convertPackageToLibrary(MyPackage, AirConditionerCycle, "1.8.0");
```
