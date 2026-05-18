import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/route_stop.dart';
import '../models/scenic_route.dart';
import '../repositories/local_route_repository.dart';
import '../repositories/route_repository.dart';
import '../widgets/route_preview_sheet.dart';
import '../widgets/route_stop_marker.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    this.routeRepository = const LocalRouteRepository(),
    super.key,
  });

  final RouteRepository routeRepository;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  late final Future<List<ScenicRoute>> _routesFuture;
  ScenicRoute? _selectedRoute;
  RouteStop? _selectedStop;

  @override
  void initState() {
    super.initState();
    _routesFuture = widget.routeRepository.fetchFeaturedRoutes();
  }

  void _selectRoute(ScenicRoute route) {
    final firstStop = route.stops.first;

    setState(() {
      _selectedRoute = route;
      _selectedStop = firstStop;
    });
    _moveTo(route.center, 9);
  }

  void _selectStop(RouteStop stop) {
    setState(() => _selectedStop = stop);
    _moveTo(stop.position, 11);
  }

  void _moveTo(LatLng center, double zoom) {
    _mapController.move(center, zoom);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: FutureBuilder<List<ScenicRoute>>(
        future: _routesFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            if (kDebugMode) {
              debugPrint('Failed to load routes: ${snapshot.error}');
              debugPrintStack(stackTrace: snapshot.stackTrace);
            }

            return _MapMessage(
              icon: Icons.cloud_off,
              title: 'Routes unavailable',
              message: 'Check the route source and try again.',
              color: colorScheme.error,
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final routes = snapshot.data!;
          if (routes.isEmpty) {
            return _MapMessage(
              icon: Icons.map_outlined,
              title: 'No routes yet',
              message: 'Add the first scenic route to start exploring.',
              color: colorScheme.primary,
            );
          }

          final selectedRoute = _selectedRoute ?? routes.first;
          final selectedStop = _selectedStop ?? selectedRoute.stops.first;

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: selectedRoute.center,
                  initialZoom: 9,
                  minZoom: 6,
                  maxZoom: 17,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName:
                        'com.example.roads_mobile_application',
                  ),
                  const RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution('OpenStreetMap contributors'),
                    ],
                  ),
                  PolylineLayer(
                    polylines: [
                      for (final route in routes)
                        Polyline(
                          points: route.path,
                          color: route.id == selectedRoute.id
                              ? colorScheme.primary
                              : colorScheme.outline,
                          strokeWidth: route.id == selectedRoute.id ? 7 : 4,
                        ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      for (final stop in selectedRoute.stops)
                        Marker(
                          point: stop.position,
                          width: 52,
                          height: 52,
                          child: RouteStopMarker(
                            stop: stop,
                            isPrimary: stop.id == selectedStop.id,
                            onTap: () => _selectStop(stop),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1F000000),
                                blurRadius: 14,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Roads',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  'Discover scenic drives nearby',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton.filled(
                        tooltip: 'Recenter route',
                        onPressed: () => _moveTo(selectedRoute.center, 9),
                        icon: const Icon(Icons.my_location),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: RoutePreviewSheet(
                  routes: routes,
                  selectedRoute: selectedRoute,
                  selectedStop: selectedStop,
                  onRouteSelected: _selectRoute,
                  onStopSelected: _selectStop,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MapMessage extends StatelessWidget {
  const _MapMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
