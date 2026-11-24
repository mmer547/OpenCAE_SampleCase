# AirConditionerCycle

R134a を用いた空調機の冷房サイクルです。圧縮機 → 凝縮器 → 膨張弁 → 蒸発器 → 圧縮機の順に標準の冷媒ポートで接続しています。室内 25 °C、室外 35 °C の設定では、600 秒時点の冷房能力は 2.996 kW、圧縮機消費電力は 0.745 kW、冷房 COP は 4.023 です。

標準の押しのけ容積型に加え、11個の部品で組み立てたロータリー圧縮機を選べます。OMEdit で `AirConditionerCycle.Examples.RotaryCooling` を実行すると作動室圧力と吐出弁リフトを確認できます。内部配線は `Components.Rotary.RollingPistonCompressor` のダイアグラムにあります。[ロータリー圧縮機の部品・設定・試験結果](RotaryCompressor.md)

追加冷媒の実行例は `AirConditionerCycle.Examples.RefrigerantTests` にあります。R290・R32・R410A は外気 35 °C、CO₂ は外気 −10 °C の亜臨界条件を用います。[冷媒別の条件と試験結果](RefrigerantTests.md)

蒸発器・凝縮器の保存則、2種類の圧縮機、ロータリー圧縮機内部11部品の式は、各クラスの実装に対応づけています。[物理方程式の技術資料（PDF）](PhysicalEquations.pdf) ・ [編集用 Markdown](PhysicalEquations.md)

## 詳細圧縮機だけを実行する

OMEdit で `AirConditionerCycle/package.mo` を開き、**Examples → RotaryCompressorStandalone** を選んでシミュレーションを実行します。ダイアグラムは吸入リザーバ、11部品のロータリー圧縮機、吐出リザーバで構成されます。吸入圧力・過熱度・吐出背圧と回転数指令を変更すると、流量と消費電力の応答を調べられます。

