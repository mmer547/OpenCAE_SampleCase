within AirConditionerCycle.Components.Rotary.BaseClasses;
function pressureDropPower "順方向の圧損仕事率近似（上流体積流量 × 差圧）"
  import SI = Modelica.Units.SI;
  input SI.MassFlowRate flowRate;
  input SI.PressureDifference dp;
  input SI.Density upstreamDensity;
  output SI.Power power;
algorithm
  power := max(0,dp)*flowRate/upstreamDensity;
  annotation(Inline=true);
end pressureDropPower;
