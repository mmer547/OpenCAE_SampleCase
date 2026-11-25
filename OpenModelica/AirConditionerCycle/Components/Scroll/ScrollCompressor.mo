within AirConditionerCycle.Components.Scroll;
model ScrollCompressor "断熱・高圧シェル・対称室対を追跡するスクロール圧縮機"
  extends Interfaces.PartialCompressor(final internalFlowPath=true);
  import SI = Modelica.Units.SI;
  parameter Dimensions geometry;
  parameter SI.Frequency speed(min=1)=50;
  parameter Boolean useDetailedLosses=true annotation(Evaluate=true);
  parameter Medium.AbsolutePressure pSuction_start=370500,pDischarge_start=1175000;
  parameter Medium.SpecificEnthalpy hSuction_start=407250,hDischarge_start=445000;
  Rotary.Accumulator accumulator(redeclare final package Medium=Medium,inletCheckValve=true,
    p_start=pSuction_start,h_start=hSuction_start) annotation(Placement(transformation(extent={{-92,29},{-72,49}})));
  Rotary.SuctionPipe suctionPipe(redeclare final package Medium=Medium,outlet(p(start=pSuction_start)))
    annotation(Placement(transformation(extent={{-63,29},{-47,49}})));
  PocketSet pockets(redeclare final package Medium=Medium,pLow_start=pSuction_start,pHigh_start=pDischarge_start,
    hLow_start=hSuction_start,hHigh_start=hDischarge_start,final wrapHeight=geometry.wrapHeight,
    inlet(p(start=pSuction_start))) annotation(Placement(transformation(extent={{-34,24},{-4,54}})));
  Rotary.DischargeReed reed(redeclare final package Medium=Medium) annotation(Placement(transformation(extent={{9,29},{29,49}})));
  Rotary.Muffler muffler(redeclare final package Medium=Medium,p_start=pDischarge_start,h_start=hDischarge_start)
    annotation(Placement(transformation(extent={{42,29},{62,49}})));
  Rotary.Adiabatic.DischargePlenum shell(redeclare final package Medium=Medium,p_start=pDischarge_start,h_start=hDischarge_start)
    annotation(Placement(transformation(extent={{38,-6},{58,14}})));
  Rotary.DischargePipe dischargePipe(redeclare final package Medium=Medium)
    annotation(Placement(transformation(extent={{69,-6},{89,14}})));
  Rotary.Adiabatic.Motor motor(speed=speed,final detailedLosses=useDetailedLosses)
    annotation(Placement(transformation(extent={{-96,-54},{-76,-34}})));
  Rotary.BaseClasses.ShaftMechanics shaft(final useOilFilm=false,eccentricity=geometry.orbitRadius)
    annotation(Placement(transformation(extent={{-73,-54},{-55,-34}})));
  OrbitDrive orbit(final radius=geometry.orbitRadius) annotation(Placement(transformation(extent={{-52,-54},{-34,-34}})));
  WrapGeometry wraps(final geometry=geometry) annotation(Placement(transformation(extent={{-27,-54},{-5,-32}})));
  SI.Mass charge;
  SI.Energy E;
  SI.Power driveLoss;
  SI.Power indicatedPower=wraps.indicatedPower;
  SI.Power bearingLoss=shaft.frictionTorque*shaft.w;
  SI.Power motorLoss=motor.P_el-motor.driveTorque*motor.w;
  SI.Power oldhamLoss=orbit.oldhamLoss;
  discrete SI.Power meanPower(start=0,fixed=true);
  discrete SI.MassFlowRate meanDelivery(start=0,fixed=true);
protected
  SI.Mass delivered(start=0,fixed=true);
  SI.Energy electric(start=0,fixed=true);
  discrete SI.Energy lastEnergy(start=0,fixed=true);
  discrete SI.Mass lastMass(start=0,fixed=true);
  discrete SI.Time lastTime(fixed=false);
initial equation
  lastTime=time;
