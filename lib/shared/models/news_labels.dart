import 'news_models.dart';

/// Human-readable British English labels for news enums.
/// Prefer these in UI; keep `.name` for wire/API values.
extension SeverityLabel on Severity {
  String get label => switch (this) {
    Severity.critical => 'Critical',
    Severity.serious => 'Serious',
    Severity.developing => 'Developing',
    Severity.general => 'General',
  };
}

extension ToneLabel on Tone {
  String get label => switch (this) {
    Tone.positive => 'Positive',
    Tone.neutral => 'Neutral',
    Tone.concerning => 'Concerning',
    Tone.mixed => 'Mixed',
  };
}

extension VerificationStatusLabel on VerificationStatus {
  String get label => switch (this) {
    VerificationStatus.confirmed => 'Confirmed',
    VerificationStatus.developing => 'Developing',
    VerificationStatus.disputed => 'Disputed',
    VerificationStatus.corrected => 'Corrected',
    VerificationStatus.insufficientEvidence => 'Insufficient evidence',
  };
}

extension StoryCategoryLabel on StoryCategory {
  String get label => switch (this) {
    StoryCategory.politics => 'Politics',
    StoryCategory.conflict => 'Conflict',
    StoryCategory.economy => 'Economy',
    StoryCategory.climate => 'Climate',
    StoryCategory.environment => 'Environment',
    StoryCategory.science => 'Science',
    StoryCategory.technology => 'Technology',
    StoryCategory.health => 'Health',
    StoryCategory.education => 'Education',
    StoryCategory.culture => 'Culture',
    StoryCategory.humanRights => 'Human rights',
    StoryCategory.community => 'Community',
    StoryCategory.sport => 'Sport',
    StoryCategory.other => 'Other',
  };
}

extension CredibilityStatusLabel on CredibilityStatus {
  String get label => switch (this) {
    CredibilityStatus.established => 'Established',
    CredibilityStatus.specialist => 'Specialist',
    CredibilityStatus.community => 'Community',
    CredibilityStatus.unverified => 'Unverified',
    CredibilityStatus.unknown => 'Unknown',
  };
}
