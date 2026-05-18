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
    super.key,
  });

  final List<ScenicRoute> routes;
  final ScenicRoute selectedRoute;
  final RouteStop selectedStop;
  final ValueChanged<ScenicRoute> onRouteSelected;
  final ValueChanged<RouteStop> onStopSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedRoute.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${selectedRoute.distanceLabel} | ${selectedRoute.durationLabel}',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                selectedRoute.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                selectedStop.name,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                selectedStop.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedRoute.stops.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final stop = selectedRoute.stops[index];
                    final isSelected = stop.id == selectedStop.id;

                    return ChoiceChip(
                      selected: isSelected,
                      label: Text(stop.name),
                      onSelected: (_) => onStopSelected(stop),
                    );
                  },
                ),
              ),
              if (routes.length > 1) ...[
                const SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: routes.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final route = routes[index];
                      final isSelected = route.id == selectedRoute.id;

                      return ChoiceChip(
                        selected: isSelected,
                        label: Text(route.name),
                        onSelected: (_) => onRouteSelected(route),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
