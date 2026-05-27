import 'package:flutter/material.dart';

import '../models/route_stop.dart';
import '../models/scenic_route.dart';

class RoutePreviewSheet extends StatelessWidget {
  const RoutePreviewSheet({
    required this.routes,
    required this.selectedRoute,
    required this.selectedStop,
    required this.onRouteSelected,
    required this.onStopSelected,
    required this.onWorldSelected,
    super.key,
  });

  final List<ScenicRoute> routes;
  final ScenicRoute? selectedRoute;
  final RouteStop? selectedStop;
  final ValueChanged<ScenicRoute> onRouteSelected;
  final ValueChanged<RouteStop> onStopSelected;
  final VoidCallback onWorldSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final route = selectedRoute;
    final stop = selectedStop;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 28,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 72),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const SizedBox(width: 42, height: 6),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: route == null
                    ? _RoutesHeader(colorScheme: colorScheme)
                    : _SelectedRouteHeader(
                        route: route,
                        stop: stop,
                        onWorldSelected: onWorldSelected,
                      ),
              ),
              if (route != null && route.stops.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: route.stops.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final routeStop = route.stops[index];
                      final isSelected = routeStop.id == stop?.id;

                      return ChoiceChip(
                        selected: isSelected,
                        label: Text(routeStop.name),
                        onSelected: (_) => onStopSelected(routeStop),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 18),
              SizedBox(
                height: 206,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: routes.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final routeOption = routes[index];

                    return _RouteCarouselCard(
                      route: routeOption,
                      isSelected: routeOption.id == route?.id,
                      onTap: () => onRouteSelected(routeOption),
                    );
                  },
                ),
              ),
              const SizedBox(height: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoutesHeader extends StatelessWidget {
  const _RoutesHeader({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Routes',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select a scenic drive to open its stops.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _SelectedRouteHeader extends StatelessWidget {
  const _SelectedRouteHeader({
    required this.route,
    required this.stop,
    required this.onWorldSelected,
  });

  final ScenicRoute route;
  final RouteStop? stop;
  final VoidCallback onWorldSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${route.distanceLabel} | ${route.durationLabel}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: const Color(0xFF007A63),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Back to all routes',
              onPressed: onWorldSelected,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          route.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        if (stop != null) ...[
          const SizedBox(height: 14),
          Text(
            stop!.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            stop!.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ],
    );
  }
}

class _RouteCarouselCard extends StatelessWidget {
  const _RouteCarouselCard({
    required this.route,
    required this.isSelected,
    required this.onTap,
  });

  final ScenicRoute route;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 288,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        elevation: isSelected ? 6 : 1,
        shadowColor: Colors.black.withOpacity(0.12),
        child: InkWell(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF007A63)
                    : colorScheme.surfaceVariant,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 124,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        _routeImageUrl(route.id),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => ColoredBox(
                          color: colorScheme.surfaceVariant,
                          child: const Center(
                            child: Icon(Icons.route, size: 36),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.38),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            child: Text(
                              route.distanceLabel,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _regionForRoute(route.id).toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: const Color(0xFF007A63),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _regionForRoute(String routeId) {
  return switch (routeId) {
    'tioga-pass' => 'United States',
    'amalfi-coast' => 'Italy',
    'great-ocean-road' => 'Australia',
    'garden-route' => 'South Africa',
    _ => 'Global',
  };
}

String _routeImageUrl(String routeId) {
  return switch (routeId) {
    'tioga-pass' =>
      'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=900&q=80',
    'amalfi-coast' =>
      'https://images.unsplash.com/photo-1533105079780-92b9be482077?auto=format&fit=crop&w=900&q=80',
    'great-ocean-road' =>
      'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=900&q=80',
    'garden-route' =>
      'https://images.unsplash.com/photo-1516026672322-bc52d61a55d5?auto=format&fit=crop&w=900&q=80',
    _ =>
      'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?auto=format&fit=crop&w=900&q=80',
  };
}
