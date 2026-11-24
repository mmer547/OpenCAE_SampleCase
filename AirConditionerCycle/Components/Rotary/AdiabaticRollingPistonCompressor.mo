within AirConditionerCycle.Components.Rotary;
model AdiabaticRollingPistonCompressor "断熱ロータリー圧縮機（作動室・弁・機械損失）"
  import SI = Modelica.Units.SI;
  extends BaseClasses.PartialRollingPiston(
    redeclare final model MotorModel = Adiabatic.Motor,
    redeclare final model ShaftModel = BaseClasses.ShaftMechanics,
    redeclare final model VaneModel = BaseClasses.VaneMechanics,
    redeclare final model CylinderModel = Adiabatic.Cylinder,
    redeclare final model ShellModel = Adiabatic.DischargePlenum);
  output SI.Power driveLoss "電動機・軸・ベーンで散逸する動力（正）";
equation
  driveLoss = motor.P_el - motor.driveTorque*motor.w
    + shaft.frictionTorque*shaft.w + vane.friction*vane.v;
  ambientHeatFlow = 0;
  E = gasAndMechanismEnergy;
  annotation(defaultComponentName="compressor", preferredView="diagram",
    Icon(graphics={Text(extent={{-75,87},{75,64}},textString="Q = 0",textColor={30,91,109})}),
    Documentation(info="<html><p>高圧シェルのガス容積を含む全冷媒室を断熱とします。圧縮仕事から冷媒の温度が決まります。driveLoss は電気・機械の散逸動力で、冷媒への入熱はゼロです。useDetailedLosses=true で一定相抵抗による銅損、鉄損、端面摩擦も計算します。</p></html>"));
end AdiabaticRollingPistonCompressor;
