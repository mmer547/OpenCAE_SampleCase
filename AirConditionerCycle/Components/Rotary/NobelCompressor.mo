within AirConditionerCycle.Components.Rotary;
model NobelCompressor "ノーベルコンプレッサー（単気筒・断熱）"
  extends AdiabaticRollingPistonCompressor(
    redeclare final model RollerModel = Nobel.PistonBlade,
    redeclare final model VaneModel = Nobel.SwingBush);
equation
  connect(roller.pivot,vane.pivot) annotation(Line(
    points={{-0.12,-41},{-0.12,-50},{-0.61,-50},{-0.61,-56}},color={65,72,81},thickness=0.7));
  annotation(defaultComponentName="compressor",preferredView="diagram",
    Icon(graphics={
      Ellipse(extent={{-74,16},{-44,-14}},lineColor={48,76,90},fillColor={207,179,122},fillPattern=FillPattern.Solid),
      Polygon(points={{-83,-9},{-30,0},{-29,7},{-82,-2},{-83,-9}},lineColor={48,76,90},fillColor={151,189,203},fillPattern=FillPattern.Solid),
      Text(extent={{-74,-65},{74,-86}},textString="NOBEL",textColor={30,91,109})}),
    Documentation(info="<html><p>roller は一体ローラ・ブレード、vane は固定中心で揺動するブッシュです。両者の並進端・回転端で相対摺動と揺動の仕事を軸に戻します。気体室は断熱です。ブレードは厚さゼロで、背室およびブッシュすきまからの流出は扱いません。</p></html>"));
end NobelCompressor;
