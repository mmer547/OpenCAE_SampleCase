within AirConditionerCycle.Components.Rotary;
model RollingPistonCompressor "単気筒・高圧シェル型ローリングピストン圧縮機"
  extends BaseClasses.PartialRollingPiston;
equation
  connect(motor.heat,shell.wall) annotation(Line(points={{-82,-39},{-82,-89},{44,-89},{44,-29}},color={166,62,53}));
  connect(shaft.heat,shell.wall) annotation(Line(points={{-48,-39},{-48,-89},{44,-89},{44,-29}},color={166,62,53}));
  connect(vane.heat,shell.wall) annotation(Line(points={{-6,-78},{-6,-89},{44,-89},{44,-29}},color={166,62,53}));
  connect(cylinder.wall,shell.wall) annotation(Line(points={{-6,58},{-6,74},{22,74},{22,-38},{44,-38},{44,-29}},color={166,62,53}));
  ambientHeatFlow = shell.Q_ambient;
  E = gasAndMechanismEnergy + shell.Cwall*(shell.Twall-273.15);
  annotation(defaultComponentName="compressor", preferredView="diagram",
    Documentation(info="<html><p>高圧シェル型、単気筒の角度分解モデルです。ダイアグラムの上段が冷媒流路、下段が駆動機構です。二つの作動室を交互に追跡することで一回転ごとの質量・内部エネルギーを連続に保ちます。Examples.CoolingCycles.RotaryCooling では軸角、作動室圧力、リード弁リフトを確認できます。useDetailedLosses=true で巻線銅損・鉄損・端面油膜抵抗を使い、losses で電力の内訳、漏れ、圧損仕事率、回転平均効率を表示します。Examples.LossStudies.RotaryCompressorLossTest が単体試験です。</p></html>"));
end RollingPistonCompressor;
