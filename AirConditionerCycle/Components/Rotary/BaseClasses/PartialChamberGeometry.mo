within AirConditionerCycle.Components.Rotary.BaseClasses;
partial model PartialChamberGeometry "二室容積と可動境界・駆動軸を接続する機構"
  import SI = Modelica.Units.SI;
  import Modelica.Constants.pi;
  parameter SI.Radius R(min=1e-4)=0.024 "シリンダ内半径";
  parameter SI.Length e(min=1e-5)=0.0045 "偏心量";
  parameter SI.Length height(min=1e-4)=0.0455 "シリンダ高さ";
  parameter Real clearanceRatio(min=0.001,max=0.2)=0.025 "各ポケットの隙間容積／押しのけ容積";
  final parameter SI.Radius r=R-e "ローラ半径";
  final parameter SI.Volume displacement=pi*height*(R^2-r^2);
  Modelica.Mechanics.Rotational.Interfaces.Flange_a shaft
    annotation(Placement(transformation(extent={{-110,-10},{-90,10}})));
  Modelica.Mechanics.Translational.Interfaces.Flange_b follower
    annotation(Placement(transformation(extent={{-10,-110},{10,-90}})));
  BaseClasses.VolumePort a annotation(Placement(transformation(extent={{-55,90},{-35,110}})));
  BaseClasses.VolumePort b annotation(Placement(transformation(extent={{35,90},{55,110}})));
  Modelica.Blocks.Interfaces.BooleanOutput fillingA
    annotation(Placement(transformation(extent={{90,35},{110,55}})));
  Integer revolutions(start=0,fixed=true) "完了回転数";
  Modelica.Blocks.Interfaces.RealOutput volumeRateA(unit="m3/s")
    annotation(Placement(transformation(extent={{90,65},{110,85}})));
  SI.Angle angle "軸角 0～2π";
protected
  SI.Volume swept "当該回転の吸入側掃引容積";
  SI.Volume dV_dAngle "掃引容積の軸角微分";
  SI.Volume dVA_dAngle;
initial equation
  assert(e < R/2, "Geometry requires a roller enclosing the cylinder centre.");
equation
  revolutions = integer(shaft.phi/(2*pi));
  angle = shaft.phi - 2*pi*revolutions;
  fillingA = mod(revolutions, 2) == 0;
  a.V = clearanceRatio*displacement + (if fillingA then swept else displacement-swept);
  b.V = (1+2*clearanceRatio)*displacement - a.V;
  dVA_dAngle = if fillingA then dV_dAngle else -dV_dAngle;
  volumeRateA = dVA_dAngle*der(shaft.phi);
end PartialChamberGeometry;
