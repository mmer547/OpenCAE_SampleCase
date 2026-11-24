within AirConditionerCycle.Components.Rotary;
model RollingPistonCompressor "単気筒・高圧シェル型ローリングピストン圧縮機"
  extends AirConditionerCycle.Interfaces.PartialCompressor(final internalFlowPath=true);
  import SI = Modelica.Units.SI;
  parameter SI.Frequency speed(min=1)=50 "軸回転数 rev/s";
  parameter SI.Radius cylinderRadius=0.024;
  parameter SI.Length eccentricity=0.0045;
  parameter SI.Length height=0.0455 "シリンダ軸方向長さ";
  Accumulator accumulator(redeclare final package Medium=Medium)
    annotation(Placement(transformation(origin={-80,46},extent={{-11,-11},{11,11}})));
  SuctionPipe suctionPipe(redeclare final package Medium=Medium)
    annotation(Placement(transformation(origin={-45,46},extent={{-10,-10},{10,10}})));
  Cylinder cylinder(redeclare final package Medium=Medium)
    annotation(Placement(transformation(origin={-6,46},extent={{-12,-12},{12,12}})));
  DischargeReed reed(redeclare final package Medium=Medium)
    annotation(Placement(transformation(origin={32,46},extent={{-10,-10},{10,10}})));
  Muffler muffler(redeclare final package Medium=Medium)
    annotation(Placement(transformation(origin={70,46},extent={{-11,-11},{11,11}})));
  Shell shell(redeclare final package Medium=Medium)
    annotation(Placement(transformation(origin={44,-18},extent={{-11,-11},{11,11}})));
  DischargePipe dischargePipe(redeclare final package Medium=Medium)
    annotation(Placement(transformation(origin={80,-18},extent={{-10,-10},{10,10}})));

  Motor motor(speed=speed)
    annotation(Placement(transformation(origin={-82,-29},extent={{-10,-10},{10,10}})));
  EccentricShaft shaft(eccentricity=eccentricity)
    annotation(Placement(transformation(origin={-48,-29},extent={{-10,-10},{10,10}})));
  Roller roller(R=cylinderRadius,e=shaft.eccentricity,height=height)
    annotation(Placement(transformation(origin={-6,-29},extent={{-12,-12},{12,12}})));
  Vane vane(height=height)
    annotation(Placement(transformation(origin={-6,-67},extent={{-11,-11},{11,11}})));
  SI.Mass charge "圧縮機内の全冷媒質量";
  SI.Energy E "冷媒・シェル壁・ベーン・回転子の蓄積エネルギー";
equation
  connect(inlet,accumulator.inlet) annotation(Line(points={{-100,0},{-96,0},{-96,46},{-91,46}},color={23,117,162}));
  connect(accumulator.outlet,suctionPipe.inlet) annotation(Line(points={{-69,46},{-55,46}},color={23,117,162}));
  connect(suctionPipe.outlet,cylinder.inlet) annotation(Line(points={{-35,46},{-18,46}},color={23,117,162}));
  connect(cylinder.outlet,reed.inlet) annotation(Line(points={{6,46},{22,46}},color={176,70,43}));
  connect(reed.outlet,muffler.inlet) annotation(Line(points={{42,46},{59,46}},color={176,70,43}));
  connect(muffler.outlet,shell.inlet) annotation(Line(points={{81,46},{91,46},{91,13},{26,13},{26,-18},{33,-18}},color={176,70,43}));
  connect(shell.outlet,dischargePipe.inlet) annotation(Line(points={{55,-18},{70,-18}},color={176,70,43}));
  connect(dischargePipe.outlet,outlet) annotation(Line(points={{90,-18},{96,-18},{96,0},{100,0}},color={176,70,43}));
  connect(motor.shaft,shaft.drive) annotation(Line(points={{-72,-29},{-58,-29}},color={57,71,82},thickness=0.7));
  connect(shaft.crank,roller.shaft) annotation(Line(points={{-38,-29},{-18,-29}},color={57,71,82},thickness=0.7));
  connect(roller.follower,vane.tip) annotation(Line(points={{-6,-41},{-6,-56}},color={57,71,82},thickness=0.7));
  connect(roller.a,cylinder.a) annotation(Line(points={{-11.4,-17},{-11.4,34}},color={113,76,151}));
  connect(roller.b,cylinder.b) annotation(Line(points={{-0.6,-17},{-0.6,34}},color={113,76,151}));
  connect(roller.fillingA,cylinder.fillingA) annotation(Line(points={{6,-23.6},{10,-23.6},{10,22},{-15.12,22},{-15.12,36.4}},color={195,94,167},pattern=LinePattern.Dash));
  connect(roller.volumeRateA,cylinder.volumeRateA) annotation(Line(points={{6,-20},{13,-20},{13,40.6},{3,40.6}},color={21,61,133},pattern=LinePattern.Dash));
  connect(vane.leakArea,cylinder.leakArea) annotation(Line(points={{5,-62.6},{16,-62.6},{16,26},{3.12,26},{3.12,36.4}},color={21,61,133},pattern=LinePattern.Dash));
  connect(motor.heat,shell.wall) annotation(Line(points={{-82,-39},{-82,-89},{44,-89},{44,-29}},color={166,62,53}));
  connect(shaft.heat,shell.wall) annotation(Line(points={{-48,-39},{-48,-89},{44,-89},{44,-29}},color={166,62,53}));
  connect(vane.heat,shell.wall) annotation(Line(points={{-6,-78},{-6,-89},{44,-89},{44,-29}},color={166,62,53}));
  connect(cylinder.wall,shell.wall) annotation(Line(points={{-6,58},{-6,74},{22,74},{22,-38},{44,-38},{44,-29}},color={166,62,53}));

  P_el = motor.P_el;
  charge = accumulator.gas.mass + cylinder.pocketA.mass + cylinder.pocketB.mass
    + muffler.gas.mass + shell.gas.mass;
  E = accumulator.gas.U + cylinder.pocketA.U + cylinder.pocketB.U + muffler.gas.U
    + shell.gas.U + shell.Cwall*(shell.Twall-273.15) + vane.E + motor.E_rotor;
  annotation(defaultComponentName="compressor", preferredView="diagram",
    Icon(graphics={Ellipse(extent={{-59,59},{59,-59}},lineColor={36,63,83},
      fillColor={229,240,246},fillPattern=FillPattern.Solid),
      Ellipse(extent={{-33,45},{57,-45}},lineColor={36,63,83},fillColor={105,153,174},fillPattern=FillPattern.Solid),
      Ellipse(extent={{2,11},{24,-11}},lineColor={36,63,83},fillColor={231,241,246},fillPattern=FillPattern.Solid),
      Line(points={{-59,0},{-33,0}},color={144,79,54},thickness=2)}),
    Documentation(info="<html><p>高圧シェル型、単気筒の角度分解モデルです。ダイアグラムの上段が冷媒流路、下段が駆動機構です。二つの作動室を交互に追跡することで一回転ごとの質量・内部エネルギーを連続に保ちます。Examples.RotaryCooling では軸角、作動室圧力、リード弁リフトを確認できます。</p></html>"));
end RollingPistonCompressor;
