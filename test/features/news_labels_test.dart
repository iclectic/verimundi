import 'package:flutter_test/flutter_test.dart';
import 'package:verimundi/shared/models/news_labels.dart';
import 'package:verimundi/shared/models/news_models.dart';

void main() {
  test('verification labels use British English phrasing', () {
    expect(
      VerificationStatus.insufficientEvidence.label,
      'Insufficient evidence',
    );
    expect(VerificationStatus.confirmed.label, 'Confirmed');
    expect(StoryCategory.humanRights.label, 'Human rights');
    expect(Severity.critical.label, 'Critical');
    expect(Tone.concerning.label, 'Concerning');
  });
}
