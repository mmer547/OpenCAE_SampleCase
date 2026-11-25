within AirConditionerCycle.Components.Scroll;
model WrapGeometry "固定・旋回スクロールの四つの対称室対の容積特性"
  import SI = Modelica.Units.SI;
  import Modelica.Constants.pi;
  parameter Dimensions geometry;
  parameter Real ramp(min=0.01,max=0.45)=0.08 "各公転端の容積勾配を滑らかにする区間比";
  parameter Real portRamp(min=0.005,max=0.45)=0.06 "各ポートの開閉にかかる公転比";
  final parameter SI.Volume Vmin=geometry.deadFraction*geometry.displacement;
  final parameter SI.Volume Vmax=Vmin+geometry.displacement;
  final parameter SI.Volume Vopen=Vmax/geometry.builtInRatio;
  final parameter SI.Volume knots[5]={Vmin,Vmax,(Vmax+Vopen)/2,Vopen,Vmin};
  Modelica.Mechanics.Rotational.Interfaces.Flange_a shaft annotation(Placement(transformation(extent={{-110,-10},{-90,10}})));
  Rotary.BaseClasses.VolumePort chamber[4] annotation(Placement(transformation(extent={{84,30},{104,50}})));
  Modelica.Blocks.Interfaces.RealOutput volumeRate[4](each unit="m3/s") annotation(Placement(transformation(extent={{84,-2},{104,18}})));
  Modelica.Blocks.Interfaces.IntegerOutput stage[4] annotation(Placement(transformation(extent={{84,-36},{104,-16}})));
  Modelica.Blocks.Interfaces.RealOutput portOpening(unit="1") annotation(Placement(transformation(extent={{84,-70},{104,-50}})));
  Integer revolutions(start=0,fixed=true);
  SI.Power indicatedPower;
  Real turn "現在の公転内の位相 0..1";
protected
  Real progress, slope;
  SI.Volume dVdPhi[4];
initial equation
  assert(geometry.orbitRadius>0 and Vopen>Vmin,"Invalid scroll orbit radius or built-in volume ratio.");
equation
  revolutions = integer(shaft.phi/(2*pi));
  turn = shaft.phi/(2*pi)-revolutions;
  portOpening = noEvent(sin(pi/2*min(1,max(0,min(turn,1-turn)/portRamp)))^2);
  progress = noEvent(if turn<ramp then turn^2/(2*ramp*(1-ramp)) else if turn>1-ramp then
    1-(1-turn)^2/(2*ramp*(1-ramp)) else (turn-ramp/2)/(1-ramp));
  slope = noEvent(if turn<ramp then turn/(ramp*(1-ramp)) else if turn>1-ramp then
    (1-turn)/(ramp*(1-ramp)) else 1/(1-ramp));
  for i in 1:4 loop
    stage[i] = 1+mod(revolutions+i-1,4);
    chamber[i].V = knots[stage[i]] + (knots[stage[i]+1]-knots[stage[i]])*progress;
    dVdPhi[i] = (knots[stage[i]+1]-knots[stage[i]])*slope/(2*pi);
    volumeRate[i] = dVdPhi[i]*der(shaft.phi);
  end for;
  shaft.tau = -sum(chamber[i].effort*dVdPhi[i] for i in 1:4);
  indicatedPower = shaft.tau*der(shaft.phi);
  annotation(Icon(graphics={Ellipse(extent={{-75,72},{75,-72}},lineColor={37,81,95},fillPattern=FillPattern.Solid,fillColor={221,240,239}),
    Line(points={{0,0},{5,5},{-3,12},{-15,6},{-18,-8},{-6,-22},{17,-22},{32,-5},{29,19},{8,35},{-21,34},{-43,12},{-45,-16},{-24,-42},{11,-50},{43,-35},{59,-8}},smooth=Smooth.Bezier,color={23,89,105},thickness=2),
    Text(extent={{-105,-72},{105,-96}},textString="%name",textColor={31,61,76})}));
end WrapGeometry;
