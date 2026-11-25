within AirConditionerCycle.Components.Scroll;
record Dimensions "固定・旋回ラップと対称室対の等価寸法"
  import SI = Modelica.Units.SI;
  parameter SI.Radius baseRadius(min=1e-5)=0.0023 "インボリュート基礎円半径";
  parameter SI.Length thickness(min=1e-5)=0.003 "ラップ厚さ";
  final parameter SI.Length orbitRadius=Modelica.Constants.pi*baseRadius-thickness;
  parameter SI.Height wrapHeight(min=1e-4)=0.024;
  parameter SI.Volume displacement(min=1e-7)=28e-6 "両側の室を合計した一公転の吸入掃引容積";
  parameter Real builtInRatio(min=1.01)=2.6 "吸込閉鎖容積／中央吐出口の開き始め容積";
  parameter Real deadFraction(min=0.001,max=0.2)=0.025 "再膨張する残留容積／行程容積";
end Dimensions;
