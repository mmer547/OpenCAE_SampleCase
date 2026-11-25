within AirConditionerCycle.Components.Rotary.Adiabatic;
model Motor "速度制御・回転子慣性・電気入力と損失（断熱版）"
  import SI = Modelica.Units.SI;
  extends BaseClasses.PartialMotor;
  parameter SI.Resistance operatingResistance(min=0)=0.36 "一定の運転時相抵抗 [Ω]";
equation
  phaseResistance = operatingResistance;
end Motor;
