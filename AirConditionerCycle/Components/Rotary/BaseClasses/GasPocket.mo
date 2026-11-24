within AirConditionerCycle.Components.Rotary.BaseClasses;
model GasPocket "ローラに挟まれた一つの作動室"
  extends VolumeState(V=boundary.V);
  VolumePort boundary annotation(Placement(transformation(extent={{-10,-110},{10,-90}})));
equation
  boundary.effort = -p;
  annotation(Icon(graphics={Ellipse(extent={{-64,63},{64,-63}},lineColor={47,80,100},
    fillColor={214,233,243},fillPattern=FillPattern.Solid,lineThickness=1),
    Text(extent={{-65,19},{65,-19}},textString="%name",textColor={42,75,91})}));
end GasPocket;
