# ノーベルコンプレッサー

## 一体ブレードと揺動ブッシュ

単気筒・断熱の角度分解モデルです。ローラとブレードを一体の剛体とし、偏心軸が一回転する間の吸入、圧縮、吐出を追跡します。ブレードは固定中心を持つブッシュの溝を往復し、同時にブッシュとともに傾きます。ブレードとローラの間に接触線や先端すきまを設ける必要がありません。

![一体ローラとブッシュの位置関係](Resources/Reference/nobel_geometry.png)

O はシリンダ中心、C はローラ中心、B はブッシュ中心、K はローラと内壁の最近接点です。線分 CB がブレードの方向を決めます。三日月状の空間を CB 上のブレードと K で二つの作動室に分けます。図の色は1回転中の室の役割を示します。

- **PistonBlade（一体ローラ・ブレード）** が偏心軸角からブレード位置・角度・二室の容積を計算します。容積ポートで受けた室圧、摺動力、揺動トルクを軸トルクに換算します。[Modelica](Components/Rotary/Nobel/PistonBlade.mo)
- **SwingBush（揺動ブッシュ）** が並進フランジでブレードの相対摺動、回転フランジでブッシュの揺動を受け、両者の摩擦と揺動慣性を計算します。共通回路内のインスタンス名は `vane` です。[Modelica](Components/Rotary/Nobel/SwingBush.mo)
- **NobelCompressor（完成圧縮機）** は一体ローラとブッシュを二つのフランジで接続します。冷媒はアキュームレータ、吸入管、シリンダ、吐出リード弁、マフラ、高圧プレナム、吐出管の順に流れます。[Modelica](Components/Rotary/NobelCompressor.mo)

## 機構と作動室容積の式

シリンダ半径を $R$、偏心量を $e$、ローラ半径を $r=R-e$、高さを $H$ とします。ブッシュ中心は固定点 $(B,0)$ で、$B=R+\text{pivotOffset}$ です。軸角 $\theta$ の原点はローラと内壁の最近接点がブッシュ側に来る位置です。ローラ中心、中心間距離、揺動角、相対摺動変位は次式です。

$$
\begin{aligned}
 C &= (e\cos\theta,e\sin\theta),\\
 D &= \sqrt{(B-e\cos\theta)^2+(e\sin\theta)^2},\\
 \beta &= \operatorname{atan2}(-e\sin\theta,B-e\cos\theta),\qquad x=D-(B-e).
\end{aligned}
$$

摺動ストロークは $2e$、最大揺動角は $\arcsin(e/B)$ です。$q=B\sin\beta$ と置くと、ローラ中心からブレード中心線とシリンダ内壁の交点までの距離は $L=\sqrt{R^2-q^2}-B\cos\beta+D$ です。外周円弧・ローラ円弧・ブレード中心線で囲まれた断面積に高さを掛けて、吸入側の掃引容積 $S$ を求めます。$\alpha$ は現在の回転内の軸角（0～$2\pi$）です。

$$
S=\frac{H}{2}\left[(R^2-r^2)(\alpha-\beta)
   +R^2\arcsin(q/R)+Lq\right],\qquad V_d=\pi H(R^2-r^2).
$$

死容積 $V_c=0.025V_d$ の既定値では、吸入側が $V_c+S$、圧縮側が $V_c+V_d-S$ です。1回転ごとに室 A と B の役割を交代し、容積と各室の冷媒状態を連続に保ちます。共通部品 `PartialChamberGeometry` が回転数、役割の交代、二室の容積・容積速度を管理します。[共通の容積機構](Components/Rotary/BaseClasses/PartialChamberGeometry.mo)

## 軸動力、損失、漏れ

フランジの座標には $x$ と $\beta$ を使います。軸角微分は $x'=Be\sin\theta/D$、$\beta'=(e^2-Be\cos\theta)/D^2$ です。$F$ と $T$ をブッシュ側に入る力とトルクとすると、機構が軸に要求するトルクは次式です。$V_A'$ は室 A の容積を軸角で微分した値です。

$$
\tau_{\mathrm{shaft}}=-(p_A-p_B)V_A'+F x'+T\beta'.
$$

速度 $v=\dot x$、揺動角速度 $\omega_b=\dot\beta$ に対して、摺動力、揺動摩擦トルク、ブッシュ側トルク、散逸動力は次式です。速度の反転で摩擦が連続に切り替わるよう双曲線正接を使います。

$$
\begin{aligned}
 F &= c_xv+F_c\tanh(v/v_0), & v_0&=0.02\;\mathrm{m/s},\\
 T_f &= c_b\omega_b+T_c\tanh(\omega_b/\omega_0), & \omega_0&=1\;\mathrm{rad/s},\\
 T &= J_b\dot\omega_b+T_f, &
 P_{\rm slide}&=Fv,\qquad P_{\rm pivot}=T_f\omega_b.
