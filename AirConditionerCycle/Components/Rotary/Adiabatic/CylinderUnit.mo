within AirConditionerCycle.Components.Rotary.Adiabatic;
model CylinderUnit "断熱ツインロータリーの1気筒分の機構・吸入管・吐出弁"
  extends Interfaces.PartialTwoPort(final internalFlowPath=true);
  import SI = Modelica.Units.SI;
  import dropPower = AirConditionerCycle.Components.Rotary.BaseClasses.pressureDropPower;
  parameter SI.Length height=0.02275;
  parameter SI.Radius radius=0.024;
  parameter SI.Length eccentricity=0.0045;
  Modelica.Mechanics.Rotational.Interfaces.Flange_a crank
    annotation(Placement(transformation(extent={{-10,-110},{10,-90}})));
  SuctionPipe suctionPipe(redeclare final package Medium=Medium)
    annotation(Placement(transformation(origin={-64,40},extent={{-12,-12},{12,12}})));
  Cylinder cylinder(redeclare final package Medium=Medium)
    annotation(Placement(transformation(origin={0,40},extent={{-20,-20},{20,20}})));
  DischargeReed reed(redeclare final package Medium=Medium)
    annotation(Placement(transformation(origin={66,40},extent={{-12,-12},{12,12}})));
  Roller roller(R=radius,e=eccentricity,height=height)
    annotation(Placement(transformation(origin={0,-18},extent={{-20,-20},{20,20}})));
  BaseClasses.VaneMechanics vane(height=height)
    annotation(Placement(transformation(origin={0,-68},extent={{-12,-12},{12,12}})));
  SI.Mass charge=cylinder.pocketA.mass + cylinder.pocketB.mass;
  SI.Energy E=cylinder.pocketA.U + cylinder.pocketB.U + vane.E;
  SI.Power indicatedPower=-(cylinder.pocketA.p-cylinder.pocketB.p)*roller.volumeRateA;
  SI.Power vaneLoss=vane.friction*vane.v;
  SI.Power suctionDrop=noEvent(dropPower(suctionPipe.m_flow,suctionPipe.dp,
    Medium.density_ph(inlet.p,h_in)) + dropPower(cylinder.m_flow,cylinder.inlet.p-cylinder.pSuction,
    Medium.density_ph(cylinder.inlet.p,cylinder.h_in)));
  SI.Power reedDrop=noEvent(dropPower(reed.m_flow,reed.inlet.p-reed.outlet.p,
    if roller.fillingA then cylinder.pocketB.rho else cylinder.pocketA.rho));
  SI.Power leakageDrop=noEvent(dropPower(abs(cylinder.leakAB),abs(cylinder.pocketA.p-cylinder.pocketB.p),
    if cylinder.leakAB >= 0 then cylinder.pocketA.rho else cylinder.pocketB.rho));
equation
  connect(inlet,suctionPipe.inlet) annotation(Line(points={{-100,0},{-90,0},{-90,40},{-76,40}},color={23,117,162}));
  connect(suctionPipe.outlet,cylinder.inlet) annotation(Line(points={{-52,40},{-20,40}},color={23,117,162}));
  connect(cylinder.outlet,reed.inlet) annotation(Line(points={{20,40},{54,40}},color={176,70,43}));
  connect(reed.outlet,outlet) annotation(Line(points={{78,40},{90,40},{90,0},{100,0}},color={176,70,43}));
  connect(crank,roller.shaft) annotation(Line(points={{0,-100},{-44,-100},{-44,-18},{-20,-18}},color={57,71,82}));
  connect(roller.follower,vane.tip) annotation(Line(points={{0,-38},{0,-56}},color={57,71,82}));
  connect(roller.a,cylinder.a) annotation(Line(points={{-9,2},{-9,20}},color={113,76,151}));
  connect(roller.b,cylinder.b) annotation(Line(points={{9,2},{9,20}},color={113,76,151}));
  connect(roller.fillingA,cylinder.fillingA) annotation(Line(points={{20,-9},{30,-9},{30,10},{-15.2,10},{-15.2,24}},color={195,94,167},pattern=LinePattern.Dash));
  connect(roller.volumeRateA,cylinder.volumeRateA) annotation(Line(points={{20,-3},{35,-3},{35,31},{15,31}},color={21,61,133},pattern=LinePattern.Dash));
  connect(vane.leakArea,cylinder.leakArea) annotation(Line(points={{12,-63.2},{44,-63.2},{44,14},{15.2,14},{15.2,24}},color={21,61,133},pattern=LinePattern.Dash));
  annotation(preferredView="diagram", Icon(graphics={
    Line(points={{-100,0},{100,0}},color={57,71,82}),
    Ellipse(extent={{-60,60},{60,-60}},lineColor={48,76,90},fillColor={218,235,240},fillPattern=FillPattern.Solid),
    Ellipse(extent={{-28,44},{60,-44}},lineColor={48,76,90},fillColor={153,185,198},fillPattern=FillPattern.Solid),
    Line(points={{0,-60},{0,-100}},color={57,71,82}),
    Text(extent={{-100,91},{100,62}},textString="%name",textColor={31,61,76})}));
end CylinderUnit;
