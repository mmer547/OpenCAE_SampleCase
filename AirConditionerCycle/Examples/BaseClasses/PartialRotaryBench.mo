within AirConditionerCycle.Examples.BaseClasses;
partial model PartialRotaryBench "詳細ロータリー圧縮機の単体試験（吸入・吐出圧力を指定）"
  extends Modelica.Icons.Example;
  import SI = Modelica.Units.SI;
  replaceable package Medium = Media.R134a constrainedby Modelica.Media.Interfaces.PartialTwoPhaseMedium(
    final ThermoStates=Modelica.Media.Interfaces.Choices.IndependentVariables.ph)
    annotation(choicesAllMatching=true);
  parameter Medium.AbsolutePressure suctionPressure=Medium.saturationPressure(280.15)
    "アキュームレータ入口の絶対圧力";
  parameter Medium.AbsolutePressure dischargePressure=Medium.saturationPressure(318.15)
    "吐出管出口の絶対圧力";
  parameter SI.TemperatureDifference suctionSuperheat(min=0.1)=5 "境界の吸入過熱度";
  parameter Boolean useDetailedLosses=false "損失評価を有効にする" annotation(Evaluate=true);
  parameter SI.Frequency speed(min=1)=50 "モーターの回転数指令 [rev/s]";
  final parameter Medium.Temperature suctionTemperature=Medium.saturationTemperature(suctionPressure) + suctionSuperheat;
  final parameter Medium.SpecificEnthalpy hSuction=Medium.specificEnthalpy_pT(suctionPressure,suctionTemperature);
  final parameter Medium.SpecificEnthalpy hDischargeStart=hSuction +
    (Medium.isentropicEnthalpy(dischargePressure,Medium.setState_ph(suctionPressure,hSuction))-hSuction)/0.72
    "運転中の吐出側を初期化する比エンタルピー";

  inner Modelica.Fluid.System system
    annotation(Placement(transformation(extent={{-94,64},{-74,84}})));
  Modelica.Fluid.Sources.Boundary_ph suction(redeclare package Medium=Medium,
    nPorts=1,p=suctionPressure,h=hSuction)
    annotation(Placement(transformation(extent={{-90,-12},{-66,12}})));
  replaceable model Compressor = Components.Rotary.RollingPistonCompressor
    constrainedby Components.Rotary.BaseClasses.PartialRollingPiston;
  Compressor compressor(redeclare package Medium=Medium, speed=speed, useDetailedLosses=useDetailedLosses,
    accumulator(inletCheckValve=true,p_start=0.989*suctionPressure,h_start=hSuction),
    suctionPipe(outlet(p(start=0.989*suctionPressure))),
    cylinder(inlet(p(start=0.989*suctionPressure)),
      pocketA(p_start=1.030*dischargePressure,h_start=hDischargeStart),
      pocketB(p_start=0.988*suctionPressure,h_start=hSuction)),
    muffler(p_start=1.025*dischargePressure,h_start=hDischargeStart),
    shell(p_start=1.012*dischargePressure,h_start=hDischargeStart))
    annotation(Placement(transformation(extent={{-22,-22},{22,22}})));
  Modelica.Fluid.Sources.Boundary_ph discharge(redeclare package Medium=Medium,
    nPorts=1,p=dischargePressure,h=hDischargeStart)
    annotation(Placement(transformation(extent={{90,-12},{66,12}})));

  output SI.MassFlowRate dischargeFlow "吐出管から境界へ出る質量流量（正）";
  output Medium.Temperature dischargeTemperature "吐出管出口の実際の冷媒温度";
initial equation
  assert(dischargePressure > suctionPressure, "Discharge pressure must exceed suction pressure.");
equation
  connect(suction.ports[1],compressor.inlet)
    annotation(Line(points={{-66,0},{-22,0}},color={23,117,162},thickness=0.7));
  connect(compressor.outlet,discharge.ports[1])
    annotation(Line(points={{22,0},{66,0}},color={176,70,43},thickness=0.7));
  dischargeFlow = -compressor.outlet.m_flow;
  dischargeTemperature = Medium.temperature_ph(compressor.outlet.p,compressor.outlet.h_outflow);
end PartialRotaryBench;
