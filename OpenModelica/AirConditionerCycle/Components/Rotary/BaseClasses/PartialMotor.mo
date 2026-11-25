within AirConditionerCycle.Components.Rotary.BaseClasses;
partial model PartialMotor "速度制御・回転子慣性・電気入力と損失"
  import SI = Modelica.Units.SI;
  parameter SI.Frequency speed(min=1)=50 "回転数 rev/s";
  parameter Real efficiency(min=0.1, max=1)=0.91;
  parameter SI.Power idleLoss(min=0)=18;
  parameter Boolean detailedLosses=false "銅損・鉄損を個別計算" annotation(Evaluate=true);
  parameter Real torqueConstant(unit="N.m/A",min=1e-6)=0.45 "相電流実効値当たりトルク";
  parameter SI.Frequency ironReferenceSpeed(min=1)=50 "鉄損定格の機械回転数 rev/s";
  parameter SI.Power hysteresisReference(min=0)=12 "基準速度でのヒステリシス損";
  parameter SI.Power eddyReference(min=0)=8 "基準速度での渦電流損";
  SI.Resistance phaseResistance "計算に使用する一相の有効抵抗";
  SI.Power copperLoss "三相巻線の銅損（詳細損失設定）";
  SI.Power ironLoss "ヒステリシス損と渦電流損の和（詳細損失設定）";
  parameter SI.Inertia J(min=1e-6)=0.0015 "回転子と軸の等価慣性モーメント";
  parameter SI.RotationalDampingConstant Kp(min=1e-5)=0.12 "速度制御の比例ゲイン";
  parameter SI.Time Ti(min=1e-4)=0.025 "速度制御の積分時間";
  parameter SI.Torque maxTorque(min=0.1)=8;
  parameter SI.Torque initialTorque=2.3 "運転中から開始するための初期トルク";
  Modelica.Mechanics.Rotational.Interfaces.Flange_b shaft(phi(start=0, fixed=true))
    annotation(Placement(transformation(extent={{90,-10},{110,10}})));
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
  copperLoss = if detailedLosses then 3*phaseResistance*(driveTorque/torqueConstant)^2 else 0;
  ironLoss = if detailedLosses then hysteresisReference*abs(w)/(2*Modelica.Constants.pi*ironReferenceSpeed)
    + eddyReference*(w/(2*Modelica.Constants.pi*ironReferenceSpeed))^2 else 0;
  P_el = if detailedLosses then driveTorque*w + idleLoss + copperLoss + ironLoss
    else idleLoss + driveTorque*w/efficiency;
  annotation(Icon(graphics={
    Ellipse(extent={{-66,66},{66,-66}}, lineColor={48,76,90}, fillColor={233,239,245},fillPattern=FillPattern.Solid,lineThickness=1),
    Text(extent={{-48,46},{48,-42}}, textString="M", textColor={42,80,104}),
    Line(points={{66,0},{96,0}},color={48,76,90},thickness=1.5),
    Text(extent={{-145,-72},{145,-100}},textString="%name",textColor={31,61,76})}));
end PartialMotor;