既定は R134a です。他の冷媒は `Examples.RefrigerantTests` の `R290Standalone`、`R32Standalone`、`R410AStandalone`、`CO2SubcriticalStandalone` から選べます。試験時間は 0.23 s。プロットには `dischargeFlow`（kg/s）、`dischargeTemperature`（K）、`compressor.P_el`（W）、`compressor.reed.lift`（m）が使えます。[境界条件とコマンドラインでの再実行](RotaryCompressor.md#単体試験の実行)

## OMEdit で動かす

1. OpenModelica のライブラリマネージャーで **Modelica 4.1.0** と **ExternalMedia 4.1.1** をインストールします。OMShell を使う場合は下記のコマンドでも導入できます。ExternalMedia の公式配布 ZIP には CoolProp バックエンドのネイティブライブラリが入っています。[ExternalMedia 4.1.1 公式リリース](https://github.com/modelica-3rdparty/ExternalMedia/releases/tag/v4.1.1)
2. 本パッケージの ZIP を展開し、OMEdit の「モデル／ライブラリファイルを開く」で `AirConditionerCycle/package.mo` を開きます。
3. ライブラリブラウザーで `AirConditionerCycle.Examples.RatedCooling` を選び、「シミュレーション」を実行します。`cycle.Q_cooling`（W）、`cycle.P_el`（W）、`cycle.COP` が主要な結果です。
4. 配管図と機器アイコンは `AirConditionerCycle.CoolingCycle` のダイアグラムで確認できます。赤系の配管が高圧側、青系が低圧側、破線が蒸発器から膨張弁への液位信号です。

```modelica
updatePackageIndex();
installPackage(Modelica, "4.1.0");
installPackage(ExternalMedia, "4.1.1", exactMatch=true);
```

## 構成と適用範囲

| 機器 | モデル | 設定・計算法 |
|---|---|---|
| 圧縮機 | `Components.DisplacementCompressor` | 28 cm³/rev、3,000 rpm、体積効率 0.80。吸入密度から流量を求め、等エントロピー効率 0.72 とモーター効率 0.90 から吐出状態と消費電力を計算 |
| 凝縮器 | `Components.Condenser` | 冷媒容積 1.2 L、熱コンダクタンス 365 W/K、壁の熱容量 14 kJ/K、出口過冷却度 5 K |
| 膨張弁 | `Components.ExpansionValve` | 等エンタルピー絞り。蒸発器液位が下がると比例制御で弁を開き、開度、上流液密度、差圧から流量を計算 |
| 蒸発器 | `Components.Evaporator` | 冷媒容積 1.5 L、熱コンダクタンス 165 W/K、壁の熱容量 9.5 kJ/K、出口過熱度 5 K |

熱交換器では飽和液と飽和蒸気が共存する固定容積を仮定します。各相の質量、冷媒内部エネルギー、壁の顕熱を考慮して圧力と液量の時間変化を解きます。空気温度は標準の熱ポートから与えます。初期蒸発温度は 7 °C、初期凝縮温度は 45 °C、初期液体体積率は蒸発器 0.20、凝縮器 0.45 です。初期充填量はこれらの条件と各機器の容積で決まります。

`Q_cooling` は室内空気から取り去る熱量率、`Q_rejected` は室外空気への放熱量率です。COP は `Q_cooling / P_el` です。分母は圧縮機の電力のみで、標準の圧縮機ではモーター損失は冷媒の外に放散する想定です。ロータリー圧縮機ではシェルの熱収支に含めます。対象は亜臨界・正方向流れで両熱交換器に気液が共存する冷房運転です。サイクルの機器間配管は圧力損失をゼロとし、空気の除湿とファン電力は省略しています。ロータリー圧縮機の内部配管には圧力損失を設定しています。機器定数は実機データに合わせて変更できます。

## 圧縮機を差し替える

`CoolingCycle.Compressor` は `replaceable model` です。独自の圧縮機は `AirConditionerCycle.Interfaces.PartialCompressor` を継承し、質量収支、流量特性、吐出比エンタルピー `outlet.h_outflow`、消費電力 `P_el` を定義します。`inlet.p` と `outlet.p` は回路の圧力、`h_in` は吸入比エンタルピー、`m_flow` は入口質量流量です。同じ等エントロピー圧縮式を使う場合は `Components.PartialIsentropicCompressor` を継承して流量特性だけを実装できます。

次の例は、配管と温度境界を共用したまま圧縮機を一定流量型に差し替えます。`FixedFlowCompressor` の箇所を自作クラスの完全修飾名に変更すれば、そのクラスで実行できます。

```modelica
model MyCoolingTest
  extends AirConditionerCycle.Examples.RatedCooling(
    cycle(redeclare model Compressor =
      AirConditionerCycle.Examples.FixedFlowCompressor));
end MyCoolingTest;
```

## 標準圧縮機と一定流量圧縮機の実行結果

OpenModelica 1.27.2、Modelica 4.1.0、ExternalMedia 4.1.1（CoolProp 7.2.0）、Linux x86-64 で実行しました。ソルバーは DASSL、許容誤差は 1e-7、出力間隔は 2 秒です。表は 600 秒時点の値で、圧力は絶対圧です。

| 実行例 | 室内／室外 | 低圧／高圧 [MPa] | 冷房能力 [kW] | 圧縮機電力 [kW] | 冷房 COP |
|---|---|---:|---:|---:|---:|
| `RatedCooling` | 25／35 °C | 0.373／1.161 | 2.996 | 0.745 | 4.023 |
| `OutdoorTemperatureRamp` | 25／40 °C | 0.380／1.318 | 2.906 | 0.830 | 3.500 |
| `CompressorReplacement` | 25／35 °C、圧縮機流量 0.016 kg/s | 0.414／1.103 | 2.487 | 0.517 | 4.811 |

外気温を 120 秒から 240 秒の間に 35 °C から 40 °C へ上げると、凝縮圧力は熱交換器の蓄熱に伴って遅れて上昇します。600 秒時点の圧縮機電力は同じ圧縮機の定格ケースより約 86 W 大きくなります。[応答グラフ](Resources/Reference/outdoor_response.png) ・ [3ケースの時系列 CSV](Resources/Reference/results.csv)

定格運転の状態点番号は配管図に対応します。`cycle.T1` ～ `T4` と `cycle.h1` ～ `h4` をプロットできます。

| 点 | 位置 | 温度 [°C] | 比エンタルピー [kJ/kg] | 相 |
|---|---|---:|---:|---|
| 1 | 圧縮機入口 | 11.84 | 407.16 | 過熱蒸気 |
| 2 | 圧縮機出口 | 62.13 | 440.88 | 過熱蒸気 |
| 3 | 凝縮器出口 | 40.04 | 256.45 | 過冷却液 |
| 4 | 膨張弁出口 | 6.84 | 256.45 | 気液二相、乾き度 0.244 |

## テストを再実行する

`omc` と Python 3 が使える環境で、展開した `AirConditionerCycle` ディレクトリから実行します。Python の追加パッケージは不要です。

```sh
python Resources/Scripts/run_tests.py --csv results.csv --rotary-csv rotary_revolutions.csv
```

テストは全5例を一時ディレクトリでコンパイル・実行します。600秒の3例では、終了時刻、圧力、温度、等エンタルピー絞り、COP、差し替え後の流量を調べます。全出力時刻で、回路全体の冷媒質量と、蓄積エネルギーの変化も検査します。エネルギーの比較には「室内からの吸熱 − 室外への放熱 ＋ 冷媒に入る軸動力」を台形積分した値を使います。これらの3例で最大の質量ずれは 9.71 × 10⁻⁹ kg、積分誤差を含む最大エネルギー残差は 3.85 J 未満でした。ロータリー圧縮機の試験では回転ごとの弁開閉、質量・エネルギー収支、平均電力・吐出流量を確認します。湿り吸入試験では分離液量と蒸気出口状態を確認します。CSV 出力用の引数は任意です。

OpenModelica 1.27.2 は翻訳中に ExternalMedia 内の関数の pure／impure 宣言について警告を出します。全5例で初期化・シミュレーションが正常終了し、上記の検査に合格しました。
