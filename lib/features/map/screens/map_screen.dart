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
                            width: 96,
                            height: 72,
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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: _MapSearchBar(
                      selectedRoute: selectedRoute,
                      onBackToWorld: _showWorld,
                      onTunePressed: () {},
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 16,
                bottom: 322,
                child: _MapFloatingControls(
                  onLayersPressed: () {},
                  onLocationPressed: selectedRoute == null
                      ? () => _moveTo(_worldCenter, 2)
                      : () => _moveTo(selectedRoute.center, 9),
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
              const Align(
                alignment: Alignment.bottomCenter,
                child: _MapBottomNav(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MapSearchBar extends StatelessWidget {
  const _MapSearchBar({
    required this.selectedRoute,
    required this.onBackToWorld,
    required this.onTunePressed,
  });

  final ScenicRoute? selectedRoute;
  final VoidCallback onBackToWorld;
  final VoidCallback onTunePressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(0.90),
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              const SizedBox(width: 8),
              IconButton(
                tooltip: selectedRoute == null ? 'Search' : 'Back to routes',
                onPressed: selectedRoute == null ? () {} : onBackToWorld,
                icon: Icon(
                  selectedRoute == null ? Icons.search : Icons.arrow_back,
                  color: colorScheme.primary,
                ),
              ),
              Expanded(
                child: Text(
                  selectedRoute?.name ?? 'Explore Scenic Routes',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              IconButton(
                tooltip: 'Filters',
                onPressed: onTunePressed,
                icon: Icon(Icons.tune, color: colorScheme.primary),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapFloatingControls extends StatelessWidget {
  const _MapFloatingControls({
    required this.onLayersPressed,
    required this.onLocationPressed,
  });

  final VoidCallback onLayersPressed;
  final VoidCallback onLocationPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RoundMapButton(
          icon: Icons.layers_outlined,
          onPressed: onLayersPressed,
          color: colorScheme.surface,
          foregroundColor: colorScheme.primary,
        ),
        const SizedBox(height: 12),
        _RoundMapButton(
          icon: Icons.my_location,
          onPressed: onLocationPressed,
          color: const Color(0xFF007A63),
          foregroundColor: Colors.white,
        ),
      ],
    );
  }
}

class _RoundMapButton extends StatelessWidget {
  const _RoundMapButton({
    required this.icon,
    required this.onPressed,
    required this.color,
    required this.foregroundColor,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      elevation: 8,
      child: IconButton(
        tooltip: 'Map control',
        onPressed: onPressed,
        icon: Icon(icon, color: foregroundColor),
      ),
    );
  }
}

class _MapBottomNav extends StatelessWidget {
  const _MapBottomNav();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xEEF8F9FD),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _MapNavItem(
                icon: Icons.explore_outlined,
                label: 'Explore',
                isSelected: true,
              ),
              _MapNavItem(icon: Icons.bookmark_border, label: 'Saved'),
              _MapNavItem(icon: Icons.person_outline, label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapNavItem extends StatelessWidget {
  const _MapNavItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
  });

  final IconData icon;
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? const Color(0xFF007A63)
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return SizedBox(
      width: 88,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
          ),
          const SizedBox(height: 3),
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: isSelected ? 4 : 0,
            height: 4,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ],
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
    return Tooltip(
      message: route.name,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF007A63),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const SizedBox(
                width: 42,
                height: 42,
                child: Icon(Icons.route, color: Colors.white, size: 22),
              ),
            ),
            const SizedBox(height: 4),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                child: Text(
                  _shortRouteLabel(route.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF007A63),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shortRouteLabel(String name) {
    if (name.contains('Amalfi')) {
      return 'Amalfi';
    }
    if (name.contains('Garden')) {
      return 'Garden';
    }
    if (name.contains('Ocean')) {
      return 'Ocean Road';
    }
    if (name.contains('Tioga')) {
      return 'Tioga';
    }

    return name;
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
