within AirConditionerCycle.Components.Rotary.BaseClasses;
connector VolumePort "可動境界の容積と圧力。流入仕事率は effort × der(V)"
  Modelica.Units.SI.Volume V;
  flow Real effort(unit="Pa") "気体側で負、機構側で正の圧力";
  annotation(Icon(graphics={Rectangle(extent={{-100,-100},{100,100}},
    lineColor={94,60,132}, fillColor={199,179,222}, fillPattern=FillPattern.Solid)}));
end VolumePort;
