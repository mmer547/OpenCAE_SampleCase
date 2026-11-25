within AirConditionerCycle.Examples.BaseClasses;
partial model StandardCase
  replaceable package Refrigerant = Media.R134a constrainedby Modelica.Media.Interfaces.PartialTwoPhaseMedium;
  parameter Modelica.Units.SI.Temperature outdoorTemperature=308.15;
  parameter Modelica.Units.SI.Temperature evaporatingStart=280.15;
  parameter Modelica.Units.SI.Temperature condensingStart=318.15;
  extends CoolingCycles.RatedCooling(outdoor(T=outdoorTemperature), cycle(
    redeclare package Medium=Refrigerant,
    evaporator(T_start=evaporatingStart), condenser(T_start=condensingStart)));
  annotation(experiment(StartTime=0, StopTime=600, Interval=0.5, Tolerance=1e-7));
end StandardCase;
