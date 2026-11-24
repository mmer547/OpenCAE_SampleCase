# ロータリー圧縮機

2気筒を使う場合は `Examples.TwinRotaryStandalone` または `Examples.TwinRotaryCooling` を開きます。[部品・力学・冷媒合流の説明](PhysicalEquations.md#ツインロータリーの構成と保存則) ／ [2気筒の例題と波形](PhysicalEquations.md#ツインロータリーの実行例)

**断熱版** `Components.Rotary.AdiabaticRollingPistonCompressor` と **熱連成版** `Components.Rotary.RollingPistonCompressor` は、同じ吸入・吐出ポート、ローラ形状、二つの作動室、リード弁と駆動機構を使います。両方とも電力、吐出流量、吐出冷媒温度を求めます。

## 断熱版の単体試験

OMEdit で **Examples → AdiabaticRotaryStandalone** を実行します。吸入圧力・吐出背圧・吸入過熱度・回転数を変更できます。5冷媒の単体例では詳細損失を有効にしています。比較対象は同じ損失設定の `RotaryCompressorLossTest` です。吸入から吐出までのダイアグラムを開くと、冷媒ポートと機械フランジをたどれます。

- `compressor.cylinder.pocketA.p`、`compressor.reed.lift` で圧縮から吐出までを追います。
- `dischargeFlow`、`dischargeTemperature`、`compressor.P_el` で吐出流量・温度・消費電力を読みます。
- `compressor.driveLoss` は電動機、軸、ベーンで散逸した動力の合計 [W]。`compressor.losses.meanPower` は完了した直前1回転の各チャネル平均 [W] です。断熱版の `shellHeat` はゼロです。

断熱版の作動室と高圧シェルは冷媒の質量・内部エネルギーを蓄えます。電気・機械の損失は冷媒へ戻さず、相抵抗 `motor.operatingResistance` を一定（既定 0.36 Ω）として扱います。熱連成版はシェル壁の熱容量、冷媒との熱交換、外気放熱、壁温による相抵抗の変化を計算します。両モデルとも蒸発器・凝縮器に接続できます。[物理方程式・第17章](PhysicalEquations.pdf)

R134a で吸入 0.374627 MPa（過熱度 5 K）、吐出 1.159924 MPa、回転数指令 3,000 rpm をそろえた単体試験の結果です。値は 0.23 s の計算中に完了した11回転目の平均です。シェル壁の長時間の温度応答はこの比較の対象外です。

| 詳細損失を有効にしたモデル | 消費電力 [W] | 吐出流量 [g/s] | 吐出冷媒温度 [°C] |
|---|---:|---:|---:|
| 断熱ロータリー | 789.6 | 22.48 | 61.71 |
| 熱連成ロータリー | 792.3 | 22.57 | 61.76 |

断熱版の全冷媒試験は、展開した `AirConditionerCycle` ディレクトリで実行します。

```sh
python Resources/Scripts/run_standalone_tests.py --adiabatic --fluid all --csv adiabatic_standalone.csv
python Resources/Scripts/run_adiabatic_cycles.py --fluid all --csv adiabatic_cycle.csv
```

[単体試験の条件・結果・収支残差](Resources/Reference/adiabatic_standalone.csv) ・ [冷凍サイクルの結果](Resources/Reference/adiabatic_cycle.csv)

以下の単体試験と損失内訳は熱連成版のものです。

## 単体試験の実行

`AirConditionerCycle.Examples.RotaryCompressorStandalone` をOMEditで実行します。吸入側は圧力と過熱度を指定するリザーバ、吐出側は背圧を指定するリザーバです。圧縮機内部では11部品の状態を解きます。吐出側リザーバの比エンタルピー設定は逆向きに供給する流体の値で、順方向の吐出温度は圧縮機の出口状態から計算します。

| 設定項目 | R134a の既定値 |
|---|---:|
| `suctionPressure`（吸入絶対圧力） | 0.374627 MPa、飽和温度 7 °C に相当 |
| `suctionSuperheat`（吸入過熱度） | 5 K、入口温度 12 °C |
| `dischargePressure`（吐出絶対圧力） | 1.159924 MPa、飽和温度 45 °C に相当 |
| `speed`（回転数指令） | 50 rev/s（3,000 rpm） |
| `ambientTemperature`（シェル周囲温度） | 35 °C |

運転中の状態を初期条件とし、0.23 s を 25 µs 間隔で出力します。`compressor.accumulator.inletCheckValve=true` により、アキュームレータ入口の差圧がゼロ以下になると入口流量をゼロにします。吸入流量と吐出流量の瞬時差は、圧縮機内の冷媒保有量の変化です。`compressor.cylinder.pocketA.p`、`compressor.reed.lift`、`dischargeFlow`、`compressor.P_el` を同じ時間軸でプロットすると、作動室の圧力上昇から吐出までを追えます。

パラメータを変更する例として、R134a の吸入圧力を 0.400 MPa、吐出圧力を 1.250 MPa、吸入過熱度を 8 K、回転数指令を 55 rev/s に設定しました。0.23 s で12回転を完了し、最後の1回転の平均電力は 0.964 kW、平均吐出流量は 0.02604 kg/s でした。

他の冷媒は `Examples.RefrigerantTests` の各 `Standalone` 例を使います。R290・R32・R410A は R134a と同じ飽和温度・過熱度で、それぞれの冷媒の境界圧力を計算します。CO₂ は飽和温度 −10／8 °C に対応する吸入／吐出圧力、入口温度 −5 °C、シェル周囲温度 −10 °C の設定です。

展開した `AirConditionerCycle` ディレクトリで次のコマンドを実行すると、最初の行は R134a のみ、2行目は5冷媒で単体試験を実行します。結果は最後に完了した1回転の平均と圧縮機の質量・エネルギー収支です。[単体例題のソース](Examples/RotaryCompressorStandalone.mo) ・ [単体試験の集計CSV](Resources/Reference/standalone_compressors.csv)

```sh
python Resources/Scripts/run_standalone_tests.py
python Resources/Scripts/run_standalone_tests.py --fluid all --csv standalone.csv
```

## 損失評価

R134a の単体例は `AirConditionerCycle.Examples.RotaryCompressorLossTest` です。`Examples.RefrigerantTests` の `R290LossTest`、`R32LossTest`、`R410ALossTest`、`CO2SubcriticalLossTest` は、各冷媒の単体試験の境界条件を引き継ぎます。既存の単体例では `useDetailedLosses=true`、閉回路の `Examples.RotaryCooling` では `cycle.compressor.useDetailedLosses=true` で同じ機能を使えます。基本設定では第9章の一定モーター効率式、新しい設定では巻線銅損・鉄損の式を使います。

| 見たい量 | OMEdit で選ぶ変数（単体例） |
|---|---|
| モーター・機械の瞬時損失合計 [W] | `compressor.losses.motorLoss`、`compressor.losses.mechanicalLoss` |
| 項目別の瞬時／直前1回転平均 [W] | `compressor.losses.power`／`meanPower` を展開し、`copper`、`iron`、`auxiliary`、`bearing`、`vane`、`oilFilm` を選択 |
| 吸入・吐出・室間漏れの圧損仕事率近似 [W] | 同じ配列の `suctionDrop`、`dischargeDrop`、`leakageDrop` |
| 図示動力・筐体放熱・電気入力・理想動力 [W] | 同じ配列の `indicated`、`shellHeat`、`electric`、`isentropic` |
| 室間漏れ絶対値の平均 [kg/s] | `compressor.losses.meanLeakRate` |
| 吐出質量基準の体積効率、電気入力基準の等エントロピー効率 | `compressor.losses.volumetricEfficiency`、`compressor.losses.isentropicEfficiency` |

回転平均は第1回転完了時から更新されます。短時間では圧縮機内のガス保有量や蓄熱も変わります。圧損仕事率は各部の上流体積流量×差圧で、冷媒の流れにすでに反映された圧損の規模を示します。電気入力を配分するときは、図示動力、モーター損失、機械摩擦、機構の蓄積変化を使います。シェル放熱の正方向は外気側です。

対象機に合わせる際は `compressor.motor` の一相抵抗・トルク定数・基準鉄損、`compressor.shaft` の運転時油粘度・膜厚・内半径を設定します。巻線温度はシェル壁温で近似し、油膜はローラの公転すべりによる両端面の粘性せん断を扱います。別の試験から求めた軸受摩擦係数を使う場合は、その係数が端面損失を含むか確認してください。

| 調整する量 | パラメータ（例題の `compressor` 以下） | 既定値 |
|---|---|---:|
| 相抵抗・トルク定数 | `motor.phaseResistance20`、`motor.torqueConstant` | 0.32 Ω／相、0.45 N·m/A |
| 基準鉄損・基準回転数 | `motor.hysteresisReference`、`motor.eddyReference`、`motor.ironReferenceSpeed` | 12 W、8 W、50 rev/s |
| 一定付帯損失 | `motor.idleLoss` | 18 W |
| 油粘度・片側膜厚・ローラ内半径 | `shaft.oilViscosity`、`shaft.filmThickness`、`shaft.boreRadius` | 0.012 Pa·s、12 µm、9 mm |
| 軸受摩擦・粘性抵抗 | `shaft.bearingFriction`、`shaft.viscous` | 0.11 N·m、0.00008 N·m·s/rad |
| ベーン摩擦・粘性抵抗・先端すきま | `vane.slidingFriction`、`vane.damping`、`vane.tipGap` | 3 N、1.6 N·s/m、3 µm |

パッケージのディレクトリで以下を実行すると、5冷媒の単体試験と、各回転平均・圧縮機全体・機械駆動系の収支検査を再現できます。`--fluid R134a` でR134aだけを試験できます。

```sh
python Resources/Scripts/run_standalone_tests.py --losses --fluid all --csv compressor_losses.csv
```

[物理方程式（第14～16章）](PhysicalEquations.md) ・ [5冷媒の損失・効率と収支残差](Resources/Reference/compressor_losses.csv)

## 部品と接続

冷媒は **アキュームレータ → 吸入管 → シリンダ → 吐出リード弁 → 吐出マフラ → 高圧シェル → 吐出管** の順に流れます。モーター、偏心軸、ローラ、ベーンは機械コネクターで接続し、ローラの容積変化とシリンダの圧力を介して軸仕事を伝えます。配管、機械、熱、制御の接続は `Components.Rotary.RollingPistonCompressor` のダイアグラムで開けます。

| 部品 | インスタンス名 | 計算内容 |
|---|---|---|
| アキュームレータ | `accumulator` | 容器内の質量・内部エネルギー、気液平衡、液の保持量。上部から、二相時は飽和蒸気、乾き運転時は容器内の蒸気を取り出す |
| 吸入管 | `suctionPipe` | 内径・長さ・局部損失係数から求める圧力損失 |
| シリンダ・吸入ポート | `cylinder` | 作動室 A・B の質量とエネルギー、吸入ポート流量、ベーンすきまを通る室間漏れ、壁との熱交換 |
| 吐出リード弁 | `reed` | 差圧と開弁圧から求めた目標リフトへの二次応答。有効開口面積と上流状態から正方向の吐出流量を計算 |
| 吐出マフラ | `muffler` | 膨張室の圧縮性と出口絞りによる圧力脈動の減衰 |
| 高圧シェル | `shell` | 高圧ガスの蓄積、筐体の熱容量、ガスとの熱交換、モーター・摺動部からの受熱、外気への放熱 |
| 吐出管 | `dischargePipe` | シェル出口から冷凍サイクルの高圧ポートまでの圧力損失 |
| モーター | `motor` | 回転子の慣性、PI 速度制御、トルク上限、電気入力、モーター損失 |
| 偏心軸・軸受 | `shaft` | 偏心量、軸トルク伝達、軸受の摩擦トルクと発熱 |
| ローラ | `roller` | 偏心円の幾何から計算する作動室容積、ベーン先端位置、圧力による負荷トルク |
| ベーン | `vane` | ローラに追従する往復質量、押付けばね、摺動摩擦、先端すきまによる有効漏れ面積 |

作動室 A・B は、一つのシリンダ内でベーンとローラの接点が区切る二つの空間です。一方が吸入中に他方が圧縮・吐出を行います。一回転が終わると両室の役割が入れ替わります。各室の質量・エネルギーを連続して追跡するので、すきま容積に残った吐出ガスの再膨張も波形に現れます。

## 設定と交換方法

| 変更箇所 | 初期設定 |
|---|---:|
| 回転数指令 `speed` | 50 rev/s（3,000 rpm） |
| シリンダ内半径／偏心量／シリンダ高さ | 24／4.5／45.5 mm |
| 幾何から得られる押しのけ容積 | 27.98 cm³/rev |
| 各作動室のすきま容積比 `roller.clearanceRatio` | 0.025 |
| ベーンの有効先端すきま `vane.tipGap` | 3 µm |
| 開弁差圧／最大リフト `reed.crackingPressure`・`reed.liftMax` | 4.5 kPa／1.0 mm |
| アキュームレータ／吐出マフラ／高圧シェルのガス側内容積 | 550／85／850 cm³ |
| シェル周囲温度 `shell.Tambient` | 35 °C |

寸法・摩擦・漏れ・熱伝達・弁特性は代表値です。吸入ポートとリード弁は正方向のノズル近似、配管は集中圧損、マフラは単一容積として扱います。リード弁の運動は有効質量・ばね・減衰に集約しています。油の影響は有効すきまと摩擦係数に含める想定です。シェル周囲温度は独立したパラメータで設定できます。

標準の `Examples.RatedCooling` は従来の `DisplacementCompressor` を使います。同じ冷凍回路に詳細モデルを組み込む指定は次の通りです。

```modelica
extends AirConditionerCycle.Examples.RatedCooling(
  cycle(redeclare model Compressor =
    AirConditionerCycle.Components.Rotary.RollingPistonCompressor));
```

## 波形を確認する

`Examples.RotaryCooling` は室内 25 °C、外気 35 °C、運転中の軸速度・圧力を初期条件として、0.21 秒を 25 µs 間隔で出力します。DASSL の内部ステップは可変です。次の変数は OMEdit のプロット画面で選べます。

| 見たい量 | 変数 |
|---|---|
| 同じ作動室の圧力–容積ループ | パラメトリックプロットの X に `cycle.compressor.roller.a.V`、Y に `cycle.compressor.cylinder.pocketA.p` |
| 弁を開く差圧と開閉波形 | `cycle.compressor.reed.inlet.p`、`cycle.compressor.muffler.gas.p`、`cycle.compressor.reed.lift` |
| 弁直後と吐出管での流量 | `cycle.compressor.reed.m_flow`、`cycle.compressor.dischargePipe.m_flow` |
| 液戻りと蓄液量 | `cycle.compressor.accumulator.liquidMass`、`cycle.compressor.accumulator.quality` |
| 直前に完了した一回転の平均 | `meanPower`（W）、`meanDelivery`（kg/s）。値は一回転ごとに更新 |

圧力・容積のループは、一つの作動室が吸入から圧縮・吐出までをたどる **二回転** で閉じます。短時間試験の平均値は、この初期条件での軸周期の値です。長時間の熱平衡性能や実機の定格性能を評価する際は、対象機の寸法と試験値で校正してください。

[作動室圧力・リード弁の波形](Resources/Reference/rotary_waveform.png) ・ [完了した最後の二回転の CSV](Resources/Reference/rotary_revolutions.csv)

## テスト結果

OpenModelica 1.27.2、Modelica 4.1.0、ExternalMedia 4.1.1、Linux x86-64 で以下を確認しました。

- **冷凍回路への組み込み**　0.21 秒間に10回転が完了しました。10回転目の平均消費電力は **807.9 W**、吐出管の平均流量は **0.02183 kg/s** です。最後の二回転の作動室 A の圧力範囲は絶対圧 **0.358～1.454 MPa**、リード弁の最大リフトは **1.000 mm** でした。
- **保存則**　圧縮機単体と冷凍回路全体で冷媒質量・エネルギー収支を検査しました。全回路では電気入力、筐体放熱、室内外の熱移動を積分し、冷媒、回転子、ベーン、筐体、熱交換器の蓄積エネルギー変化と比較しました。出力時刻での最大エネルギー残差は **0.007 J 未満**でした。
- **アキュームレータ単体**　`Examples.AccumulatorWetInlet` で乾き度 0.80 の冷媒を供給し、0.012 kg/s で蒸気を取り出しました。0.5 秒で容器内の液量は **2.463 g から 3.979 g** に増加し、各出力時刻の出口比エンタルピーが出口圧力の飽和蒸気値と一致しました。
- **既存モデル**　標準圧縮機の定格運転・外気温上昇、および一定流量圧縮機への差し替えの3例を各600秒再実行しました。[既存3例の結果・全5例の再実行方法](README.md)
