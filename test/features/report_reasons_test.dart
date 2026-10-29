import 'package:flutter_test/flutter_test.dart';
import 'package:verimundi/core/constants/report_reasons.dart';

void main() {
  test('report reasons match allowlisted editorial categories', () {
    expect(ReportReasons.all, contains('Incorrect summary'));
    expect(ReportReasons.all, contains('Other'));
    expect(ReportReasons.isAllowed('Broken source'), isTrue);
    expect(ReportReasons.isAllowed('spam'), isFalse);
    expect(ReportReasons.isAllowed('  Other  '), isTrue);
    expect(ReportReasons.maxDetailsLength, 500);
  });
}
