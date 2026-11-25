within AirConditionerCycle.Components.Rotary;
model DischargePipe "シェル出口から凝縮器へ向かう吐出管"
  extends BaseClasses.Pipe(length=0.20, diameter=0.008, minorLoss=1.8);
  annotation(Icon(graphics={Line(points={{-26,-18},{23,-18}},arrow={Arrow.None,Arrow.Filled},
    color={176,70,43},thickness=1.1)}));
end DischargePipe;
