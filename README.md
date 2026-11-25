# OpenCAE_SampleCase

OpenModelica と OpenFOAM のサンプルケース集です。モデル、実行スクリプト、計算条件はソフトウェア別にまとめています。

## OpenModelica

| ケース | 内容 |
| --- | --- |
| [AirConditionerCycle](OpenModelica/AirConditionerCycle/README.md) | 冷凍サイクルと圧縮機のモデル。必要なライブラリと実行手順はリンク先にあります。 |
| [Compression_Chamber](OpenModelica/Compression_Chamber/Compression_Chamber.mo) | 冷媒圧縮機の簡易1室モデル。[OMEdit での実行手順](OpenModelica/README.md) |
| [Oil_Circuit](OpenModelica/Oil_Circuit/OilCircuit.mo) | 油回路のモデル |

## OpenFOAM

各ケースのディレクトリに計算条件と実行スクリプトを収録しています。

| ケース | 内容 |
| --- | --- |
| [AMI](OpenFOAM/AMI/) | AMI を用いたケース |
| [TwoMeshAMI](OpenFOAM/TwoMeshAMI/) | 2つのメッシュを AMI で接続するケース |
| [cfMeshAndMRFWithTopoSet](OpenFOAM/cfMeshAndMRFWithTopoSet/) | cfMesh と topoSet を用いた MRF のケース |
| [tetgen](OpenFOAM/tetgen/) | TetGen と autoPatch を用いたメッシュ作成のケース |

## 移行元の開発ブランチ

OpenModelica の旧 `main` に未統合だった[ノーベル圧縮機](https://github.com/mmer547/OpenCAE_SampleCase/blob/feature/nobel-compressor/OpenModelica/AirConditionerCycle/NobelCompressor.md)と[スクロール圧縮機](https://github.com/mmer547/OpenCAE_SampleCase/blob/feature/scroll-compressor/OpenModelica/AirConditionerCycle/ScrollCompressor.md)は、それぞれ `feature/nobel-compressor` と `feature/scroll-compressor` に収録しています。ツインロータリ圧縮機は `main` に含まれています。
