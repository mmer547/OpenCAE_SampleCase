within AirConditionerCycle.Examples.BaseClasses;
partial model PartialRotaryCase
  replaceable package Refrigerant = Media.R134a constrainedby Modelica.Media.Interfaces.PartialTwoPhaseMedium;
  parameter Modelica.Units.SI.Temperature outdoorTemperature=308.15;
  parameter Modelica.Units.SI.Temperature evaporatingStart=280.15;
  parameter Modelica.Units.SI.Temperature condensingStart=318.15;
  parameter Real shellPressureRatio=1.004 "初期シェル圧力／初期凝縮圧力";
  parameter Real mufflerPressureRatio=1.011;
  parameter Real pocketAPressureRatio=1.013;
  final parameter Refrigerant.AbsolutePressure pL=Refrigerant.saturationPressure(evaporatingStart);
  final parameter Refrigerant.AbsolutePressure pH=Refrigerant.saturationPressure(condensingStart);
  final parameter Refrigerant.SpecificEnthalpy hS=
    Refrigerant.specificEnthalpy_pT(pL,evaporatingStart+cycle.evaporator.superheat);
  final parameter Refrigerant.SpecificEnthalpy hD=hS+
    (Refrigerant.isentropicEnthalpy(pH,Refrigerant.setState_ph(pL,hS))-hS)/0.72
    "運転開始時の吐出ガスの初期値";
  extends CoolingCycles.RotaryCooling(outdoor(T=outdoorTemperature), cycle(
    redeclare package Medium=Refrigerant,
    evaporator(T_start=evaporatingStart), condenser(T_start=condensingStart),
    compressor(
      accumulator(p_start=0.989*pL,h_start=hS),
      suctionPipe(outlet(p(start=0.989*pL))),
      cylinder(inlet(p(start=0.989*pL)),pocketB(p_start=0.988*pL,h_start=hS),
        pocketA(p_start=pocketAPressureRatio*pH,h_start=hD)),
      muffler(p_start=mufflerPressureRatio*pH,h_start=hD),
      shell(p_start=shellPressureRatio*pH,h_start=hD))));
  annotation(experiment(StartTime=0, StopTime=0.21, Interval=0.000025, Tolerance=1e-7));
end PartialRotaryCase;
