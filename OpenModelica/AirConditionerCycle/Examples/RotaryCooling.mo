within AirConditionerCycle.Examples;
model RotaryCooling "ロータリー圧縮機での軸角分解冷房運転"
  extends RatedCooling(cycle(redeclare model Compressor =
    AirConditionerCycle.Components.Rotary.RollingPistonCompressor));
  Modelica.Units.SI.Energy electricalEnergy(start=0,fixed=true);
  Modelica.Units.SI.Mass deliveredMass(start=0,fixed=true);
  discrete Modelica.Units.SI.Power meanPower(start=0,fixed=true) "直前に完了した1回転の平均消費電力";
  discrete Modelica.Units.SI.MassFlowRate meanDelivery(start=0,fixed=true) "直前に完了した1回転の平均吐出管流量";
protected
  discrete Modelica.Units.SI.Time lastTime(start=0,fixed=true);
  discrete Modelica.Units.SI.Energy lastEnergy(start=0,fixed=true);
  discrete Modelica.Units.SI.Mass lastMass(start=0,fixed=true);
equation
  der(electricalEnergy) = cycle.P_el;
  der(deliveredMass) = -cycle.compressor.outlet.m_flow;
  when change(cycle.compressor.roller.revolutions) then
    meanPower = (electricalEnergy-pre(lastEnergy))/(time-pre(lastTime));
    meanDelivery = (deliveredMass-pre(lastMass))/(time-pre(lastTime));
    lastTime = time;
    lastEnergy = electricalEnergy;
    lastMass = deliveredMass;
  end when;
  annotation(experiment(StartTime=0,StopTime=0.21,Interval=0.000025,Tolerance=1e-7));
end RotaryCooling;
