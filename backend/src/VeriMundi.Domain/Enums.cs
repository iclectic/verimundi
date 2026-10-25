namespace VeriMundi.Domain;

public enum SourceType
{
    Newsroom,
    Wire,
    Specialist,
    Official,
    Community,
    Aggregator,
    Other
}

public enum LicenceStatus
{
    Proposed,
    Approved,
    Restricted,
    Rejected
}

public enum ContentUsageStatus
{
    MetadataOnly,
    HeadlineAndLink,
    PermittedExcerpt,
    FullTextLicensed,
    Prohibited
}

public enum ProcessingStatus
{
    Discovered,
    Normalised,
    Clustered,
    Synthesised,
    Failed,
    Quarantined
}

public enum Severity
{
    Critical,
    Serious,
    Developing,
    General
}

public enum Tone
{
    Positive,
    Neutral,
    Concerning,
    Mixed
}

public enum VerificationStatus
{
    Confirmed,
    Developing,
    Disputed,
    Corrected,
    InsufficientEvidence
}

public enum StoryCategory
{
    Politics,
    Conflict,
    Economy,
    Climate,
    Environment,
    Science,
    Technology,
    Health,
    Education,
    Culture,
    HumanRights,
    Community,
    Sport,
    Other
}

public enum StoryStatus
{
    Active,
    Archived,
    Retracted
}

public enum CoverageClass
{
    Local,
    Regional,
    International
}

public enum ClaimStatus
{
    Confirmed,
    Disputed,
    Unverified,
    Retracted
}

public enum HumanReviewStatus
{
    None,
    Pending,
    Approved,
    Rejected
}
