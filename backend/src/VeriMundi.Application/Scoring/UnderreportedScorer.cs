using VeriMundi.Domain;

namespace VeriMundi.Application.Scoring;

public static class UnderreportedScorer
{
    public static (double Score, string Reason) Calculate(
        Severity severity,
        int localSourceCount,
        int regionalSourceCount,
        int internationalSourceCount,
        int independentSourceCount,
        double confidence)
    {
        var importance = severity switch
        {
            Severity.Critical => 1.0,
            Severity.Serious => 0.78,
            Severity.Developing => 0.58,
            _ => 0.34
        };

        var localRegional = localSourceCount + regionalSourceCount;
        var localCoverage = Math.Clamp(localRegional / 10.0, 0, 1);
        var internationalGap = Math.Clamp(1 - (internationalSourceCount / 6.0), 0, 1);
        var independence = Math.Clamp(independentSourceCount / Math.Max(1.0, localRegional + internationalSourceCount), 0.35, 1.0);
        var confidenceAdjustment = Math.Clamp(confidence, 0.2, 1.0);

        var score = (importance * 0.40 + localCoverage * 0.25 + internationalGap * 0.25 + independence * 0.10)
                    * confidenceAdjustment
                    * 100;

        score = Math.Clamp(score, 0, 100);

        var reason =
            $"Covered by {localRegional} local or regional source{(localRegional == 1 ? string.Empty : "s")} " +
            $"but only {internationalSourceCount} international source{(internationalSourceCount == 1 ? string.Empty : "s")} " +
            $"({independentSourceCount} independent). This provisional score is a discovery aid, not a judgement of objective importance.";

        return (Math.Round(score, 2), reason);
    }
}
