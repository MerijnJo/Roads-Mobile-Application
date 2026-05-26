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
    this.initialRouteId,
    super.key,
  });

  final RouteRepository routeRepository;
  final String? initialRouteId;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const double _overlayMaxWidth = 480;
  static const LatLng _worldCenter = LatLng(20, 0);

  final MapController _mapController = MapController();

  late final Future<List<ScenicRoute>> _routesFuture;
  ScenicRoute? _selectedRoute;
  RouteStop? _selectedStop;
  bool _useInitialRoute = true;

  @override
  void initState() {
    super.initState();
    _routesFuture = widget.routeRepository.fetchFeaturedRoutes();
  }

  void _selectRoute(ScenicRoute route) {
    setState(() {
      _selectedRoute = route;
      _selectedStop = route.stops.first;
      _useInitialRoute = false;
    });
    _moveTo(route.center, 9);
  }

  void _showWorld() {
    setState(() {
      _selectedRoute = null;
      _selectedStop = null;
      _useInitialRoute = false;
    });
    _moveTo(_worldCenter, 2);
  }

  void _selectStop(RouteStop stop) {
    setState(() => _selectedStop = stop);
    _moveTo(stop.position, 11);
  }

  void _moveTo(LatLng center, double zoom) {
    _mapController.move(center, zoom);
  }

  ScenicRoute? _findRoute(List<ScenicRoute> routes, String id) {
    for (final route in routes) {
      if (route.id == id) {
        return route;
      }
    }

    return null;
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

          final initialRoute = _useInitialRoute && widget.initialRouteId != null
              ? _findRoute(routes, widget.initialRouteId!)
              : null;
          final selectedRoute = _selectedRoute ?? initialRoute;
          final selectedStop = selectedRoute == null
              ? null
              : _selectedStop ?? selectedRoute.stops.first;
          final visibleRoutes = selectedRoute == null
              ? const <ScenicRoute>[]
              : <ScenicRoute>[selectedRoute];

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: selectedRoute?.center ?? _worldCenter,
                  initialZoom: selectedRoute == null ? 2 : 9,
                  minZoom: 2,
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
                      for (final route in visibleRoutes)
                        Polyline(
                          points: route.path,
                          color: colorScheme.primary,
                          strokeWidth: 7,
                        ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      if (selectedRoute == null)
                        for (final route in routes)
                          Marker(
                            point: route.stops.first.position,
                            width: 52,
                            height: 52,
                            child: _RouteEntryMarker(
                              route: route,
                              onTap: () => _selectRoute(route),
                            ),
                          )
                      else
                        for (final stop in selectedRoute.stops)
                          Marker(
                            point: stop.position,
                            width: 52,
                            height: 52,
                            child: RouteStopMarker(
                              stop: stop,
                              isPrimary: stop.id == selectedStop!.id,
                              onTap: () => _selectStop(stop),
                            ),
                          ),
                    ],
                  ),
                ],
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: _overlayMaxWidth,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            fit: FlexFit.loose,
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
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Roads',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    if (selectedRoute != null)
                                      ConstrainedBox(
                                        constraints:
                                            const BoxConstraints(maxWidth: 220),
                                        child: Text(
                                          selectedRoute.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton.filled(
                            tooltip: selectedRoute == null
                                ? 'World overview'
                                : 'Back to world',
                            onPressed: selectedRoute == null
                                ? () => _moveTo(_worldCenter, 2)
                                : _showWorld,
                            icon: Icon(
                              selectedRoute == null
                                  ? Icons.public
                                  : Icons.travel_explore,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                  onWorldSelected: _showWorld,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RouteEntryMarker extends StatelessWidget {
  const _RouteEntryMarker({
    required this.route,
    required this.onTap,
  });

  final ScenicRoute route;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: route.name,
      child: GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
            border: Border.all(color: colorScheme.surface, width: 4),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.route,
            color: colorScheme.onPrimary,
            size: 25,
          ),
        ),
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