\end{aligned}
$$

一体ピストンの自転とブッシュの揺動は同じ角速度で、合成慣性の蓄積エネルギーは $J_b\omega_b^2/2$ です。一体ピストンの重心をローラ中心に置く近似を用い、公転の慣性は駆動側の等価慣性に含める想定です。損失集計の `Channel.vane` に摺動・揺動の摩擦動力の和が入り、断熱モデルの `driveLoss` から機外へ散逸します。[共通の案内機構ポート](Components/Rotary/BaseClasses/PartialBladeGuide.mo)

各作動室について $d m_i/dt=\sum\dot m_{i}$、$d U_i/dt=\sum\dot m_i h_{\rm up}-p_i\dot V_i$ を解き、ExternalMedia から冷媒物性を取得します。一体ブレードの先端漏れは常にゼロです。A・B 間の漏れはローラ外周・上端面・下端面の符号付き和で、各経路が上流のエンタルピーを運びます。外周・端面のガス流量式は共通シリンダの薄いすきま流れに従います。[すきまの流量式](PhysicalEquations.md#シリンダの半径すきまと端面すきま)

ブレード厚さ、背室圧力、ブレード側面・ブッシュ外周から背室へ至る漏れ、油と冷媒の二相漏れは省略しています。摩擦力とトルクの係数は一定で、差圧によるブッシュ荷重との連成は今後の精密化の対象です。

## 実行例と検証

OMEdit で `AirConditionerCycle/package.mo` を開きます。**Examples → CompressorTests → NobelStandalone** が圧縮機単体、**Examples → CoolingCycles → NobelCooling** が冷房サイクルです。単体例では `compressor.roller.beta` が揺動角 [rad]、`compressor.vane.slideLoss` と `pivotLoss` が各摩擦動力 [W]、`dischargeFlow` が吐出管出口の流量 [kg/s] です。サイクル例の `meanDelivery` と `meanPower` は完了した直前1回転の平均です。[単体例](Examples/CompressorTests/NobelStandalone.mo)・[サイクル例](Examples/CoolingCycles/NobelCooling.mo)

既定は R134a、回転数指令 3,000 rpm。単体例の吸入・吐出の飽和温度は 7 °C、45 °C、吸入過熱度は 5 K です。CO₂ は亜臨界の −10 °C、8 °C を使用します。例題の仮定寸法は $R=24$ mm、$e=4.5$ mm、$H=45.5$ mm、$B=27$ mm です。行程容積は 27.98 cm³/rev、摺動ストロークは 9.0 mm、最大揺動角は 9.59° です。外周・上下の有効気体すきまは 5・8・8 µm です。

例題では摺動摩擦力 3 N、摺動粘性 1.6 N·s/m、揺動摩擦トルク 0.015 N·m、揺動粘性 0.0001 N·m·s/rad、合成揺動慣性 $2.5\times10^{-5}$ kg·m² を仮定しています。流量と電力は短時間計算の最終完了回転平均で、寸法と係数は実機データでの同定を要します。

### シミュレーション結果

OpenModelica 1.27.2、Modelica 4.1.0、ExternalMedia 4.1.1。各単体例を 0.23 s 実行し、質量収支、全エネルギー収支・断熱ガス収支、作動室容積の独立した多角形計算、ブレードの運動、摩擦の符号と集計、漏れの内訳を照合しました。

| 冷媒 | 完了回転数 | 吐出流量 [g/s] | 電力 [W] | 吐出温度 [°C] |
|---|---:|---:|---:|---:|
| R134a | 11 | 22.32 | 793.5 | 61.7 |
| R290 | 11 | 15.49 | 1007.5 | 61.1 |
| R32 | 11 | 33.23 | 2001.9 | 90.2 |
| R410A | 11 | 46.30 | 1912.5 | 73.9 |
| CO₂ | 10 | 81.83 | 2667.2 | 34.7 |

CO₂ は既定のモータートルク上限 8 N·m に達し、最終完了回転は約 2,734 rpm です。

R134a の冷房サイクル例は 0.21 s で10回転を完了し、第10回転の吐出量は 21.90 g/s、電力は 793.4 W でした。回路全体のエネルギー収支の最大残差は 0.0053 J です。[単体5冷媒の数値・残差](Resources/Reference/nobel_standalone.csv)

試験を再実行するには、パッケージのディレクトリで次のコマンドを実行します。全5冷媒の単体例と R134a 冷房サイクル例が対象です。

```sh
python Resources/Scripts/run_nobel_tests.py --fluid all
```
