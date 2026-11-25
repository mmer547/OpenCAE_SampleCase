within AirConditionerCycle.Components.Rotary.BaseClasses;
record CylinderClearances "各シリンダの気体が通る有効すきま"
  extends Modelica.Icons.Record;
  import SI = Modelica.Units.SI;
  parameter SI.Length radialGap(min=0)=0 "ローラ外周の最小半径すきま（片側）";
  parameter SI.Length topGap(min=0)=0 "上端面の軸方向すきま（片側）";
  parameter SI.Length bottomGap(min=0)=0 "下端面の軸方向すきま（片側）";
  parameter SI.Length faceWidth(min=1e-9)=0.006 "端面1面当たりの等価通路幅";
  parameter SI.Length faceLength(min=1e-9)=0.005 "端面の等価圧力降下長さ";
end CylinderClearances;
