import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/route_stop.dart';
import '../models/scenic_route.dart';
import 'route_repository.dart';

class SupabaseRouteRepository implements RouteRepository {
  const SupabaseRouteRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<ScenicRoute>> fetchFeaturedRoutes() async {
    final response = await _client.rpc('discover_routes') as List<dynamic>;

    return response
        .cast<Map<String, dynamic>>()
        .map(_ScenicRouteMapper.fromSupabase)
        .toList(growable: false);
  }
}

class _ScenicRouteMapper {
  const _ScenicRouteMapper._();

  static ScenicRoute fromSupabase(Map<String, dynamic> row) {
    final geometry = _jsonObject(row['geometry_geojson']);
    final coordinates = geometry['coordinates'] as List<dynamic>;
    final stops = _jsonList(row['stops']);

    return ScenicRoute(
      id: row['slug'] as String,
      name: row['name'] as String,
      description: row['description'] as String,
      distanceLabel: row['distance_label'] as String,
      durationLabel: row['duration_label'] as String,
      center: LatLng(
        (row['center_lat'] as num).toDouble(),
        (row['center_lng'] as num).toDouble(),
      ),
      path: coordinates.map(_latLngFromGeoJsonPosition).toList(growable: false),
      stops: stops
          .cast<Map<String, dynamic>>()
          .map(_routeStopFromSupabase)
          .toList(growable: false),
    );
  }

  static LatLng _latLngFromGeoJsonPosition(dynamic position) {
    final values = position as List<dynamic>;

    return LatLng(
      (values[1] as num).toDouble(),
      (values[0] as num).toDouble(),
    );
  }

  static RouteStop _routeStopFromSupabase(Map<String, dynamic> row) {
    return RouteStop(
      id: row['slug'] as String,
      name: row['name'] as String,
      description: row['description'] as String,
      position: LatLng(
        (row['lat'] as num).toDouble(),
        (row['lng'] as num).toDouble(),
      ),
    );
  }

  static Map<String, dynamic> _jsonObject(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is String) {
      return jsonDecode(value) as Map<String, dynamic>;
    }

    throw FormatException('Expected JSON object, got ${value.runtimeType}');
  }

  static List<dynamic> _jsonList(Object? value) {
    if (value is List<dynamic>) {
      return value;
    }
    if (value is String) {
      return jsonDecode(value) as List<dynamic>;
    }

    throw FormatException('Expected JSON list, got ${value.runtimeType}');
  }
}
