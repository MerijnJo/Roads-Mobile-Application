import 'package:latlong2/latlong.dart';

import 'route_stop.dart';

class ScenicRoute {
  const ScenicRoute({
    required this.id,
    required this.name,
    required this.description,
    required this.distanceLabel,
    required this.durationLabel,
    required this.center,
    required this.path,
    required this.stops,
  });

  final String id;
  final String name;
  final String description;
  final String distanceLabel;
  final String durationLabel;
  final LatLng center;
  final List<LatLng> path;
  final List<RouteStop> stops;
}
