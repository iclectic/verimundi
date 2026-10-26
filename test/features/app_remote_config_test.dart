import 'package:flutter_test/flutter_test.dart';
import 'package:verimundi/core/network/app_remote_config.dart';

void main() {
  group('AppRemoteConfig.isBelowMinimum', () {
    test('detects older patch versions', () {
      expect(
        AppRemoteConfig.isBelowMinimum(current: '1.0.0', minimum: '1.0.1'),
        isTrue,
      );
    });

    test('accepts equal and newer versions', () {
      expect(
        AppRemoteConfig.isBelowMinimum(current: '1.0.0', minimum: '1.0.0'),
        isFalse,
      );
      expect(
        AppRemoteConfig.isBelowMinimum(current: '1.2.0', minimum: '1.0.5'),
        isFalse,
      );
    });

    test('ignores build metadata suffixes', () {
      expect(
        AppRemoteConfig.isBelowMinimum(current: '1.0.0+12', minimum: '1.0.0'),
        isFalse,
      );
      expect(
        AppRemoteConfig.isBelowMinimum(current: '0.9.9+99', minimum: '1.0.0'),
        isTrue,
      );
    });
  });

  group('AppRemoteConfig.fromJson', () {
    test('parses maintenance and ingestion flags', () {
      final config = AppRemoteConfig.fromJson({
        'environment': 'Development',
        'maintenanceMode': true,
        'maintenanceMessage': 'Back soon',
        'minimumAppVersion': '1.1.0',
        'ingestion': {'enableRss': false, 'enableGdelt': true},
        'disclaimer': 'Read carefully',
      });

      expect(config.maintenanceMode, isTrue);
      expect(config.maintenanceMessage, 'Back soon');
      expect(config.minimumAppVersion, '1.1.0');
      expect(config.enableRss, isFalse);
      expect(config.enableGdelt, isTrue);
      expect(config.disclaimer, 'Read carefully');
    });
  });
}
