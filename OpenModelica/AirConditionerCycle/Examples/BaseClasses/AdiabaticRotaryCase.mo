within AirConditionerCycle.Examples.BaseClasses;
partial model AdiabaticRotaryCase
  extends PartialRotaryCase(cycle(redeclare model Compressor =
    Components.Rotary.AdiabaticRollingPistonCompressor));
end AdiabaticRotaryCase;
