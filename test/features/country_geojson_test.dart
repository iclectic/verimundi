import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verimundi/features/world/data/country_geojson.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('parses Natural Earth–style FeatureCollection with isoA2 rings', () {
    const raw = '''
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {"isoA2": "NG", "name": "Nigeria"},
      "geometry": {
        "type": "Polygon",
        "coordinates": [[[2.7,4.3],[14.6,4.3],[14.6,13.9],[2.7,13.9],[2.7,4.3]]]
      }
    },
    {
      "type": "Feature",
      "properties": {"isoA2": "JP", "name": "Japan"},
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [[[[129.4,31.0],[145.8,31.0],[145.8,45.5],[129.4,45.5],[129.4,31.0]]]]
      }
    },
    {
      "type": "Feature",
      "properties": {"isoA2": "", "name": "Skip"},
      "geometry": {"type": "Polygon", "coordinates": [[[0,0],[1,0],[1,1],[0,0]]]}
    }
  ]
}
''';

    final collection = CountryGeoJsonRepository.parse(raw);
    expect(collection.features, hasLength(2));
    expect(collection.byIso('ng')?.name, 'Nigeria');
    expect(collection.byIso('JP')?.rings, isNotEmpty);
    expect(collection.byIso('NG')!.centroid.dx, closeTo(7.46, 0.2));
  });

  test('vendored asset loads and includes seeded ISO codes', () async {
    final collection = await CountryGeoJsonRepository(
      bundle: rootBundle,
    ).load();
    expect(collection.features.length, greaterThan(100));
    for (final code in ['NG', 'JP', 'US', 'BR', 'AU', 'GB']) {
      expect(collection.byIso(code), isNotNull, reason: code);
      expect(collection.byIso(code)!.rings.first.length, greaterThanOrEqualTo(3));
    }
  });

  test('equirectangular projector builds closed paths', () {
    const projector = EquirectangularProjector(Size(360, 180));
    final path = projector.pathForRings([
      [const Offset(-10, 10), const Offset(10, 10), const Offset(10, -10), const Offset(-10, -10)],
    ]);
    expect(path.getBounds().width, greaterThan(0));
    expect(path.contains(const Offset(180, 90)), isTrue);
  });
}
