import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/news_labels.dart';
import '../../../shared/models/news_models.dart';
import '../data/country_geojson.dart';

/// Country-polygon choropleth over public-domain Natural Earth geometries.
/// Severity is encoded with fill **and** hatch pattern + centroid icon (not colour alone).
class ChoroplethMap extends StatefulWidget {
  const ChoroplethMap({
    required this.geo,
    required this.countries,
    required this.onSelect,
    this.selectedCode,
    super.key,
  });

  final CountryGeoCollection geo;
  final List<CountryNewsStatus> countries;
  final ValueChanged<CountryNewsStatus> onSelect;
  final String? selectedCode;

  @override
  State<ChoroplethMap> createState() => _ChoroplethMapState();
}

class _ChoroplethMapState extends State<ChoroplethMap> {
  String? _hoverCode;

  Map<String, CountryNewsStatus> get _byCode => {
    for (final country in widget.countries) country.code.toUpperCase(): country,
  };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Interactive world choropleth map. Country severity uses colour, hatch pattern, and icons. '
          'Use the country list for an accessible alternative.',
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 6,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(constraints.maxWidth, constraints.maxHeight);
                  final projector = EquirectangularProjector(size);
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) {
                      final country = _hitTest(details.localPosition, projector);
                      if (country != null) {
                        widget.onSelect(country);
                      }
                    },
                    onTapUp: (_) => setState(() => _hoverCode = null),
                    child: CustomPaint(
                      size: size,
                      painter: _ChoroplethPainter(
                        geo: widget.geo,
                        byCode: _byCode,
                        brightness: Theme.of(context).brightness,
                        outline: Theme.of(context).colorScheme.outlineVariant,
                        selectedCode: widget.selectedCode?.toUpperCase(),
                        hoverCode: _hoverCode,
                        projector: projector,
                      ),
                      child: Stack(
                        children: [
                          for (final country in widget.countries)
                            if (widget.geo.byIso(country.code) != null)
                              _CentroidMarker(
                                country: country,
                                feature: widget.geo.byIso(country.code)!,
                                projector: projector,
                                selected:
                                    widget.selectedCode?.toUpperCase() ==
                                    country.code.toUpperCase(),
                                onSelect: () => widget.onSelect(country),
                              ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  CountryNewsStatus? _hitTest(Offset local, EquirectangularProjector projector) {
    // Prefer countries we have news for, highest severity first among hits.
    final hits = <CountryNewsStatus>[];
    for (final country in widget.countries) {
      final feature = widget.geo.byIso(country.code);
      if (feature == null) {
        continue;
      }
      final path = projector.pathForRings(feature.rings);
      if (path.contains(local)) {
        hits.add(country);
      }
    }
    if (hits.isEmpty) {
      return null;
    }
    hits.sort((a, b) => a.currentSeverity.index.compareTo(b.currentSeverity.index));
    return hits.first;
  }
}

class _CentroidMarker extends StatelessWidget {
  const _CentroidMarker({
    required this.country,
    required this.feature,
    required this.projector,
    required this.onSelect,
    required this.selected,
  });

  final CountryNewsStatus country;
  final CountryGeoFeature feature;
  final EquirectangularProjector projector;
  final VoidCallback onSelect;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final point = projector.project(feature.centroid);
    return Positioned(
      left: (point.dx - 16).clamp(0, projector.size.width - 32),
      top: (point.dy - 16).clamp(0, projector.size.height - 32),
      child: Semantics(
        button: true,
        label:
            '${country.name}, ${country.currentSeverity.label} severity, '
            '${country.activeStoryCount} active stories, region ${country.region}',
        child: IconButton.filledTonal(
          tooltip:
              '${country.name}: ${country.currentSeverity.label}, ${country.activeStoryCount} stories',
          isSelected: selected,
          icon: Icon(_severityIcon(country.currentSeverity), size: 16),
          color: AppSemanticColors.severity(
            country.currentSeverity,
            Theme.of(context).brightness,
          ),
          onPressed: onSelect,
        ),
      ),
    );
  }

  static IconData _severityIcon(Severity severity) => switch (severity) {
    Severity.critical => Icons.warning_amber,
    Severity.serious => Icons.priority_high,
    Severity.developing => Icons.update,
    Severity.general => Icons.info_outline,
  };
}

class _ChoroplethPainter extends CustomPainter {
  _ChoroplethPainter({
    required this.geo,
    required this.byCode,
    required this.brightness,
    required this.outline,
    required this.projector,
    this.selectedCode,
    this.hoverCode,
  });

  final CountryGeoCollection geo;
  final Map<String, CountryNewsStatus> byCode;
  final Brightness brightness;
  final Color outline;
  final EquirectangularProjector projector;
  final String? selectedCode;
  final String? hoverCode;

  @override
  void paint(Canvas canvas, Size size) {
    // Basemap: all polygons in muted fill.
    for (final feature in geo.features) {
      final path = projector.pathForRings(feature.rings);
      final status = byCode[feature.isoA2];
      final severity = status?.currentSeverity ?? Severity.general;
      final active = status != null && status.activeStoryCount > 0;
      final fill = AppSemanticColors.severity(severity, brightness).withValues(
        alpha: active ? 0.42 : 0.12,
      );
      canvas.drawPath(path, Paint()..color = fill);
      _paintHatch(canvas, path, severity, brightness);
      final isSelected = selectedCode == feature.isoA2;
      canvas.drawPath(
        path,
        Paint()
          ..color = isSelected
              ? (brightness == Brightness.dark ? Colors.white : Colors.black87)
              : outline.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 1.8 : 0.6,
      );
    }
  }

  void _paintHatch(
    Canvas canvas,
    Path path,
    Severity severity,
    Brightness brightness,
  ) {
    // Distinct non-colour cues: denser hatches for higher severity.
    final spacing = switch (severity) {
      Severity.critical => 5.0,
      Severity.serious => 7.0,
      Severity.developing => 10.0,
      Severity.general => 0.0,
    };
    if (spacing <= 0) {
      return;
    }
    canvas.save();
    canvas.clipPath(path);
    final bounds = path.getBounds();
    final paint = Paint()
      ..color = AppSemanticColors.severity(severity, brightness).withValues(alpha: 0.55)
      ..strokeWidth = severity == Severity.critical ? 1.4 : 1.0
      ..style = PaintingStyle.stroke;
    for (var x = bounds.left - bounds.height; x < bounds.right + bounds.height; x += spacing) {
      canvas.drawLine(
        Offset(x, bounds.top),
        Offset(x + bounds.height, bounds.bottom),
        paint,
      );
    }
    if (severity == Severity.critical) {
      // Cross-hatch for critical.
      for (var x = bounds.left - bounds.height; x < bounds.right + bounds.height; x += spacing) {
        canvas.drawLine(
          Offset(x, bounds.bottom),
          Offset(x + bounds.height, bounds.top),
          paint,
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ChoroplethPainter oldDelegate) =>
      oldDelegate.geo != geo ||
      oldDelegate.byCode != byCode ||
      oldDelegate.brightness != brightness ||
      oldDelegate.selectedCode != selectedCode ||
      oldDelegate.hoverCode != hoverCode ||
      oldDelegate.projector.size != projector.size;
}
