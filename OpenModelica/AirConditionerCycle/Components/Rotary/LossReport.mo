within AirConditionerCycle.Components.Rotary;
block LossReport "損失・図示仕事と効率（瞬時値と直前の完了回転平均）"
  import SI = Modelica.Units.SI;
  type Channel = enumeration(copper "巻線銅損", iron "鉄損", auxiliary "一定付帯損失",
    bearing "軸受摩擦", vane "ベーン摺動／ノーベルコンプレッサーではブッシュの摺動・揺動摩擦", oilFilm "ローラ端面油膜",
    suctionDrop "吸入側圧損の仕事率近似", dischargeDrop "吐出側圧損の仕事率近似",
    leakageDrop "室間漏れの圧損仕事率近似", indicated "作動室へ入る図示動力",
    shellHeat "シェルから周囲への放熱", electric "電気入力", isentropic "吐出流量基準の等エントロピー動力");
  input SI.Power power[Channel] "チャネル別瞬時値";
  input SI.MassFlowRate leakRate "室間漏れの流量絶対値";
  input SI.MassFlowRate delivered "吐出管を出る流量";
  input SI.MassFlowRate theoretical "吸入密度 × 行程容積 × 実回転数";
  input Integer revolutions(start=0,fixed=true) "軸角ゼロからの完了回転数";
  output SI.Power motorLoss "瞬時のモーター損失合計";
  output SI.Power mechanicalLoss "瞬時の機械摩擦損失合計";
  discrete output SI.Power meanPower[Channel](each start=0,each fixed=true) "直前の1回転平均 [W]";
  discrete output SI.MassFlowRate meanLeakRate(start=0,fixed=true) "同期間の室間漏れ [kg/s]";
  discrete output Real volumetricEfficiency(start=0,fixed=true) "吐出質量／理論吸入質量";
  discrete output Real isentropicEfficiency(start=0,fixed=true) "吐出流量基準の等エントロピー仕事／電気入力";
protected
  SI.Energy energy[Channel](each start=0,each fixed=true);
  discrete SI.Energy previousEnergy[Channel](each start=0,each fixed=true);
  SI.Mass leakedMass(start=0,fixed=true), deliveredMass(start=0,fixed=true), theoreticalMass(start=0,fixed=true);
  discrete SI.Mass previousLeak(start=0,fixed=true), previousDelivery(start=0,fixed=true),
    previousTheoretical(start=0,fixed=true);
  discrete SI.Time previousTime(fixed=false);
initial equation
  previousTime = time;
equation
  motorLoss = power[Channel.copper] + power[Channel.iron] + power[Channel.auxiliary];
  mechanicalLoss = power[Channel.bearing] + power[Channel.vane] + power[Channel.oilFilm];
  der(energy) = power;
  der(leakedMass) = leakRate;
  der(deliveredMass) = delivered;
  der(theoreticalMass) = theoretical;
  when change(revolutions) then
    meanPower = (energy-pre(previousEnergy))/(time-pre(previousTime));
    meanLeakRate = (leakedMass-pre(previousLeak))/(time-pre(previousTime));
    volumetricEfficiency = if theoreticalMass > pre(previousTheoretical) then
      (deliveredMass-pre(previousDelivery))/(theoreticalMass-pre(previousTheoretical)) else 0;
    isentropicEfficiency = if meanPower[Channel.electric] > 0 then
      meanPower[Channel.isentropic]/meanPower[Channel.electric] else 0;
    previousEnergy = energy;
    previousLeak = leakedMass;
    previousDelivery = deliveredMass;
    previousTheoretical = theoreticalMass;
    previousTime = time;
  end when;
  annotation(Icon(graphics={Rectangle(extent={{-96,72},{96,-72}},lineColor={41,87,108},
    fillColor={220,240,237},fillPattern=FillPattern.Solid,radius=12),
    Line(points={{-69,-43},{-69,42}},color={38,93,102},thickness=2),
    Line(points={{-36,-43},{-36,12}},color={38,93,102},thickness=2),
    Line(points={{-3,-43},{-3,26}},color={38,93,102},thickness=2),
    Text(extent={{10,37},{88,-37}},textString="W",textColor={41,87,108})}));
end LossReport;
