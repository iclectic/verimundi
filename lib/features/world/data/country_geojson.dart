import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';

/// Minimal Natural Earth–derived country polygon set (ISO-A2 keyed).
class CountryGeoFeature {
  const CountryGeoFeature({
    required this.isoA2,
    required this.name,
    required this.rings,
  });

  final String isoA2;
  final String name;

  /// Outer rings as lon/lat pairs (degrees). Holes omitted for choropleth fill.
  final List<List<Offset>> rings;

  Offset get centroid {
    var sumX = 0.0;
    var sumY = 0.0;
    var count = 0;
    for (final ring in rings) {
      for (final point in ring) {
        sumX += point.dx;
        sumY += point.dy;
        count++;
      }
    }
    if (count == 0) {
      return Offset.zero;
    }
    return Offset(sumX / count, sumY / count);
  }
}

class CountryGeoCollection {
  const CountryGeoCollection(this.features);

  final List<CountryGeoFeature> features;

  CountryGeoFeature? byIso(String code) {
    final needle = code.trim().toUpperCase();
    for (final feature in features) {
      if (feature.isoA2 == needle) {
        return feature;
      }
    }
    return null;
  }
}

/// Loads and parses `assets/geo/countries_110m.geojson` (public-domain Natural Earth).
class CountryGeoJsonRepository {
  CountryGeoJsonRepository({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  static const assetPath = 'assets/geo/countries_110m.geojson';

  final AssetBundle _bundle;
  CountryGeoCollection? _cached;

  Future<CountryGeoCollection> load() async {
    if (_cached != null) {
      return _cached!;
    }
    final raw = await _bundle.loadString(assetPath);
    _cached = parse(raw);
    return _cached!;
  }

  /// Pure parser for tests / fixtures.
  static CountryGeoCollection parse(String raw) {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final featuresJson = decoded['features'] as List<dynamic>? ?? const [];
    final features = <CountryGeoFeature>[];

    for (final item in featuresJson) {
      final map = item as Map<String, dynamic>;
      final props = map['properties'] as Map<String, dynamic>? ?? const {};
      final iso = (props['isoA2'] as String? ?? '').trim().toUpperCase();
      if (iso.isEmpty) {
        continue;
      }
      final name = props['name'] as String? ?? iso;
      final geometry = map['geometry'] as Map<String, dynamic>?;
      if (geometry == null) {
        continue;
      }
      final rings = _outerRings(geometry);
      if (rings.isEmpty) {
        continue;
      }
      features.add(CountryGeoFeature(isoA2: iso, name: name, rings: rings));
    }

    return CountryGeoCollection(features);
  }

  static List<List<Offset>> _outerRings(Map<String, dynamic> geometry) {
    final type = geometry['type'] as String? ?? '';
    final coordinates = geometry['coordinates'];
    final rings = <List<Offset>>[];

    if (type == 'Polygon' && coordinates is List) {
      final outer = _ring(coordinates.first as List<dynamic>);
      if (outer.length >= 3) {
        rings.add(outer);
      }
    } else if (type == 'MultiPolygon' && coordinates is List) {
      for (final polygon in coordinates) {
        if (polygon is! List || polygon.isEmpty) {
          continue;
        }
        final outer = _ring(polygon.first as List<dynamic>);
        if (outer.length >= 3) {
          rings.add(outer);
        }
      }
    }

    return rings;
  }

  static List<Offset> _ring(List<dynamic> coords) {
    final points = <Offset>[];
    for (final pair in coords) {
      if (pair is! List || pair.length < 2) {
        continue;
      }
      final lon = (pair[0] as num).toDouble();
      final lat = (pair[1] as num).toDouble();
      points.add(Offset(lon, lat));
    }
    return points;
  }
}

/// Equirectangular projection helpers shared by painters and hit-testing.
class EquirectangularProjector {
  const EquirectangularProjector(this.size);

  final Size size;

  Offset project(Offset lonLat) {
    final x = ((lonLat.dx + 180) / 360) * size.width;
    final y = ((90 - lonLat.dy) / 180) * size.height;
    return Offset(x, y);
  }

  Path pathForRings(List<List<Offset>> rings) {
    final path = Path();
    for (final ring in rings) {
      if (ring.isEmpty) {
        continue;
      }
      final first = project(ring.first);
      path.moveTo(first.dx, first.dy);
      for (var i = 1; i < ring.length; i++) {
        final point = project(ring[i]);
        path.lineTo(point.dx, point.dy);
      }
      path.close();
    }
    return path;
  }
}
