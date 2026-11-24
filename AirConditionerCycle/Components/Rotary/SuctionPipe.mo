within AirConditionerCycle.Components.Rotary;
model SuctionPipe "アキュームレータ出口からシリンダ吸入口まで"
  extends BaseClasses.Pipe(length=0.16, diameter=0.012, minorLoss=1.2);
  annotation(Icon(graphics={Line(points={{-26,-18},{23,-18}},arrow={Arrow.None,Arrow.Filled},
    color={23,117,162},thickness=1.1)}));
end SuctionPipe;
