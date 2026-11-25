within AirConditionerCycle.Components.Scroll;
model OrbitDrive "自転を拘束した旋回スクロールとオルダム継手の等価摺動"
  import SI = Modelica.Units.SI;
  parameter SI.Radius radius(min=1e-6)=0.00423;
  parameter SI.Mass orbitingMass(min=0)=0.42 "等価公転質量";
  parameter SI.Force slidingForce(min=0)=3 "各直交キーの等価摩擦力";
  parameter SI.TranslationalDampingConstant damping(min=0)=1.6;
  Modelica.Mechanics.Rotational.Interfaces.Flange_a drive annotation(Placement(transformation(extent={{-110,-10},{-90,10}})));
  Modelica.Mechanics.Rotational.Interfaces.Flange_b driven annotation(Placement(transformation(extent={{90,-10},{110,10}})));
  SI.Length x,y;
  SI.AngularVelocity w;
  SI.Velocity vx,vy;
  SI.Force fx,fy;
  SI.Power oldhamLoss;
  SI.Energy E;
equation
  drive.phi=driven.phi;
  w=der(drive.phi);
  x=radius*cos(drive.phi);
  y=radius*sin(drive.phi);
  vx=-y*w;
  vy=x*w;
  fx=damping*vx+slidingForce*tanh(vx/0.02);
  fy=damping*vy+slidingForce*tanh(vy/0.02);
  drive.tau+driven.tau=orbitingMass*radius^2*der(w)-fx*y+fy*x;
  oldhamLoss=fx*vx+fy*vy;
  E=orbitingMass*(vx^2+vy^2)/2;
  annotation(Icon(graphics={Ellipse(extent={{-64,63},{64,-63}},lineColor={39,84,97},lineThickness=1.5),
    Rectangle(extent={{-59,9},{59,-9}},lineColor={39,84,97},fillColor={156,193,205},fillPattern=FillPattern.Solid),
    Rectangle(extent={{-9,58},{9,-58}},lineColor={39,84,97},fillColor={219,182,120},fillPattern=FillPattern.Solid)}));
end OrbitDrive;
