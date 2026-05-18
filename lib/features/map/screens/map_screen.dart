import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/point_of_interest.dart';
import '../widgets/poi_marker.dart';
import '../widgets/route_preview_sheet.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  static const _initialCenter = LatLng(51.9851, 5.8987);

  final List<PointOfInterest> _pointsOfInterest = const [
    PointOfInterest(
      id: 'posbank-lookout',
      name: 'Posbank Lookout',
      description: 'A sweeping heathland viewpoint with winding roads nearby.',
      routeName: 'Veluwe Ridge Drive',
      position: LatLng(52.0244, 6.0144),
      distanceLabel: '42 km',
    ),
    PointOfInterest(
      id: 'rhine-bend',
      name: 'Rhine Bend',
      description: 'River views, small villages, and relaxed dike roads.',
      routeName: 'Rhine Valley Scenic Loop',
      position: LatLng(51.9706, 5.9041),
      distanceLabel: '28 km',
    ),
    PointOfInterest(
      id: 'castle-lane',
      name: 'Castle Lane',
      description: 'A calm forest lane passing estates and historic grounds.',
      routeName: 'Estate Roads Explorer',
      position: LatLng(52.0465, 5.8237),
      distanceLabel: '35 km',
    ),
  ];

  late PointOfInterest _selectedPoi = _pointsOfInterest.first;

  void _selectPoi(PointOfInterest poi) {
    setState(() => _selectedPoi = poi);
    _mapController.move(poi.position, 11.5);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 10,
              minZoom: 7,
              maxZoom: 17,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.roads_mobile_application',
              ),
              MarkerLayer(
                markers: [
                  for (final poi in _pointsOfInterest)
                    Marker(
                      point: poi.position,
                      width: 52,
                      height: 52,
                      child: PoiMarker(
                        poi: poi,
                        isSelected: poi.id == _selectedPoi.id,
                        onTap: () => _selectPoi(poi),
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
                    tooltip: 'Recenter map',
                    onPressed: () => _selectPoi(_selectedPoi),
                    icon: const Icon(Icons.my_location),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: RoutePreviewSheet(
              pointsOfInterest: _pointsOfInterest,
              selectedPoi: _selectedPoi,
              onPoiSelected: _selectPoi,
            ),
          ),
        ],
      ),
    );
  }
}
