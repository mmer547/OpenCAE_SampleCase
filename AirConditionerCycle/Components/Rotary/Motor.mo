within AirConditionerCycle.Components.Rotary;
model Motor "回転子慣性とPI速度制御を持つ電動機"
  import SI = Modelica.Units.SI;
  parameter SI.Frequency speed(min=1)=50 "回転数 rev/s";
  parameter Real efficiency(min=0.1, max=1)=0.91;
  parameter SI.Power idleLoss(min=0)=18;
  parameter SI.Inertia J(min=1e-6)=0.0015 "回転子と軸の等価慣性モーメント";
  parameter SI.RotationalDampingConstant Kp(min=1e-5)=0.12 "速度制御の比例ゲイン";
  parameter SI.Time Ti(min=1e-4)=0.025 "速度制御の積分時間";
  parameter SI.Torque maxTorque(min=0.1)=8;
  parameter SI.Torque initialTorque=2.3 "運転中から開始するための初期トルク";
  Modelica.Mechanics.Rotational.Interfaces.Flange_b shaft(phi(start=0, fixed=true))
    annotation(Placement(transformation(extent={{90,-10},{110,10}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_b heat
    annotation(Placement(transformation(extent={{-10,-110},{10,-90}})));
  SI.Power P_mech "軸への出力";
  SI.Power P_el "電気入力";
  SI.AngularVelocity w(start=2*Modelica.Constants.pi*speed, fixed=true);
  SI.Torque driveTorque "電磁トルク";
  SI.Energy E_rotor "回転子の運動エネルギー";
protected
  SI.AngularVelocity speedError;
  SI.Torque requestedTorque;
  SI.Torque integralTorque(start=initialTorque,fixed=true);
equation
  der(shaft.phi) = w;
  speedError = 2*Modelica.Constants.pi*speed - w;
  requestedTorque = Kp*speedError + integralTorque;
  driveTorque = noEvent(min(maxTorque,max(0,requestedTorque)));
  der(integralTorque) = (Kp*speedError + driveTorque-requestedTorque)/Ti;
  J*der(w) = driveTorque + shaft.tau;
  P_mech = -shaft.tau*w;
  E_rotor = J*w^2/2;
  P_el = idleLoss + driveTorque*w/efficiency;
  heat.Q_flow = driveTorque*w - P_el;
  annotation(Icon(graphics={
    Ellipse(extent={{-66,66},{66,-66}}, lineColor={48,76,90}, fillColor={233,239,245},fillPattern=FillPattern.Solid,lineThickness=1),
    Text(extent={{-48,46},{48,-42}}, textString="M", textColor={42,80,104}),
    Line(points={{66,0},{96,0}},color={48,76,90},thickness=1.5),
    Text(extent={{-145,-72},{145,-100}},textString="%name",textColor={31,61,76})}));
end Motor;