equation
  connect(inlet,accumulator.inlet) annotation(Line(points={{-100,0},{-96,0},{-96,39},{-92,39}},color={23,117,162}));
  connect(accumulator.outlet,suctionPipe.inlet) annotation(Line(points={{-72,39},{-63,39}},color={23,117,162}));
  connect(suctionPipe.outlet,pockets.inlet) annotation(Line(points={{-47,39},{-34,39}},color={23,117,162}));
  connect(pockets.outlet,reed.inlet) annotation(Line(points={{-4,39},{9,39}},color={176,70,43}));
  connect(reed.outlet,muffler.inlet) annotation(Line(points={{29,39},{42,39}},color={176,70,43}));
  connect(muffler.outlet,shell.inlet) annotation(Line(points={{62,39},{65,39},{65,20},{35,20},{35,4},{38,4}},color={176,70,43}));
  connect(shell.outlet,dischargePipe.inlet) annotation(Line(points={{58,4},{69,4}},color={176,70,43}));
  connect(dischargePipe.outlet,outlet) annotation(Line(points={{89,4},{95,4},{95,0},{100,0}},color={176,70,43}));
  connect(motor.shaft,shaft.drive) annotation(Line(points={{-76,-44},{-73,-44}},color={57,71,82}));
  connect(shaft.crank,orbit.drive) annotation(Line(points={{-55,-44},{-52,-44}},color={57,71,82}));
  connect(orbit.driven,wraps.shaft) annotation(Line(points={{-34,-44},{-31,-44},{-31,-43},{-27,-43}},color={57,71,82}));
  connect(wraps.chamber,pockets.chamber) annotation(Line(points={{-5.66,-38.6},{8,-38.6},{8,-12},{-28,-12},{-28,24.6}},color={113,76,151}));
  connect(wraps.volumeRate,pockets.volumeRate) annotation(Line(points={{-5.66,-42.12},{12,-42.12},{12,-8},{-19.3,-8},{-19.3,24.6}},color={30,97,150},pattern=LinePattern.Dash));
  connect(wraps.stage,pockets.stage) annotation(Line(points={{-5.66,-45.86},{16,-45.86},{16,-4},{-10,-4},{-10,24.6}},color={116,88,61},pattern=LinePattern.Dash));
  connect(wraps.portOpening,pockets.portOpening) annotation(Line(points={{-5.66,-49.6},{20,-49.6},{20,-1},{-6.1,-1},{-6.1,29.4}},color={30,97,150},pattern=LinePattern.Dash));
  charge=accumulator.gas.mass+sum(pockets.pocket.mass)+pockets.center.mass+muffler.gas.mass+shell.gas.mass;
  E=accumulator.gas.U+sum(pockets.pocket.U)+pockets.center.U+muffler.gas.U+shell.gas.U+motor.E_rotor+orbit.E;
  P_el=motor.P_el;
  driveLoss=motorLoss+bearingLoss+oldhamLoss;
  der(delivered)=-outlet.m_flow;
  der(electric)=P_el;
  when change(wraps.revolutions) then
    meanPower=(electric-pre(lastEnergy))/(time-pre(lastTime));
    meanDelivery=(delivered-pre(lastMass))/(time-pre(lastTime));
    lastEnergy=electric;
    lastMass=delivered;
    lastTime=time;
  end when;
  annotation(defaultComponentName="compressor",preferredView="diagram",
    Icon(graphics={Ellipse(extent={{-64,64},{64,-64}},lineColor={28,86,97},fillColor={228,242,240},fillPattern=FillPattern.Solid),
      Line(points={{1,0},{6,6},{0,14},{-12,12},{-19,-1},{-13,-17},{5,-24},{25,-17},{33,3},{24,27},{0,40},{-27,34},{-44,10},{-41,-18},{-21,-41},{10,-47},{41,-31},{54,-6}},color={16,99,109},smooth=Smooth.Bezier,thickness=2.4)}),
    Documentation(info="<html><p>対称な両側のポケットを一組に集約し、四組を外周吸入・二公転の閉じ込み圧縮・中央吐出まで連続追跡します。容積特性は行程容積と内蔵容積比で指定する近似です。例題は ScrollStandalone と ScrollCooling です。</p></html>"));
end ScrollCompressor;
