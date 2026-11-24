within AirConditionerCycle.Components.Rotary;
model TwinRotaryCompressor "単段並列・180度位相差の断熱ツインロータリー"
  extends Interfaces.PartialCompressor(final internalFlowPath=true);
  import SI = Modelica.Units.SI;
  import dropPower = AirConditionerCycle.Components.Rotary.BaseClasses.pressureDropPower;
  parameter SI.Frequency speed(min=1)=50;
  parameter SI.Radius cylinderRadius=0.024;
  parameter SI.Length eccentricity=0.0045;
  parameter SI.Length cylinderHeight(min=1e-4)=0.02275 "1気筒当たりの高さ";
  parameter Boolean useDetailedLosses=true annotation(Evaluate=true);
  parameter Medium.AbsolutePressure pSuctionStart=Medium.saturationPressure(280.15);
  parameter Medium.AbsolutePressure pDischargeStart=Medium.saturationPressure(318.15);
  parameter Medium.SpecificEnthalpy hSuctionStart=Medium.specificEnthalpy_pT(pSuctionStart,
    Medium.saturationTemperature(pSuctionStart)+5);
  parameter Medium.SpecificEnthalpy hDischargeStart=hSuctionStart +
    (Medium.isentropicEnthalpy(pDischargeStart,Medium.setState_ph(pSuctionStart,hSuctionStart))-hSuctionStart)/0.72;
  Accumulator accumulator(redeclare final package Medium=Medium,inletCheckValve=true,
    p_start=0.989*pSuctionStart,h_start=hSuctionStart)
    annotation(Placement(transformation(origin={-78,0},extent={{-10,-10},{10,10}})));
  Adiabatic.CylinderUnit upper(redeclare final package Medium=Medium,
    radius=cylinderRadius,eccentricity=eccentricity,height=cylinderHeight,
    suctionPipe(outlet(p(start=0.989*pSuctionStart))),cylinder(inlet(p(start=0.989*pSuctionStart)),
      pocketA(p_start=1.03*pDischargeStart,h_start=hDischargeStart),
      pocketB(p_start=0.988*pSuctionStart,h_start=hSuctionStart)))
    annotation(Placement(transformation(origin={-4,67},extent={{-15,-15},{15,15}})));
  Adiabatic.CylinderUnit lower(redeclare final package Medium=Medium,
    radius=cylinderRadius,eccentricity=eccentricity,height=cylinderHeight,
    suctionPipe(outlet(p(start=0.989*pSuctionStart))),cylinder(inlet(p(start=0.989*pSuctionStart)),
      pocketA(p_start=0.988*pSuctionStart,h_start=hSuctionStart),
      pocketB(p_start=pSuctionStart,h_start=hSuctionStart)))
    annotation(Placement(transformation(origin={-4,0},extent={{-15,-15},{15,15}})));
  Muffler muffler(redeclare final package Medium=Medium,p_start=1.025*pDischargeStart,h_start=hDischargeStart)
    annotation(Placement(transformation(origin={42,38},extent={{-9,-9},{9,9}})));
  Adiabatic.DischargePlenum shell(redeclare final package Medium=Medium,
    p_start=1.012*pDischargeStart,h_start=hDischargeStart)
    annotation(Placement(transformation(origin={72,38},extent={{-9,-9},{9,9}})));
  DischargePipe dischargePipe(redeclare final package Medium=Medium)
    annotation(Placement(transformation(origin={72,0},extent={{-9,-9},{9,9}})));
  Adiabatic.Motor motor(speed=speed,final detailedLosses=useDetailedLosses)
    annotation(Placement(transformation(origin={-78,-67},extent={{-10,-10},{10,10}})));
  BaseClasses.ShaftMechanics shaft(eccentricity=eccentricity,faceRadius=cylinderRadius-eccentricity,
    final useOilFilm=useDetailedLosses,final facePairs=2)
    annotation(Placement(transformation(origin={-44,-67},extent={{-10,-10},{10,10}})));
  Modelica.Mechanics.Rotational.Components.Disc offset(final deltaPhi=Modelica.Constants.pi)
    annotation(Placement(transformation(origin={-17,-50},extent={{-8,-8},{8,8}})));
  final parameter SI.Volume displacement=upper.roller.displacement + lower.roller.displacement;
  SI.Power driveLoss "モーター・共通軸・両ベーンの散逸";
  SI.Mass charge "全冷媒質量";
  SI.Energy E "冷媒・両ベーン・回転子のエネルギー";
  LossReport losses(revolutions=upper.roller.revolutions,
    leakRate=noEvent(abs(upper.cylinder.leakAB)+abs(lower.cylinder.leakAB)),delivered=-outlet.m_flow,
    theoretical=Medium.density_ph(inlet.p,h_in)*displacement*motor.w/(2*Modelica.Constants.pi),
    power={motor.copperLoss,motor.ironLoss,motor.idleLoss,shaft.bearingTorque*shaft.w,
      upper.vaneLoss+lower.vaneLoss,shaft.oilFilmLoss,
      upper.suctionDrop+lower.suctionDrop+noEvent(dropPower(m_flow,inlet.p-accumulator.gas.p,Medium.density_ph(inlet.p,h_in))),
      upper.reedDrop+lower.reedDrop+noEvent(dropPower(-muffler.outlet.m_flow,muffler.gas.p-muffler.outlet.p,muffler.gas.rho)
        + dropPower(dischargePipe.m_flow,dischargePipe.dp,shell.gas.rho)),
      upper.leakageDrop+lower.leakageDrop,upper.indicatedPower+lower.indicatedPower,0,P_el,
      (-outlet.m_flow)*(Medium.isentropicEnthalpy(outlet.p,Medium.setState_ph(inlet.p,h_in))-h_in)})
    if useDetailedLosses annotation(Placement(transformation(origin={63,-66},extent={{-10,-10},{10,10}})));
