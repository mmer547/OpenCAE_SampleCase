within AirConditionerCycle.Media;
package R410A "CoolProp の擬似純物質 R410A。飽和線の収支計算用微分を整合"
  extends ExternalMedia.Media.CoolPropMedium(mediumName="R410A", substanceNames={"R410A"});

  redeclare function setSat_p
    input AbsolutePressure p;
    output SaturationProperties sat;
  protected
    Modelica.Units.SI.PressureDifference dp;
    SaturationProperties upper;
    SaturationProperties lower;
  algorithm
    sat := Native.setSat_p(p);
    // Differentiate the same bubble/dew correlations used for the stored mass and energy.
    // Keep both evaluations inside the pressure domain on approach to the critical point.
    dp := min(1e-5*p, 0.25*(fluidConstants[1].criticalPressure-p));
    if dp > 0 then
      lower := Native.setSat_p(p-dp);
      upper := Native.setSat_p(p+dp);
      sat.dTp := (upper.Tsat-lower.Tsat)/(2*dp);
      sat.ddldp := (upper.dl-lower.dl)/(2*dp);
      sat.ddvdp := (upper.dv-lower.dv)/(2*dp);
      sat.dhldp := (upper.hl-lower.hl)/(2*dp);
      sat.dhvdp := (upper.hv-lower.hv)/(2*dp);
    end if;
  end setSat_p;

protected
  package Native = ExternalMedia.Media.CoolPropMedium(mediumName="R410A", substanceNames={"R410A"});
end R410A;
