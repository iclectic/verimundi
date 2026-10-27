/// Canonical problem-report reasons. Keep aligned with
/// `VeriMundi.Application.Safety.StoryReportReasons` on the API.
class ReportReasons {
  const ReportReasons._();

  static const int maxDetailsLength = 500;

  static const List<String> all = [
    'Incorrect summary',
    'Unsupported claim',
    'Outdated information',
    'Misleading classification',
    'Broken source',
    'Other',
  ];

  static bool isAllowed(String reason) => all.contains(reason.trim());
}
