# 空調用冷凍サイクルの物理方程式

**AirConditionerCycle 1.4.0　技術資料**

この資料は、冷媒状態から冷房能力と消費電力を求める式、およびローリングピストン式圧縮機の軸運動から吐出流量を求める式を、Modelica のクラスに対応づけたものです。標準圧縮機と詳細圧縮機は同じ冷凍回路に接続できます。

| 調べたい内容 | 章 |
|---|---|
| 圧力・流量・熱量の符号、冷房 COP、冷媒の状態点 | 1 |
| 蒸発器・凝縮器の蓄積、標準圧縮機と膨張弁 | 2・3 |
| ExternalMedia の物性、R410A の微分、圧力と比エンタルピーを状態に選ぶ理由 | 4 |
| ロータリーの冷媒流路、ローラの幾何、圧力・容積変化 | 5–8 |
| モーター、偏心軸、ベーンの力・トルク・損失 | 9 |
| 圧縮機と回路全体の保存則、1回転の平均 | 10 |
| 冷媒別の初期化、実行例、試験条件と照合結果 | 11・12 |
| 圧縮機単体のリザーバ境界、入口逆止弁、開回路での試験 | 13 |
| モーター・摩擦・流路の損失、モデルの校正、5冷媒の損失評価 | 14–16 |

**単位と添字**　圧力 $p$ は絶対圧 [Pa]、温度 $T$ は [K]、比エンタルピー $h$ は [J/kg]、密度 $\rho$ は [kg/m³]、容積 $V$ は [m³]、エネルギーは [J]、熱流率・動力は [W] です。上付きの点は時間微分、$l,v$ は飽和液・飽和蒸気を表します。$\operatorname{clip}(z,a,b)=\min(b,\max(a,z))$ とします。$T$ の差は K と °C で同じ値です。

**モデルと資料の対応**　章末に実装ファイルを挙げています。パッケージ内の編集用 Markdown では、そのリンクから各クラスを開けます。例題名の先頭には `AirConditionerCycle.Examples.` が付きます。圧縮機の内部部品は `Components/Rotary/`、内部の共通式は `Components/Rotary/BaseClasses/` にあります。

計算環境は OpenModelica 1.27.2、Modelica Standard Library 4.1.0、ExternalMedia 4.1.1（CoolProp 7.2.0）です。掲載した性能は代表寸法と設定値によるシミュレーション結果です。

![偏心ローラの断面と2回転分の作動室容積](Resources/Reference/rotary_geometry.png)

**図1**　断面は標準寸法から描画し、室 A・B の容積は R134a の計算結果から最後の2回転を抜き出しました。第6章の幾何式で同じ波形を再現できます。

## 1　回路・コネクター・状態点

冷媒は、**①圧縮機入口 → ②圧縮機出口 → ③凝縮器出口 → ④膨張弁出口 → 蒸発器 → ①** の順に循環します。蒸発器の液体体積率を膨張弁の制御入力に戻します。室内空気は蒸発器、室外空気は凝縮器の熱ポートにつなぎます。

### 冷媒・熱・機械の接続条件

冷媒には Modelica.Fluid の流体ポートを使います。各部品の流量 [kg/s] は**流入が正**です。入口を $j_i$、出口を $j_o$ と書きます。`PartialTwoPort` での変数名は `inlet.m_flow` と `outlet.m_flow` です。順方向運転では $j_i\geq0,\ j_o\leq0$、正の吐出流量は $-j_o$ です。蓄積容積を持つ部品では $j_i+j_o$ が部品内の質量変化率になります。

| 接続 | 一致する量 | 接続点で満たす式 |
|---|---|---|
| 冷媒ポート | 圧力 $p$ | $\sum_k j_k=0$。流入比エンタルピーは `inStream` が接続先の流出値から決定 |
| 熱ポート | 温度 $T$ | $\sum_j \dot Q_j=0$。$\dot Q_j$ は各部品への入熱 |
| 回転／並進フランジ | 軸角 $\phi$／変位 $x$ | $\sum_j\tau_j=0$／$\sum_j F_j=0$ |
| 可動容積 `VolumePort` | 容積 $V$ | $\sum_j e_j=0$。気体側 $e=-p$、機構側 $e=+p$。ポートへの仕事率は $e\dot V$ |

成分輸送の独立変数と微量成分はともにゼロ（`nXi=nC=0`）です。`PartialCompressor` はこの二ポートに電力出力 `P_el` を加えます。詳細圧縮機の外部ポートでは内部配管の流出状態をそのまま使用します。

### 状態点と観測量

$p_L=p_1=p_4,\ p_H=p_2=p_3$。高低圧は熱交換器の蓄積状態から決まります。$h_1$ は圧縮機の流入値、$h_2,h_3,h_4$ は各機器の流出値です。$T_i=T(p_i,h_i)$、$x_4=\mathrm{vapourQuality}(p_L,h_4)$ を ExternalMedia で評価します。熱交換器の出口過熱・過冷却は第2章の境界式で与えます。

$$
\dot Q_{\rm cool}=\dot Q_{\rm room},\qquad
\dot Q_{\rm rej}=-\dot Q_{\rm outdoor},\qquad
{\rm COP}=\begin{cases}\dot Q_{\rm cool}/P_{\rm el}&P_{\rm el}>0\\0&P_{\rm el}\leq0.\end{cases}
$$

`Q_rejected` は凝縮器から外気への放熱です。詳細圧縮機のシェル放熱は第10章で別項に数えます。COP の分母は圧縮機の電力です。空気側は乾き空気の顕熱交換を扱い、機器間を結ぶ冷媒ポートは圧力損失ゼロの接続です。

**実装**　[CoolingCycle.mo](CoolingCycle.mo) ・ [PartialTwoPort.mo](Interfaces/PartialTwoPort.mo) ・ [PartialCompressor.mo](Interfaces/PartialCompressor.mo) ・ [VolumePort.mo](Components/Rotary/BaseClasses/VolumePort.mo)

## 2　蒸発器と凝縮器の質量・エネルギー収支

`PartialHeatExchanger` は、一定容積 $V$ 内に圧力 $p$ の飽和液と飽和蒸気が共存する集中定数モデルです。入口・出口・内部の圧力は等しく、壁温は代表飽和温度 $T_s(p)$ に追従します。未知数は主に $p$ と液質量 $m_l$ です。液体体積率 $\alpha$ は蒸気の**質量**割合である乾き度 $x$ と区別します。

$$
\begin{aligned}
\alpha&=\frac{m_l}{V\rho_l}, &m_v&=V(1-\alpha)\rho_v,& M&=m_l+m_v,\\
U&=m_lh_l+m_vh_v-pV+C(T_s-273.15),&&&
\dot Q_a&=G(T_a-T_s).
\end{aligned}
$$

$U$ は冷媒内部エネルギーと壁の顕熱の合計、$C$ は壁熱容量、$G$ は空気との熱コンダクタンスです。係数のプライムは飽和線に沿った $d/dp$ です。実装では $m_v$ 用の微分補助変数 `dmV` を使い、次の3本を連立します。

