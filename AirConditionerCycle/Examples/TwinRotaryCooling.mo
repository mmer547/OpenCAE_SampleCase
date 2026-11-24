within AirConditionerCycle.Examples;
model TwinRotaryCooling "180度位相差の断熱ツインロータリーを組み込んだ冷房回路"
  extends RatedCooling(cycle(redeclare model Compressor=Components.Rotary.TwinRotaryCompressor,
    compressor(pSuctionStart=cycle.Medium.saturationPressure(cycle.evaporator.T_start),
      pDischargeStart=cycle.Medium.saturationPressure(cycle.condenser.T_start),
      hSuctionStart=cycle.Medium.specificEnthalpy_pT(cycle.compressor.pSuctionStart,
        cycle.evaporator.T_start+cycle.evaporator.superheat))));
  annotation(experiment(StartTime=0,StopTime=0.21,Interval=0.000025,Tolerance=1e-7),
    Documentation(info="<html><p>cycle.Q_cooling、cycle.compressor.upper.reed.lift、cycle.compressor.lower.reed.lift、cycle.compressor.losses.meanPower を表示できます。サイクル全体の蓄積には圧縮機の charge と E を含みます。</p></html>"));
end TwinRotaryCooling;
