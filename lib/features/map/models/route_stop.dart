import 'package:latlong2/latlong.dart';

class RouteStop {
  const RouteStop({
    required this.id,
    required this.name,
    required this.description,
    required this.position,
  });

  final String id;
  final String name;
  final String description;
  final LatLng position;
}
