within AirConditionerCycle.Examples;
package RefrigerantTests "R290・R32・R410A・CO₂ の冷房試験"
  extends Modelica.Icons.ExamplesPackage;

  partial model StandardCase
    replaceable package Refrigerant = Media.R134a constrainedby Modelica.Media.Interfaces.PartialTwoPhaseMedium;
    parameter Modelica.Units.SI.Temperature outdoorTemperature=308.15;
    parameter Modelica.Units.SI.Temperature evaporatingStart=280.15;
    parameter Modelica.Units.SI.Temperature condensingStart=318.15;
    extends RatedCooling(outdoor(T=outdoorTemperature), cycle(
      redeclare package Medium=Refrigerant,
      evaporator(T_start=evaporatingStart), condenser(T_start=condensingStart)));
    annotation(experiment(StartTime=0, StopTime=600, Interval=0.5, Tolerance=1e-7));
  end StandardCase;

  partial model PartialRotaryCase
    replaceable package Refrigerant = Media.R134a constrainedby Modelica.Media.Interfaces.PartialTwoPhaseMedium;
    parameter Modelica.Units.SI.Temperature outdoorTemperature=308.15;
    parameter Modelica.Units.SI.Temperature evaporatingStart=280.15;
    parameter Modelica.Units.SI.Temperature condensingStart=318.15;
    parameter Real shellPressureRatio=1.004 "初期シェル圧力／初期凝縮圧力";
    parameter Real mufflerPressureRatio=1.011;
    parameter Real pocketAPressureRatio=1.013;
    final parameter Refrigerant.AbsolutePressure pL=Refrigerant.saturationPressure(evaporatingStart);
    final parameter Refrigerant.AbsolutePressure pH=Refrigerant.saturationPressure(condensingStart);
    final parameter Refrigerant.SpecificEnthalpy hS=
      Refrigerant.specificEnthalpy_pT(pL,evaporatingStart+cycle.evaporator.superheat);
    final parameter Refrigerant.SpecificEnthalpy hD=hS+
      (Refrigerant.isentropicEnthalpy(pH,Refrigerant.setState_ph(pL,hS))-hS)/0.72
      "運転開始時の吐出ガスの初期値";
    extends RotaryCooling(outdoor(T=outdoorTemperature), cycle(
      redeclare package Medium=Refrigerant,
      evaporator(T_start=evaporatingStart), condenser(T_start=condensingStart),
      compressor(
        accumulator(p_start=0.989*pL,h_start=hS),
        suctionPipe(outlet(p(start=0.989*pL))),
        cylinder(inlet(p(start=0.989*pL)),pocketB(p_start=0.988*pL,h_start=hS),
          pocketA(p_start=pocketAPressureRatio*pH,h_start=hD)),
        muffler(p_start=mufflerPressureRatio*pH,h_start=hD),
        shell(p_start=shellPressureRatio*pH,h_start=hD))));
    annotation(experiment(StartTime=0, StopTime=0.21, Interval=0.000025, Tolerance=1e-7));
  end PartialRotaryCase;

  partial model RotaryCase
    extends PartialRotaryCase(cycle(compressor(shell(Twall_start=wallStart,Tambient=outdoorTemperature))));
    parameter Modelica.Units.SI.Temperature wallStart=330.15;
  end RotaryCase;

  partial model AdiabaticRotaryCase
    extends PartialRotaryCase(cycle(redeclare model Compressor =
      Components.Rotary.AdiabaticRollingPistonCompressor));
  end AdiabaticRotaryCase;

  model R290Standard
    extends StandardCase(redeclare package Refrigerant=Media.R290);
  end R290Standard;
  model R290Rotary
    extends RotaryCase(redeclare package Refrigerant=Media.R290);
  end R290Rotary;
  model R290AdiabaticCooling
    extends AdiabaticRotaryCase(redeclare package Refrigerant=Media.R290);
  end R290AdiabaticCooling;
  model R32Standard
    extends StandardCase(redeclare package Refrigerant=Media.R32);
  end R32Standard;
  model R32Rotary
    extends RotaryCase(redeclare package Refrigerant=Media.R32,
      shellPressureRatio=1.012,mufflerPressureRatio=1.025,pocketAPressureRatio=1.03,
      wallStart=Refrigerant.temperature_ph(pH,hD));
  end R32Rotary;
  model R32AdiabaticCooling
    extends AdiabaticRotaryCase(redeclare package Refrigerant=Media.R32,
      shellPressureRatio=1.012,mufflerPressureRatio=1.025,pocketAPressureRatio=1.03);
  end R32AdiabaticCooling;
  model R410AStandard
    extends StandardCase(redeclare package Refrigerant=Media.R410A);
  end R410AStandard;
  model R410ARotary
    extends RotaryCase(redeclare package Refrigerant=Media.R410A);
  end R410ARotary;
  model R410AAdiabaticCooling
    extends AdiabaticRotaryCase(redeclare package Refrigerant=Media.R410A);
  end R410AAdiabaticCooling;
  model CO2SubcriticalStandard "R744、外気 -10 °C の亜臨界試験"
    extends StandardCase(redeclare package Refrigerant=Media.CO2,
      outdoorTemperature=263.15,evaporatingStart=263.15,condensingStart=281.15);
  end CO2SubcriticalStandard;
  model CO2SubcriticalRotary "R744、外気 -10 °C の亜臨界試験"
    extends RotaryCase(redeclare package Refrigerant=Media.CO2,
      outdoorTemperature=263.15,evaporatingStart=263.15,condensingStart=281.15,
      shellPressureRatio=1.012,mufflerPressureRatio=1.025,pocketAPressureRatio=1.03,
      wallStart=Refrigerant.temperature_ph(pH,hD));
    annotation(experiment(StartTime=0,StopTime=0.23,Interval=0.000025,Tolerance=1e-7));
  end CO2SubcriticalRotary;
  model CO2SubcriticalAdiabaticCooling "R744、外気 -10 °C の亜臨界試験"
    extends AdiabaticRotaryCase(redeclare package Refrigerant=Media.CO2,
      outdoorTemperature=263.15,evaporatingStart=263.15,condensingStart=281.15,
      shellPressureRatio=1.012,mufflerPressureRatio=1.025,pocketAPressureRatio=1.03);
    annotation(experiment(StartTime=0,StopTime=0.23,Interval=0.000025,Tolerance=1e-7));
  end CO2SubcriticalAdiabaticCooling;
  model R290Standalone "R290 ロータリー圧縮機単体"
    extends RotaryCompressorStandalone(redeclare package Medium=Media.R290);
  end R290Standalone;
  model R32Standalone "R32 ロータリー圧縮機単体"
    extends RotaryCompressorStandalone(redeclare package Medium=Media.R32);
  end R32Standalone;
  model R410AStandalone "R410A ロータリー圧縮機単体"
    extends RotaryCompressorStandalone(redeclare package Medium=Media.R410A);
  end R410AStandalone;
  model CO2SubcriticalStandalone "CO₂ ロータリー圧縮機単体・亜臨界圧力条件"
    extends RotaryCompressorStandalone(redeclare package Medium=Media.CO2,
      suctionPressure=Medium.saturationPressure(263.15),dischargePressure=Medium.saturationPressure(281.15),
      ambientTemperature=263.15);
  end CO2SubcriticalStandalone;
  model R290LossTest "R290 損失評価"
    extends R290Standalone(useDetailedLosses=true);
  end R290LossTest;
  model R32LossTest "R32 損失評価"
    extends R32Standalone(useDetailedLosses=true);
  end R32LossTest;
  model R410ALossTest "R410A 損失評価"
    extends R410AStandalone(useDetailedLosses=true);
  end R410ALossTest;
  model CO2SubcriticalLossTest "CO2Subcritical 損失評価"
    extends CO2SubcriticalStandalone(useDetailedLosses=true);
    annotation(experiment(StartTime=0,StopTime=0.23,Interval=0.0000125,Tolerance=3e-8));
  end CO2SubcriticalLossTest;
  model R290AdiabaticStandalone "R290 断熱ロータリー単体"
    extends AdiabaticRotaryStandalone(redeclare package Medium=Media.R290);
  end R290AdiabaticStandalone;
  model R32AdiabaticStandalone "R32 断熱ロータリー単体"
    extends AdiabaticRotaryStandalone(redeclare package Medium=Media.R32);
  end R32AdiabaticStandalone;
  model R410AAdiabaticStandalone "R410A 断熱ロータリー単体"
    extends AdiabaticRotaryStandalone(redeclare package Medium=Media.R410A);
  end R410AAdiabaticStandalone;
  model CO2SubcriticalAdiabaticStandalone "CO2 断熱ロータリー単体"
    extends AdiabaticRotaryStandalone(redeclare package Medium=Media.CO2,
      suctionPressure=Medium.saturationPressure(263.15), dischargePressure=Medium.saturationPressure(281.15));
    annotation(experiment(StartTime=0,StopTime=0.23,Interval=0.0000125,Tolerance=3e-8));
  end CO2SubcriticalAdiabaticStandalone;

  model R290TwinStandalone
    extends TwinRotaryStandalone(redeclare package Medium=Media.R290);
  end R290TwinStandalone;

  model R290TwinCooling
    extends TwinRotaryCooling(cycle(redeclare package Medium=Media.R290));
  end R290TwinCooling;

  model R32TwinStandalone
    extends TwinRotaryStandalone(redeclare package Medium=Media.R32);
  end R32TwinStandalone;

  model R32TwinCooling
    extends TwinRotaryCooling(cycle(redeclare package Medium=Media.R32));
  end R32TwinCooling;

  model R410ATwinStandalone
    extends TwinRotaryStandalone(redeclare package Medium=Media.R410A);
  end R410ATwinStandalone;

  model R410ATwinCooling
    extends TwinRotaryCooling(cycle(redeclare package Medium=Media.R410A));
  end R410ATwinCooling;

  model CO2SubcriticalTwinStandalone
    extends TwinRotaryStandalone(redeclare package Medium=Media.CO2,
      suctionPressure=Medium.saturationPressure(263.15), dischargePressure=Medium.saturationPressure(281.15));
  end CO2SubcriticalTwinStandalone;

  model CO2SubcriticalTwinCooling
    extends TwinRotaryCooling(outdoor(T=263.15), cycle(redeclare package Medium=Media.CO2,
      evaporator(T_start=263.15), condenser(T_start=281.15)));
  end CO2SubcriticalTwinCooling;
  annotation(Documentation(info="<html><p>冷凍サイクル例の室内温度は 25 °C。Standalone は吸入・吐出リザーバを使う圧縮機単体試験です。R290、R32、R410A は外気 35 °C、CO₂ は外気 −10 °C の亜臨界運転を対象とします。CO₂ の臨界温度は 30.98 °C であり、外気 35 °C の放熱には高圧側ガスクーラが必要です。</p></html>"));
end RefrigerantTests;
