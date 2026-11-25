# OpenFOAM のサンプルケース

| ケース | 内容 | 実行スクリプト |
| --- | --- | --- |
| [AMI](AMI/) | OpenFOAM 11 向け。snappyHexMesh でメッシュを作成し、`createNonConformalCouples` で非整合面を接続します。メッシュ作成だけを行うには `-m` を指定します。 | [Allrun](AMI/Allrun) |
| [TwoMeshAMI](TwoMeshAMI/) | 内側と外側のメッシュを cfMesh で別々に作成し、`mergeMeshes` で結合します。境界に `cyclicAMI` を設定して並列計算します。 | [前処理](TwoMeshAMI/Allprep)・[求解](TwoMeshAMI/Allsolve) |
| [cfMeshAndMRFWithTopoSet](cfMeshAndMRFWithTopoSet/) | cfMesh でメッシュを作成し、`topoSet` で回転座標系（MRF）を適用するセル領域を定義します。 | [Allrun](cfMeshAndMRFWithTopoSet/Allrun) |
| [tetgen](tetgen/) | TetGen で段差付き流路の四面体メッシュを生成し、`tetgenToFoam` で変換します。`autoPatch` と `createPatch` で境界を設定します。 | [前処理](tetgen/Allrun.pre)・[Allrun](tetgen/Allrun) |

## 実行方法

OpenFOAM の環境を読み込んだシェルで、実行するケースのディレクトリに移動します。次のコマンドは各ケースのディレクトリから実行してください。

- **AMI** — `sh ./Allrun` でメッシュ作成から求解まで実行します。メッシュ作成だけなら `sh ./Allrun -m` です。
- **TwoMeshAMI** — cfMesh を用意し、`chmod +x Allprep Allsolve inner/Allrun.pre outer/Allrun.pre` を実行してから `sh ./Allrun` を実行します。
- **cfMeshAndMRFWithTopoSet** — cfMesh を用意し、`sh ./Allrun` を実行します。
- **tetgen** — 前処理は `./tetgen` を呼び出します。ケースの直下に実行可能な TetGen バイナリを `tetgen` の名前で配置し、`chmod +x Allrun.pre` を実行してから `sh ./Allrun` を実行します。
