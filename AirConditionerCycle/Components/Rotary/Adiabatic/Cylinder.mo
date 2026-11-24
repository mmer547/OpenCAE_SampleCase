within AirConditionerCycle.Components.Rotary.Adiabatic;
model Cylinder "二つの作動室・吸入・漏れの質量とエンタルピー輸送（断熱版）"
  extends BaseClasses.PartialCylinder;
equation
  pocketA.Q_flow = 0;
  pocketB.Q_flow = 0;
end Cylinder;
