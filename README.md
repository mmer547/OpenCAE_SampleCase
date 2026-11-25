# OpenCAE_SampleCase

OpenModelica と OpenFOAM のサンプルケース集です。モデル、実行スクリプト、計算条件はソフトウェア別にまとめています。

## OpenModelica

| ケース | 内容 |
| --- | --- |
| [AirConditionerCycle](OpenModelica/AirConditionerCycle/README.md) | 冷凍サイクルと圧縮機のモデル。必要なライブラリと実行手順はリンク先にあります。 |
| [Compression_Chamber](OpenModelica/Compression_Chamber/Compression_Chamber.mo) | 冷媒圧縮機の簡易1室モデル。[OMEdit での実行手順](OpenModelica/README.md) |
| [Oil_Circuit](OpenModelica/Oil_Circuit/OilCircuit.mo) | 油回路のモデル |

`AirConditionerCycle` に含まれる[ノーベル圧縮機](OpenModelica/AirConditionerCycle/NobelCompressor.md)と[スクロール圧縮機](OpenModelica/AirConditionerCycle/ScrollCompressor.md)の解説では、各モデルの構造と計算結果を確認できます。

## OpenFOAM

各ケースのディレクトリに計算条件と実行スクリプトを収録しています。

| ケース | 内容 |
| --- | --- |
| [AMI](OpenFOAM/AMI/) | AMI を用いたケース |
| [TwoMeshAMI](OpenFOAM/TwoMeshAMI/) | 2つのメッシュを AMI で接続するケース |
| [cfMeshAndMRFWithTopoSet](OpenFOAM/cfMeshAndMRFWithTopoSet/) | cfMesh と topoSet を用いた MRF のケース |
| [tetgen](OpenFOAM/tetgen/) | TetGen と autoPatch を用いたメッシュ作成のケース |