equation
  connect(inlet,accumulator.inlet) annotation(Line(points={{-100,0},{-88,0}},color={23,117,162}));
  connect(accumulator.outlet,upper.inlet) annotation(Line(points={{-68,0},{-59,0},{-59,67},{-19,67}},color={23,117,162}));
  connect(accumulator.outlet,lower.inlet) annotation(Line(points={{-68,0},{-19,0}},color={23,117,162}));
  connect(upper.outlet,muffler.inlet) annotation(Line(points={{11,67},{23,67},{23,38},{33,38}},color={176,70,43}));
  connect(lower.outlet,muffler.inlet) annotation(Line(points={{11,0},{23,0},{23,38},{33,38}},color={176,70,43}));
  connect(muffler.outlet,shell.inlet) annotation(Line(points={{51,38},{63,38}},color={176,70,43}));
  connect(shell.outlet,dischargePipe.inlet) annotation(Line(points={{81,38},{91,38},{91,18},{58,18},{58,0},{63,0}},color={176,70,43}));
  connect(dischargePipe.outlet,outlet) annotation(Line(points={{81,0},{100,0}},color={176,70,43}));
  connect(motor.shaft,shaft.drive) annotation(Line(points={{-68,-67},{-54,-67}},color={57,71,82}));
  connect(shaft.crank,upper.crank) annotation(Line(points={{-34,-67},{-30,-67},{-30,40},{-4,40},{-4,52}},color={57,71,82}));
  connect(shaft.crank,offset.flange_a) annotation(Line(points={{-34,-67},{-30,-67},{-30,-50},{-25,-50}},color={57,71,82}));
  connect(offset.flange_b,lower.crank) annotation(Line(points={{-9,-50},{-4,-50},{-4,-15}},color={57,71,82}));
  P_el = motor.P_el;
  driveLoss = P_el - motor.driveTorque*motor.w + shaft.frictionTorque*shaft.w + upper.vaneLoss + lower.vaneLoss;
  charge = accumulator.gas.mass + upper.charge + lower.charge + muffler.gas.mass + shell.gas.mass;
  E = accumulator.gas.U + upper.E + lower.E + muffler.gas.U + shell.gas.U + motor.E_rotor;
  annotation(defaultComponentName="compressor",preferredView="diagram",Icon(graphics={
    Rectangle(extent={{-68,70},{68,-70}},radius=18,lineColor={36,63,83},fillColor={229,240,246},fillPattern=FillPattern.Solid),
    Ellipse(extent={{-37,65},{37,0}},lineColor={36,63,83}),Ellipse(extent={{-10,56},{36,9}},lineColor={36,63,83},fillColor={114,158,174},fillPattern=FillPattern.Solid),
    Ellipse(extent={{-37,0},{37,-65}},lineColor={36,63,83}),Ellipse(extent={{-36,-9},{10,-56}},lineColor={36,63,83},fillColor={114,158,174},fillPattern=FillPattern.Solid)}),
    Documentation(info="<html><p>断熱・単段の2気筒。上下のローラを1本の軸に180度ずらして取り付け、各リード弁の下流で合流します。共通機器は一度だけ収支に含めます。初期圧力・エンタルピーは使用する冷媒の運転条件に合わせます。</p></html>"));
end TwinRotaryCompressor;