$$
\begin{aligned}
\dot m_l+\dot m_v&=j_i+j_o,\\
\frac{\dot m_l}{\rho_l}+\frac{\dot m_v}{\rho_v}
&=\left(\frac{m_l\rho_l'}{\rho_l^2}+\frac{m_v\rho_v'}{\rho_v^2}\right)\dot p,\\
h_l\dot m_l+h_v\dot m_v+
(m_l h_l'+m_v h_v'-V+C T_s')\dot p
&=\dot Q_a+j_i h_i+j_o h_o .
\end{aligned}
$$

2本目は $V=m_l/\rho_l+m_v/\rho_v$ の時間微分、3本目は $\dot U$ の展開です。$j_o<0$ なので、出口が持ち去るエンタルピーは右辺から差し引かれます。初期条件は $p(0)=p_{\rm sat}(T_{\rm start})$、$m_l(0)=\alpha_0 V\rho_l(p(0))$。両方の相が残る $0<\alpha<1$ が成立条件です。

| 実装と出口状態 | $V$ [L] | $G$ [W/K] | $C$ [J/K] | $\alpha_0$ |
|---|---:|---:|---:|---:|
| 蒸発器 `Evaporator`　$h_1=h(p_L,T_{s,L}+\Delta T_{\rm sh})$ | 1.5 | 165 | 9,500 | 0.20 |
| 凝縮器 `Condenser`　$h_3=h(p_H,T_{s,H}-\Delta T_{\rm sc})$ | 1.2 | 365 | 14,000 | 0.45 |

過熱度 $\Delta T_{\rm sh}$ と過冷却度 $\Delta T_{\rm sc}$ はそれぞれ 5 K です。過熱・過冷却は出口状態に課し、保有冷媒には飽和物性を用います。蒸発器は $\text{level}=\alpha$ を出力します。過渡時の冷房能力は空気側の $G(T_{\rm room}-T_{s,L})$ であり、冷媒のエンタルピー輸送と蓄熱の両方が収支に入ります。

**実装**　[PartialHeatExchanger.mo](Components/PartialHeatExchanger.mo) ・ [Evaporator.mo](Components/Evaporator.mo) ・ [Condenser.mo](Components/Condenser.mo)

## 3　標準圧縮機・一定流量圧縮機・膨張弁

### 押しのけ容積と等エントロピー効率

`DisplacementCompressor` は吸入密度 $\rho_1=\rho(p_L,h_1)$ から冷媒質量流量を決めます。$N$ は毎秒回転数、$V_d$ は1回転当たりの押しのけ容積です。`PartialIsentropicCompressor` が出口状態と仕事を決めます。

$$
\begin{aligned}
j_i=-j_o=\dot m &=\eta_v V_dN\rho_1,\\
s_1 &=s(p_L,h_1),& h_{2s}&=h(p_H,s_1),\\
h_2 &=h_1+(h_{2s}-h_1)/\eta_{\rm is},\\
P_{\rm shaft}&=\dot m(h_2-h_1),&
P_{\rm el}&=P_{\rm shaft}/\eta_m .
\end{aligned}
$$

$h_{2s}$ は `Medium.isentropicEnthalpy` の値です。標準値は $V_d=28$ cm³/rev、$N=50$ rev/s、体積効率 $\eta_v=0.80$、等エントロピー効率 $\eta_{\rm is}=0.72$、モーター効率 $\eta_m=0.90$。圧縮機での蓄積はゼロ、$p_H>p_L$ を要求します。モーター損失 $P_{\rm el}-P_{\rm shaft}$ は冷媒の外へ放散します。

一定流量型の `FixedFlowCompressor` は同じ圧縮式を継承し、流量を $\dot m=\dot m_{\rm set}=0.016$ kg/s に固定します。例題 `CompressorReplacement` はこの組合せで回路の差し替えを試験します。詳細圧縮機の場合、流量と吐出状態は作動室と弁の時間発展から決まります（第5–10章）。

R134a の定格例では、600 s で $\dot m=0.01988$ kg/s、$h_1=407.16$、$h_2=440.88$ kJ/kg です。軸動力は $0.01988(440.88-407.16)=0.670$ kW、電力は $0.670/0.90=0.745$ kW。室内からの吸熱 2.996 kW を用いると冷房 COP は約 4.02 です。

### 膨張弁と蒸発器液位のフィードバック

蒸発器の液量が少なくなると開度 $u$ が増加します。$u_b$ は基準開度、$K_\alpha$ は比例ゲインです。上流密度は凝縮器**出口状態** $(p_H,h_3)$ で求めます。

$$
\begin{aligned}
u&=\operatorname{clip}\{u_b+K_\alpha(\alpha_{\rm set}-\alpha),0,1\},\\
\Delta p&=p_H-p_L,\qquad
j_i=-j_o=C_d A_{\max}u\sqrt{2\rho(p_H,h_3)\max(\Delta p,0)},\\
h_4&=h_3 .
\end{aligned}
$$

$A_{\max}=1.5$ mm²、$C_d=0.72$、$u_b=0.5$、$K_\alpha=4$、$\alpha_{\rm set}=0.20$。断熱絞りとして流量を準定常で求め、質量・エネルギーは蓄積しません。運転中は $\Delta p>0$ を検査します。

**実装**　[DisplacementCompressor.mo](Components/DisplacementCompressor.mo) ・ [PartialIsentropicCompressor.mo](Components/PartialIsentropicCompressor.mo) ・ [FixedFlowCompressor.mo](Examples/FixedFlowCompressor.mo) ・ [ExpansionValve.mo](Components/ExpansionValve.mo)

## 4　冷媒物性と共通の容積モデル

### ExternalMedia / CoolProp

`Media.R134a`、`R290`、`R32`、`CO2` は対応する CoolProp 流体を指定します。`setState_ph(p,h)` で状態を定め、$\rho,T$ と密度の偏微分を取得します。熱交換器とアキュームレータは `setSat_p(p)` の液側（bubble）・蒸気側（dew）の密度、比エンタルピーを用います。

`Media.R410A` は CoolProp の擬似純物質 R410A と固定組成を使い、熱交換器は単一の代表飽和温度で解きます。同じ飽和相関から蓄積量とその圧力微分を求めるため、この冷媒だけ次の補正を施します。

$$
\delta p=\min(10^{-5}p,(p_c-p)/4),\qquad
f'(p)\simeq\frac{f(p+\delta p)-f(p-\delta p)}{2\delta p},
\quad f\in\{T_s,\rho_l,\rho_v,h_l,h_v\}.
$$

$p_c$ は臨界圧力です。$\delta p>0$ のときだけ該当する5個の導関数を置き換えます。これは飽和線に沿う圧力微分で、次の式の一定 $p$ または一定 $h$ での密度偏微分とは別の量です。

### 固定容積と可動容積

`VolumeState` は一様な $(p,h)$ を持つ容積です。$S_m$ [kg/s] は正味流入質量流率、$H_f$ [W] は正味のエンタルピー輸送、$\dot Q_g$ は冷媒への入熱です。気体が外部にする境界仕事を $p\dot V$ とすると、

$$
M=\rho(p,h)V,\quad U=Mh-pV,\qquad
\dot M=S_m,\qquad \dot U=H_f+\dot Q_g-p\dot V .
$$

この2本の保存則を実装が積分する $p,h$ の形に書き直すと、

$$
V\left[\left(\frac{\partial\rho}{\partial p}\right)_h\dot p+
\left(\frac{\partial\rho}{\partial h}\right)_p\dot h\right]+\rho\dot V=S_m,
\qquad M\dot h-V\dot p=H_f-hS_m+\dot Q_g .
$$

`FixedVolume` は $\dot V=0,\ S_m=j_i+j_o,\ H_f=j_i h_i+j_o h_o$ を与え、アキュームレータ・マフラ・シェルが継承します。`GasPocket` は `VolumePort` で $V$ を受け、気体側の `effort` を $-p$ とします。シリンダが $\dot V,S_m,H_f,\dot Q_g$ を供給します。どちらも $p(0)=p_{\rm start},\ h(0)=h_{\rm start}$ を固定します。

**実装**　[VolumeState.mo](Components/Rotary/BaseClasses/VolumeState.mo) ・ [FixedVolume.mo](Components/Rotary/BaseClasses/FixedVolume.mo) ・ [GasPocket.mo](Components/Rotary/BaseClasses/GasPocket.mo) ・ [R410A.mo](Media/R410A.mo) ・ [R134a.mo](Media/R134a.mo) ・ [R290.mo](Media/R290.mo) ・ [R32.mo](Media/R32.mo) ・ [CO2.mo](Media/CO2.mo)

## 5　アキュームレータ、吸入管、吐出管

### アキュームレータの液保持と上部蒸気取り出し

`Accumulator` は 550 cm³ の断熱・固定容積です。容器圧力を $p_g$、内部の平均比エンタルピーを $h_g$ とします。入口絞りの有効面積 $A_i=65$ mm²、平滑化幅 $\delta=40$ Pa に対して、

$$
\begin{aligned}
R(z,\delta)&=\frac{z}{(z^2+\delta^2)^{1/4}},\\
j_i&=A_i\sqrt{2\rho(p_i,h_i)}\,R(p_i-p_g,\delta),\quad
p_o=p_g,\quad \dot Q_g=0 .
\end{aligned}
$$

$R$ は Modelica.Fluid.Utilities の `regRoot` です。差圧ゼロ付近の傾きを有限にし、正の大きな差圧では平方根に近づきます。平衡乾き度、保持液質量、流出する冷媒の状態は、

$$
x=\operatorname{clip}\!\left(\frac{h_g-h_l(p_g)}{h_v(p_g)-h_l(p_g)},0,1\right),
\qquad M_l=M(1-x),\qquad h_o=\max\{h_g,h_v(p_g)\}.
$$

二相の間は飽和蒸気が上部から流出し、過熱状態では内部の $h_g$ が流出します。容器内の全質量・内部エネルギーは第4章の式で積分します。気相を確保するため $h_g>h_l(p_g)$ を要求します。この取り出し則は気液平衡と上部取り出しを仮定しています。

### 吸入管と吐出管の圧力損失

`SuctionPipe` と `DischargePipe` は共通の `Pipe` を継承します。Darcy 摩擦係数 $f_D$ と局部損失係数 $K$ を用いる集中圧損です。$\epsilon_m=10^{-4}$ kg/s はゼロ流量付近の平滑化の幅です。

$$
\begin{aligned}
A&=\pi D^2/4,\qquad \dot m=j_i=-j_o,\qquad h_o=h_i,\\
p_i-p_o&=\left(f_D\frac{L}{D}+K\right)
\frac{\dot m\sqrt{\dot m^2+\epsilon_m^2}}{2\rho(p_i,h_i)A^2}.
\end{aligned}
$$

| 区間 | $L$ [m] | 内径 $D$ [mm] | $f_D$ | $K$ |
|---|---:|---:|---:|---:|
| アキュームレータ出口 → シリンダ吸入口 | 0.16 | 12 | 0.025 | 1.2 |
| 高圧シェル出口 → 圧縮機の外部吐出ポート | 0.20 | 8 | 0.025 | 1.8 |

両管とも断熱で、流体の蓄積と管内の波動伝播を省略します。吸入側ではアキュームレータ入口と吸入管のそれぞれに圧力損失が生じます。

**実装**　[Accumulator.mo](Components/Rotary/Accumulator.mo) ・ [Pipe.mo](Components/Rotary/BaseClasses/Pipe.mo) ・ [SuctionPipe.mo](Components/Rotary/SuctionPipe.mo) ・ [DischargePipe.mo](Components/Rotary/DischargePipe.mo)

## 6　ローラの幾何、作動室容積、圧力トルク

`Roller` はシリンダ半径 $R=24$ mm、偏心量 $e=4.5$ mm、高さ $H=45.5$ mm の偏心円から容積を計算します。ローラ半径 $r=R-e$、押しのけ容積 $V_d=\pi H(R^2-r^2)=27.98$ cm³/rev、各室のすきま容積 $V_c=cV_d$（$c=0.025$）です。幾何条件は $0<e<R/2$ です。

### 軸角から吸入側の掃引容積へ

正回転する連続軸角を $\phi$ [rad]、完了回転数を $n=\lfloor\phi/(2\pi)\rfloor$、回転内の角度を $\theta=\phi-2\pi n$ とします。ベーン中心線上のローラ半弦 $b$、シリンダ中心からローラ表面までの距離 $r_b$、ベーン変位 $x$ は、

$$
b=\sqrt{r^2-e^2\sin^2\phi},\quad r_b=e\cos\phi+b,\quad
x=R-r_b,\quad \frac{dx}{d\phi}=e\sin\phi\left(1+\frac{e\cos\phi}{b}\right).
$$

三日月状の断面をその回転の始点から積分した容積 $S$（`swept`）と、その角度微分 $D$ は、

$$
\begin{aligned}
S&=\frac{H}{2}\left[(R^2-r^2)\theta-\frac{e^2}{2}\sin(2\phi)
-e\sin\phi\,b-r^2\arcsin\left(\frac{e\sin\phi}{r}\right)\right],\\
D&=\frac{\partial S}{\partial\theta}=\frac{H}{2}(R^2-r_b^2).
\end{aligned}
$$

### 室の役割の切り替えと仕事

| $n$ の偶奇 | 吸入室／圧縮・吐出室 | $V_A$ | $D_A=\partial V_A/\partial\phi$ |
|---|---|---|---|
| 偶数（`fillingA=true`） | A／B | $V_c+S$ | $+D$ |
| 奇数（`fillingA=false`） | B／A | $V_c+V_d-S$ | $-D$ |

$$
\begin{aligned}
V_B&=2V_c+V_d-V_A,\qquad \dot V_A=D_A\dot\phi,\qquad \dot V_B=-\dot V_A,\\
\tau_{\rm roller}&=-(p_A-p_B)D_A-F_{\rm follower}\,\frac{dx}{d\phi}.
\end{aligned}
$$

$\tau_{\rm roller}$ と $F_{\rm follower}$ はローラの各フランジへの作用です。最終式に角速度を掛けると、軸・ベーンでの仕事と両作動室の $p\dot V$ が釣り合います。一回転で $S$ が $V_d$ から 0 に戻る瞬間に A・B の役割も反転するため、各室の容積と冷媒状態は連続です。個々の室は二回転で吸入・圧縮・吐出を一巡します。

**実装**　[Roller.mo](Components/Rotary/Roller.mo) ・ [GasPocket.mo](Components/Rotary/BaseClasses/GasPocket.mo)

## 7　シリンダの吸入、室間漏れ、各室の収支

### 吸入・漏れ・吐出弁に共通のノズル式

`massFlux` の $G$ は上流圧力 $p_u$、下流圧力 $p_d$、上流密度 $\rho_u$ による**単位有効面積当たり**の順方向流束 [kg/(m²·s)] です。一定の比熱比 $\gamma=1.12$ を使う圧縮性ノズル近似に、各冷媒の実在流体密度を与えます。

$$
\begin{aligned}
r_*&=(2/(\gamma+1))^{\gamma/(\gamma-1)},&
q&=\operatorname{clip}(p_d/p_u,r_*,1),\\
B&=\max\!\left(0,\frac{2\rho_u p_u\gamma}{\gamma-1}
q^{2/\gamma}\left[1-q^{(\gamma-1)/\gamma}\right]\right),&
G&=\frac{B}{\sqrt{B+G_0^2}} .
\end{aligned}
$$

$G_0=1$ kg/(m²·s) はゼロ差圧近傍の平滑化流束です。$p_d/p_u\leq r_*$ でチョークし、$p_d\geq p_u$ で $G=0$ になります。吸入口の有効面積 $A_s=95$ mm² に対して、$j_i=A_sG(p_i,p_{\rm fill},\rho_i)$。入口の逆流は生じません。

### 作動室 A・B の入出流

$\ell$ は A→B を正とする漏れ流量 [kg/s]、$H_\ell$ は同じ向きのエンタルピー輸送 [W] です。$A_\ell$ はベーンから受け取る有効先端すきま面積です。

$$
\ell=A_\ell
\begin{cases}
G(p_A,p_B,\rho_A)&p_A\ge p_B,\\
-G(p_B,p_A,\rho_B)&p_A<p_B,
\end{cases}
\qquad H_\ell=\ell
\begin{cases}h_A&\ell\ge0,\\ h_B&\ell<0.\end{cases}
$$

外部ポートから各室に入る質量・比エンタルピーの組を $(j_A,h_{e,A})$ と $(j_B,h_{e,B})$ とします。圧縮室の状態をリード弁入口に渡します。

| 吸入室 | $(j_A,h_{e,A})$ | $(j_B,h_{e,B})$ | $(p_{\rm fill},p_o,h_o)$ |
|---|---|---|---|
| A | $(j_i,h_i)$ | $(j_o,h_B)$ | $(p_A,p_B,h_B)$ |
| B | $(j_o,h_A)$ | $(j_i,h_i)$ | $(p_B,p_A,h_A)$ |

$$
\begin{aligned}
S_{m,A}&=j_A-\ell, & H_{f,A}&=j_A h_{e,A}-H_\ell,\\
S_{m,B}&=j_B+\ell, & H_{f,B}&=j_B h_{e,B}+H_\ell,\\
\dot Q_k&=G_w(T_w-T_k),\quad k=A,B, &
\dot Q_{\rm wall,port}&=\dot Q_A+\dot Q_B .
\end{aligned}
$$

各室は第4章の可動容積式を解きます。$\dot V_A,\dot V_B$ は第6章、壁温 $T_w$ はシェルと共通で $G_w=0.45$ W/K（各室）です。漏れは両室を合計すると質量・エネルギー収支から相殺されます。

**実装**　[Cylinder.mo](Components/Rotary/Cylinder.mo) ・ [massFlux.mo](Components/Rotary/BaseClasses/massFlux.mo) ・ [GasPocket.mo](Components/Rotary/BaseClasses/GasPocket.mo)

## 8　吐出リード弁・吐出マフラ・高圧シェル

### 吐出リード弁のリフトと流量

弁孔径 $d=9$ mm、投影面積 $A_p=\pi d^2/4$、開弁差圧 $p_{\rm cr}=4.5$ kPa とします。圧縮室からマフラへの差圧 $\Delta p=p_i-p_o$ に応じて目標リフト $y_*$ を計算し、実リフト $y$ を二次系で追従させます。

$$
\begin{aligned}
y_*&=\operatorname{clip}((\Delta p-p_{\rm cr})A_p/k,0,y_{\max}),\\
m_r\ddot y&=k(y_*-y)-2\zeta\sqrt{k m_r}\,\dot y,\\
A_{\rm eff}&=C_d\min(A_p,\pi d\,\operatorname{clip}(y,0,y_{\max})),\\
j_i&=-j_o=A_{\rm eff}G(p_i,p_o,\rho_i),\qquad h_o=h_i.
\end{aligned}
$$

$m_r=0.18$ g、$k=3800$ N/m、$\zeta=1$、$y_{\max}=1.0$ mm、$C_d=0.78$、$y(0)=\dot y(0)=0$。上限は目標リフトと開口面積に適用します。弁座への衝突や反発を解く式は含みません。ノズルの流量条件により、弁が閉じる途中でも逆差圧時の流量はゼロです。

### 吐出マフラ

容積 85 cm³ の断熱膨張室に第4章の固定容積式を適用します。出口有効面積 $A_e=45$ mm²、容器密度 $\rho_g$、流出量 $q_o=-j_o$ とすると、

$$
p_i=p_g,\qquad h_o=h_g,\qquad p_g-p_o=\frac{q_o|q_o|}{2\rho_g A_e^2},\qquad\dot Q_g=0.
$$

吐出弁からのパルス流で室内の質量・圧力が変動し、出口絞りを通じて高圧シェルに流れます。音響管路は集中容積と抵抗に集約しています。

### 高圧シェルのガスと壁

固定容積は 850 cm³、$p_i=p_o=p_g,\ h_o=h_g$。壁温 $T_w$ とガス温度 $T_g$ を別々に解き、筐体熱容量 $C_w=1100$ J/K、ガス側 $G_g=8$ W/K、外気側 $G_a=1.8$ W/K を使います。

$$
\dot Q_g=G_g(T_w-T_g),\quad \dot Q_a=G_a(T_w-T_a),\quad
C_w\dot T_w=\dot Q_{\rm wall,port}-\dot Q_g-\dot Q_a .
$$

ここで $\dot Q_a$ は筐体から外気への放熱 `Q_ambient` が正です。熱ポートへの正味入熱は、モーター・軸受・ベーンの損失熱からシリンダ両室へ渡す熱を引いた値です。ガスの出口は第5章の吐出管につながります。

**実装**　[DischargeReed.mo](Components/Rotary/DischargeReed.mo) ・ [Muffler.mo](Components/Rotary/Muffler.mo) ・ [Shell.mo](Components/Rotary/Shell.mo)

## 9　モーター、偏心軸、ベーン

以下の電力・摩擦式は基本設定です。`useDetailedLosses=true` で変更する項を第14章に示します。

### モーターの速度制御と慣性

$\omega=\dot\phi$、速度誤差 $e_\omega=2\pi N-\omega$、積分トルク $I$ とすると、トルク上限付き PI 制御と運動方程式は、

$$
\begin{aligned}
\tau_r&=K_p e_\omega+I,&
\tau_d&=\operatorname{clip}(\tau_r,0,\tau_{\max}),&
\dot I&=(K_p e_\omega+\tau_d-\tau_r)/T_i,\\
J\dot\omega&=\tau_d+\tau_{\rm port},&
P_{\rm mech}&=-\tau_{\rm port}\omega,&
E_r&=J\omega^2/2,\\
P_{\rm el}&=P_0+\tau_d\omega/\eta_m,&
\dot Q_{\rm motor,port}&=\tau_d\omega-P_{\rm el}.&&
\end{aligned}
$$

$\tau_{\rm port}$ は軸からモーターへ作用するトルクです。$P_{\rm mech}$ は接続軸に渡す動力で、加速時は電磁トルクの仕事の一部が回転子に蓄積します。$J=0.0015$ kg·m²、$K_p=0.12$ N·m·s/rad、$T_i=0.025$ s、$\tau_{\max}=8$ N·m、$\eta_m=0.91$、$P_0=18$ W。初期条件は $\phi(0)=0,\ \omega(0)=2\pi N,\ I(0)=2.3$ N·m です。

### 偏心軸と軸受

軸角は $\phi_{\rm drive}=\phi_{\rm crank}$。軸受の摩擦トルクと熱ポートは次式です。回転慣性はモーターの $J$ に集約します。

$$
\tau_f=\tau_b\tanh(\omega/\omega_0)+b_\omega\omega,\quad
\tau_{\rm drive}+\tau_{\rm crank}=\tau_f,\quad
\dot Q_{\rm shaft,port}=-\tau_f\omega .
$$

$\tau_b=0.11$ N·m、$b_\omega=8.0\times10^{-5}$ N·m·s/rad、$\omega_0=1$ rad/s。偏心量はローラの幾何に渡します。

### ベーンの追従力、摩擦、漏れ面積

ローラが `tip.s` の変位 $x$ を拘束し、ベーンが次の反力を返します。$v=\dot x$、$x_f$ はばね力がゼロになる伸び位置です。

$$
\begin{aligned}
F_f&=b_v v+F_s\tanh(v/v_0),&
F_{\rm tip}&=m_v\dot v+k_v(x-x_f)+F_f,\\
E_v&=\tfrac12 m_vv^2+\tfrac12 k_v(x-x_f)^2,&
\dot Q_{\rm vane,port}&=-F_fv,\qquad A_\ell=H g_{\rm tip}.
\end{aligned}
$$

この式の $m_v$ はベーン質量 9 g です。$k_v=1600$ N/m、$x_f=16$ mm、$b_v=1.6$ N·s/m、$F_s=3$ N、$v_0=0.02$ m/s。先端すきま $g_{\rm tip}=3$ µm と高さ $H=45.5$ mm から室間漏れ面積を定めます。ベーンの接触を幾何で拘束し、油膜の効果は有効すきま・摩擦係数に集約しています。

**実装**　[Motor.mo](Components/Rotary/Motor.mo) ・ [EccentricShaft.mo](Components/Rotary/EccentricShaft.mo) ・ [Vane.mo](Components/Rotary/Vane.mo)

## 10　圧縮機全体の保存則と1回転平均

`RollingPistonCompressor` は11部品の組立モデルです。冷媒はアキュームレータ → 吸入管 → シリンダ → 吐出リード弁 → マフラ → シェル → 吐出管を通ります。モーターと偏心軸がローラを駆動し、ローラは容積ポートでシリンダと、並進フランジでベーンと結合します。

### 蓄積量を測る境界

圧縮機内に冷媒が蓄積する5容積の集合を $\mathcal C=\{\text{accumulator}, A,B,\text{muffler},\text{shell}\}$ とします。`charge` は5容積の冷媒質量、`E` はそれらの内部エネルギー、シェル壁、ベーン、回転子に蓄えたエネルギーの和です。$E_v,E_r$ の定義は第9章です。

$$
\begin{aligned}
M_c&=\sum_{k\in\mathcal C} M_k,\\
E_c&=\sum_{k\in\mathcal C} U_k+C_w(T_w-273.15)+E_v+E_r,\\
\dot M_c&=j_i+j_o,\\
\dot E_c&=j_i h_1+j_o h_2+P_{\rm el}-\dot Q_{\rm amb}.
\end{aligned}
$$

ここで $j_i,j_o$ は圧縮機**外部**のポート流量です。リード弁運動は開口の制御に使う近似で、弁体の動力・蓄積を冷媒や軸の収支に結合していません。配管と絞りにも保有量を持たせていません。

蒸発器・凝縮器の蓄積を $U_e,U_d$、充填量を $M_e,M_d$ とします。閉回路の境界まで広げると、内部のエンタルピー輸送が相殺されます。

| 圧縮機 | 保存される冷媒質量 | 回路全体のエネルギー変化率 |
|---|---|---|
| 標準・一定流量 | $M_e+M_d$ | $d(U_e+U_d)/dt=\dot Q_{\rm cool}-\dot Q_{\rm rej}+P_{\rm shaft}$ |
| 詳細ロータリー | $M_e+M_d+M_c$ | $d(U_e+U_d+E_c)/dt=\dot Q_{\rm cool}-\dot Q_{\rm rej}+P_{\rm el}-\dot Q_{\rm amb}$ |

熱交換器壁の顕熱は既に $U_e,U_d$ に含みます。標準型に入力する仕事は冷媒に渡る軸動力、詳細型では筐体と駆動部も境界の内側にあるため電気入力を使います。

### 軸1回転の平均電力と吐出量

`RotaryCooling` は電気入力と外部吐出流量を積分します。回転番号が変わる時刻を $t_n$、$\Delta t_n=t_n-t_{n-1}$ とすると、完了した回転の表示値は、

$$
\overline P_n=\frac{1}{\Delta t_n}\int_{t_{n-1}}^{t_n}P_{\rm el}\,dt,\qquad
\overline{\dot m}_n=\frac{1}{\Delta t_n}\int_{t_{n-1}}^{t_n}(-j_o)\,dt .
$$

`meanPower`・`meanDelivery` は一回転が終わるごとに更新され、次の更新まで保持されます。期間平均の軸速度は $60/\Delta t_n$ rpm です。リード弁直後の瞬時流量と外部吐出流量の差は、下流のマフラとシェルの蓄積に現れます。

**実装**　[RollingPistonCompressor.mo](Components/Rotary/RollingPistonCompressor.mo) ・ [RotaryCooling.mo](Examples/RotaryCooling.mo) ・ [rotary_checks.py](Resources/Scripts/rotary_checks.py)

## 11　初期条件と実行例

### 冷媒別の初期化

`RefrigerantTests.StandardCase` は室内を 25 °C に固定し、冷媒と外気温、蒸発・凝縮の初期飽和温度 $T_{e0},T_{d0}$ を設定します。初期液体体積率は全冷媒で同じなので、初期充填**質量**は冷媒ごとに変わります。

`RefrigerantTests.RotaryCase` は、運転中の軸速度と各部の初期冷媒状態を設定します。次の $h_S,h_D$ は初期値の計算に用います。回転中の吐出比エンタルピーは第4–9章の式で決まります。

$$
\begin{aligned}
p_{L0}&=p_{\rm sat}(T_{e0}),\quad p_{H0}=p_{\rm sat}(T_{d0}),\\
h_S&=h(p_{L0},T_{e0}+\Delta T_{\rm sh}),\quad
h_D=h_S+\frac{h(p_{H0},s(p_{L0},h_S))-h_S}{0.72}.
\end{aligned}
$$

アキュームレータは $(0.989p_{L0},h_S)$、室 B は $(0.988p_{L0},h_S)$、室 A・マフラ・シェルは各高圧側倍率に $p_{H0}$ を掛け、比エンタルピーを $h_D$ とします。吸入管出口とシリンダ入口の `p(start=...)` は $0.989p_{L0}$ の初期推定値です。高圧側の倍率は **室 A／マフラ／シェル** の順です。

| 冷媒 | 外気 [°C] | $T_{e0}/T_{d0}$ [°C] | 初期高圧側倍率 | 初期シェル壁温 |
|---|---:|---|---|---|
| R290・R410A | 35 | 7／45 | 1.013／1.011／1.004 | 57 °C |
| R32 | 35 | 7／45 | 1.030／1.025／1.012 | $T(p_{H0},h_D)$ |
| CO₂ | −10 | −10／8 | 1.030／1.025／1.012 | $T(p_{H0},h_D)$ |

実行例の接頭辞は `R290`、`R32`、`R410A`、`CO2Subcritical` です。末尾が `Standard` の例は標準圧縮機、`Rotary` の例は詳細ロータリー圧縮機を使います。

R134a の `RotaryCooling` は各部品の既定値を使用します。初期 $(p,h)$ を [kPa, kJ/kg] で表すと、アキュームレータ (370.5, 407.25)、室 A (1175, 445)、室 B (370, 407.2)、マフラ (1173, 443)、シェル (1164.5, 444)。壁温は 57 °C です。

### 境界条件を変更する例

`RatedCooling` は室内・室外を 25／35 °C に固定します。`OutdoorTemperatureRamp` は時刻 $t$ [s] に対し、$T_a=308.15+5\,\operatorname{clip}((t-120)/120,0,1)$ [K] とします。`CompressorReplacement` は同じ温度境界で第3章の一定流量圧縮機を使用します。

`AccumulatorWetInlet` は単体試験です。供給圧力 $p_f=375$ kPa、供給乾き度 $x_f=0.80$、$h_f=(1-x_f)h_l(p_f)+x_fh_v(p_f)$ とし、この $h_f$ を容器の初期比エンタルピーにも設定します。下流から 0.012 kg/s の蒸気を取り出し、保持液が増えることを調べます。

**実装**　[RefrigerantTests.mo](Examples/RefrigerantTests.mo) ・ [RatedCooling.mo](Examples/RatedCooling.mo) ・ [OutdoorTemperatureRamp.mo](Examples/OutdoorTemperatureRamp.mo) ・ [CompressorReplacement.mo](Examples/CompressorReplacement.mo) ・ [AccumulatorWetInlet.mo](Examples/AccumulatorWetInlet.mo)

## 12　試験結果と方程式の照合

室内は全例 25 °C。標準型は600秒時点の冷房能力と COP、ロータリー型は完了した10回転目の期間平均を示します。R134a・R290・R32・R410A のロータリー試験は 0.21 s、CO₂ は 0.23 s です。表の電力はロータリー型の値です。

| 冷媒 | 外気 [°C] | 標準・冷房 [kW] | 標準・COP | ロータリー・電力 [kW] | ロータリー・吐出 [kg/s] |
|---|---:|---:|---:|---:|---:|
| R134a | 35 | 2.996 | 4.023 | 0.808 | 0.02183 |
| R290 | 35 | 3.479 | 3.364 | 1.018 | 0.01551 |
| R32 | 35 | 4.779 | 2.179 | 1.956 | 0.03318 |
| R410A | 35 | 4.509 | 2.249 | 1.873 | 0.04539 |
| CO₂ | −10 | 8.561 | 1.935 | 2.556 | 0.08151 |

CO₂ の臨界温度は 30.9782 °C です。凝縮器内の気液共存を前提とするため、外気 35 °C では CO₂ が凝縮して外気へ放熱する条件が成立しません。表の CO₂ は低外気温の亜臨界試験です。ロータリー型の10回転目の平均は 2,757 rpm で、標準型の設定回転数は 3,000 rpm です。短時間のロータリー結果は初期状態近傍の軸周期を表します。

### 何を検査したか

エネルギー残差は $R_E(t)=E(t)-E(0)-\int_0^t\dot E_{\rm boundary}\,dt$ とし、第10章の境界ごとに評価します。積分は出力時刻での台形則です。ソルバーは DASSL、許容誤差 $10^{-7}$。標準型の出力間隔は R134a が 2 s、追加4冷媒が 0.5 s、詳細型は 25 µs です。

- **回路の質量とエネルギー**　追加4冷媒の標準型で総質量変化の絶対値の最大は $3.63\times10^{-7}$ kg、最大エネルギー残差は 2.43 J（ともに CO₂）。判定値は $10^{-6}$ kg、12 J です。R410A では第4章の微分を用いて、それぞれ $2.06\times10^{-8}$ kg、0.66 J でした。
- **ロータリーの運動と収支**　全5冷媒で10回転を完了。各回転でリード弁のリフトが 0.4 mm を超え、0.05 mm を下回ること、および逆流防止を確認しました。両室の総容積は一定で、圧縮機単体と全回路のエネルギー残差はともに判定値 0.12 J 以内でした。
- **境界条件・機器単体**　R134a で外気温を 40 °C に上げた例は 600 s 時点で COP 3.500、一定流量圧縮機への差し替え例は 4.811。湿り吸入試験では 0.5 s で保持液が 2.463 g から 3.979 g へ増加し、出口比エンタルピーは飽和蒸気値に一致しました。

検査の対象は方程式の保存則とモデルの応答です。実機の性能曲線への校正、空気側の湿分・着霜、R410A の組成変化、CO₂ 遷臨界運転はこの試験の対象外です。再現には同梱の `Resources/Scripts/run_tests.py` と `run_refrigerant_tests.py` を使用できます。

**試験記録**　[R134a の結果](Resources/Reference/results.csv) ・ [ロータリーの波形](Resources/Reference/rotary_revolutions.csv) ・ [追加4冷媒の結果](Resources/Reference/refrigerants.csv) ・ [冷媒別の実行手順](RefrigerantTests.md)

## 13　詳細圧縮機の単体運転

`RotaryCompressorStandalone` は第5–10章の11部品を備える圧縮機を、圧力境界の間で運転する例です。左の吸入境界からアキュームレータへ流れ、吐出管から右の背圧境界へ流れます。標準の境界クラスは両側とも `Modelica.Fluid.Sources.Boundary_ph` です。

### 指定する量と計算する量

外部の吸入・吐出圧力を $p_s,p_d$、吸入過熱度を $\Delta T_s$ とすると、吸入境界は $p_s$ と次の $h_s$ を与えます。吐出境界は $p_d$ を与え、圧縮機が吐出比エンタルピー $h_o$ と流量 $-j_o$ を決めます。

$$
T_{\rm in}=T_{\rm sat}(p_s)+\Delta T_s,\qquad h_s=h(p_s,T_{\rm in}),\qquad
T_{\rm out}=T(p_d,h_o),\qquad \dot m_{\rm out}=-j_o .
$$

吐出側リザーバの設定エンタルピーはリザーバから出る流体に用いる値です。順方向に運転するときの $T_{\rm out}$ は `dischargeTemperature`、$\dot m_{\rm out}$ は `dischargeFlow` で確認できます。吸入・吐出流量は各瞬間で異なり、その差が圧縮機内の冷媒質量を変えます。

この例ではアキュームレータ入口の逆止弁を有効にします。第5章の入口流量式に $\Delta p_+=\max(0,p_s-p_g)$ を用いると、$p_g\geq p_s$ で吸入は一時的に止まります。圧縮機部品の既定設定は `inletCheckValve=false` です。

$$
j_i=A_i\sqrt{2\rho(p_s,h_s)}\,R(\Delta p_+,40\,{\rm Pa}),\quad
\dot M_c=j_i+j_o,\quad
\dot E_c=P_{\rm el}-\dot Q_{\rm amb}+j_i h_s+j_o h_o .
$$

### 初期状態と実行条件

吸入ガスの初期比エンタルピーを $h_s$、吐出側初期値を $h_D=h_s+[h(p_d,s(p_s,h_s))-h_s]/0.72$ とします。アキュームレータと室 B の初期圧力はそれぞれ $0.989p_s,0.988p_s$、室 A・マフラ・シェルは $1.030p_d,1.025p_d,1.012p_d$。シェル壁温は $T(p_d,h_D)$ に初期化します。運転中は作動室と機構の式から状態が進みます。

既定の R134a は $p_s=0.374627$ MPa、$p_d=1.159924$ MPa、$\Delta T_s=5$ K、$T_{\rm in}=12$ °C、回転数指令 50 rev/s、シェル周囲 35 °C です。追加冷媒の例は `RefrigerantTests` 内にあり、CO₂ には −10／8 °C の飽和圧力を使います。出力間隔は 25 µs、計算時間は 0.23 s です。第10章の1回転平均と上の開回路収支を、シミュレーションの出力から積分して検査します。

単体試験で完了した最後の1回転の平均を示します。CO₂ の圧力条件とシェル周囲温度は第11章の亜臨界試験に合わせています。

| 冷媒 | 完了回転数 | 平均電力 [kW] | 平均吐出流量 [kg/s] | 平均吐出温度 [°C] |
|---|---:|---:|---:|---:|
| R134a | 11 | 0.808 | 0.02257 | 61.8 |
| R290 | 11 | 1.018 | 0.01572 | 61.1 |
| R32 | 11 | 1.954 | 0.03377 | 90.2 |
| R410A | 11 | 1.874 | 0.04702 | 74.0 |
| CO₂ | 10 | 2.578 | 0.08493 | 34.7 |

**実装と結果**　[RotaryCompressorStandalone.mo](Examples/RotaryCompressorStandalone.mo) ・ [RefrigerantTests.mo](Examples/RefrigerantTests.mo) ・ [単体試験の集計](Resources/Reference/standalone_compressors.csv)

## 14　モーターと摺動部の損失

`RollingPistonCompressor.useDetailedLosses=true` で損失を個別に解きます。`Motor` の回転慣性・PI制御、`EccentricShaft` の軸受摩擦、`Vane` の摺動摩擦は第9章の式です。相電流と回転数からモーターの発熱を求め、ローラ端面油膜の反力を軸のトルク収支に加えます。

### 電気入力から電磁動力へ

三相平衡を仮定します。$K_T$ は相電流実効値あたりのトルク定数、$\tau_d$ は電磁トルク、$T_w$ はシェル壁温 [K] です。巻線抵抗には、この壁温を巻線温度の近似として用います。

$$
\begin{aligned}
I_{\rm rms}&=\tau_d/K_T, & R_{\rm ph}&=R_{20}[1+\alpha_R(T_w-293.15)],\\
P_{\rm Cu}&=3R_{\rm ph} I_{\rm rms}^2, &
u&=|\omega|/(2\pi N_{\rm ref}),\\
P_{\rm Fe}&=P_{h,\rm ref}u+P_{e,\rm ref}u^2, &
P_{\rm el}&=\tau_d\omega+P_{\rm Cu}+P_{\rm Fe}+P_0 .
\end{aligned}
$$

磁束を一定とし、ヒステリシス損は回転数に比例、渦電流損は回転数の二乗に比例とします。既定値は $K_T=0.45$ N·m/A、$R_{20}=0.32$ Ω/相、$\alpha_R=0.00393$ $\mathrm{K}^{-1}$、$N_{\rm ref}=50$ rev/s、$P_{h,\rm ref}=12$ W、$P_{e,\rm ref}=8$ W。$P_0=18$ W は一定の付帯損失です。`motor.heat.Q_flow` は $-(P_{\rm Cu}+P_{\rm Fe}+P_0)$ で、これらの損失はシェル壁に流入します。

### 機械摩擦からシェル発熱へ

ローラの両端面と固定板の間に一様な油膜を仮定します。片面の環状面積 $A=\pi(r_o^2-r_i^2)$、油粘度 $\mu$、膜厚 $\delta$、公転によるすべり速度 $e|\omega|$ に対し、ニュートン流体のクエットせん断を面積積分すると、

$$
\tau_{\rm oil}=\frac{2\mu A e^2}{\delta}\,\omega,\quad
P_{\rm oil}=\tau_{\rm oil}\omega,\quad
P_{\rm mech,loss}=\tau_f\omega+F_fv+P_{\rm oil}.
$$

$r_o=R-e$（既定値 19.5 mm）、$r_i=9$ mm、$e=4.5$ mm、$\delta=12$ µm、$\mu=0.012$ Pa·s。$\tau_f,F_f$ は第9章の軸受摩擦トルクとベーン摩擦力です。$\tau_{\rm oil}$ を駆動軸の抵抗に、$P_{\rm oil}$ をシェル発熱に加えます。油膜式が扱う速度は公転成分です。ローラの自転、油の撹拌、油循環は個別の自由度を持ちません。

機種固有の校正には、抵抗測定とトルク・電流データ、速度別の無負荷損失、油の運転時粘度とすきま寸法を使います。軸受摩擦と端面摩擦は異なる摺動面に割り当てます。上記既定値は代表値です。

**実装**　[Motor.mo](Components/Rotary/Motor.mo) ・ [EccentricShaft.mo](Components/Rotary/EccentricShaft.mo) ・ [Vane.mo](Components/Rotary/Vane.mo)

## 15　圧損・室間漏れと圧縮機の動力収支

### 吸入側・吐出側の圧力損失

各絞り・配管について、質量流量 $\dot m\ge0$、上流密度 $\rho_u$、上流・下流圧 $p_u,p_d$ を用います。圧損の規模を電力と同じ単位で読むための診断量は、

$$
P_{\Delta p}^{*}=\frac{\dot m}{\rho_u}\max(p_u-p_d,0).
$$

`suctionDrop` はアキュームレータ入口絞り、吸入管、シリンダ吸入ポートの各値の和です。`dischargeDrop` はリード弁、マフラ出口絞り、吐出管の和です。各部で流量・密度を個別に求めるため、容器の充填・排出を含む過渡状態でも計算できます。圧縮性が強い流路では上流比容を代表値とする近似です。これらの値をエントロピー生成や追加の発熱には換算していません。

室間漏れはベーンすきまを通る双方向の流れです。$\ell>0$ は A→B、$\ell<0$ は B→A、$\rho_u$ はその瞬間に送り出す室の密度とします。

$$
P_\ell^*=\frac{|\ell|}{\rho_u}|p_A-p_B|,\qquad
\overline{\dot m_\ell}=\frac{1}{\Delta t}\int_{t_0}^{t_1}|\ell|\,dt .
$$

漏れによる質量・エンタルピーの移動は第7章の室収支に反映されます。絶対値の平均を使うため、A・B の役割交代で漏れが相殺されません。すきま容積に残るガスの再膨張は第6章の幾何と室圧で計算され、吐出質量と図示仕事に影響します。

### 電気入力の配分と効率

図示動力 $P_i=-p_A\dot V_A-p_B\dot V_B=-(p_A-p_B)\dot V_A$ は、機構が両室の冷媒へ行う正味の仕事率です。回転子、ベーン質量、押付けばねに蓄積されるエネルギーを $E_r+E_v$ とすると、

$$
P_{\rm el}=P_i+P_{\rm Cu}+P_{\rm Fe}+P_0+P_{\rm mech,loss}+\frac{d(E_r+E_v)}{dt}.
$$

流路抵抗、漏れ、熱交換は冷媒状態と図示仕事に影響します。上式に足す損失はモーターと機械の散逸です。`shellHeat` は筐体から周囲への符号付き放熱で、第10章の圧縮機全体の境界収支に使います。壁からシェルガスに移る熱は `shell.Q_gas`、各作動室に移る熱は `cylinder.pocketA.Q_flow` と `pocketB.Q_flow` です。

区間 $[t_0,t_1]$ は直前に完了した軸1回転です。$\dot m_o$ は正の外部吐出流量、$\rho_s$ は入口密度、$N=\omega/(2\pi)$、$\Delta h_s=h(p_d,s(p_s,h_s))-h_s$ とすると、

$$
\eta_v=\frac{\int\dot m_o\,dt}{\int\rho_s V_d N\,dt},\qquad
\eta_{\rm is,el}=\frac{\int\dot m_o\Delta h_s\,dt}{\int P_{\rm el}\,dt}.
$$

過渡運転では保有量と蓄熱の影響を含みます。効率と `meanPower` は最初の1回転完了後に更新されます。

**実装**　[LossReport.mo](Components/Rotary/LossReport.mo) ・ [RollingPistonCompressor.mo](Components/Rotary/RollingPistonCompressor.mo) ・ [pressureDropPower.mo](Components/Rotary/BaseClasses/pressureDropPower.mo)

## 16　損失評価を実行する

OMEdit で `AirConditionerCycle.Examples.RotaryCompressorLossTest` を開き、シミュレーションを実行します。`compressor.losses.meanPower` のチャネル名を選ぶと、直前に完了した1回転平均 [W] を表示できます。対応する瞬時値は `compressor.losses.power` にあります。冷媒別の境界条件は第13章と同じです。

| 冷媒 | 電気入力 [W] | モーター損失 [W] | 機械摩擦 [W] | 図示動力 [W] | 電気基準の効率 |
|---|---:|---:|---:|---:|---:|
| R134a | 792.3 | 69.4 | 50.5 | 672.3 | 68.7 % |
| R290 | 1002.2 | 88.1 | 50.5 | 863.5 | 72.7 % |
| R32 | 2011.0 | 245.6 | 50.5 | 1714.6 | 70.3 % |
| R410A | 1911.8 | 219.4 | 50.5 | 1641.6 | 69.4 % |
| CO₂ | 2683.8 | 355.4 | 46.1 | 2270.2 | 62.4 % |

固定吸吐出境界で0.23 s 運転し、最後に完了した1回転を比較しました。CO₂ は亜臨界の10回転目、他の4冷媒は11回転目です。表の各値は独立に丸めています。第15章の駆動収支には、一回転の間に残る回転子・ベーンの蓄積エネルギーの差も含まれます。

![R134a 単体試験の最後の1回転における動力と損失](Resources/Reference/rotary_losses_R134a.png)

**図2**　R134a の11回転目。横軸はその回転の開始からの経過時間です。負荷が高い区間では電磁トルクが増え、巻線銅損も増えます。軸受や端面油膜の損失は回転速度に応じて変化します。

R134a の内訳は、銅損31.42 W、鉄損20.00 W、付帯18.00 W、軸受42.45 W、ベーン4.32 W、油膜3.76 W。吸入・吐出・室間漏れの圧損仕事率近似はそれぞれ16.41／77.46／7.16 W、漏れ絶対値の回転平均は0.533 g/s、体積効率は90.4 %でした。巻線抵抗と油粘度をゼロにした対照計算では両項がゼロとなり、入力は792.26 W から757.08 W に変わりました。

既定の出力間隔は25 µs（許容誤差 $10^{-7}$）、CO₂ の損失例は質量収支を細かく検査するため12.5 µs（$3\times 10^{-8}$）です。各回転平均を出力波形から別途台形積分して照合し、質量、全圧縮機と駆動系のエネルギー収支を検査しました。5例での最大残差は冷媒質量 4.87e-08 kg、全圧縮機 0.0245 J、駆動系 0.00019 J でした。

**実装と結果**　[単体の損失例題](Examples/RotaryCompressorLossTest.mo) ・ [5冷媒の全チャネルと検査残差](Resources/Reference/compressor_losses.csv) ・ [再実行手順](RotaryCompressor.md#損失評価)
