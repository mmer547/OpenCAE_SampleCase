within AirConditionerCycle.Components.Rotary.BaseClasses;
partial model PartialBladeGuide "ブレード案内機構の並進端・漏れ面積・仕事率"
  import SI = Modelica.Units.SI;
  parameter SI.Length height(min=1e-4)=0.0455;
  Modelica.Mechanics.Translational.Interfaces.Flange_a tip
    annotation(Placement(transformation(extent={{-10,90},{10,110}})));
  Modelica.Blocks.Interfaces.RealOutput leakArea(unit="m2")
    annotation(Placement(transformation(extent={{90,30},{110,50}})));
  SI.Velocity v;
  SI.Force friction;
  SI.Energy E "機構の蓄積エネルギー";
  SI.Power frictionPower "案内部の摩擦散逸";
end PartialBladeGuide;
