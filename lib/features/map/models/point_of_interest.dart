import 'package:latlong2/latlong.dart';

class PointOfInterest {
  const PointOfInterest({
    required this.id,
    required this.name,
    required this.description,
    required this.routeName,
    required this.position,
    required this.distanceLabel,
  });

  final String id;
  final String name;
  final String description;
  final String routeName;
  final LatLng position;
  final String distanceLabel;
}
