import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../map/models/scenic_route.dart';
import '../../map/repositories/route_repository.dart';
import '../../map/screens/map_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({
    required this.routeRepository,
    super.key,
  });

  final RouteRepository routeRepository;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late Future<List<ScenicRoute>> _routesFuture;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  void _loadRoutes() {
    _routesFuture = widget.routeRepository.fetchFeaturedRoutes();
  }

  void _openMap([ScenicRoute? route]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MapScreen(
          routeRepository: widget.routeRepository,
          initialRouteId: route?.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<ScenicRoute>>(
          future: _routesFuture,
          builder: (context, snapshot) {
            final routes = snapshot.data ?? const <ScenicRoute>[];

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _TopBar(onSearchPressed: () {}),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                    child: Column(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0xFF6DFAD2).withOpacity(0.35),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            child: Text(
                              'EXPLORE GLOBALLY'.toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: const Color(0xFF006B55),
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2.4,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Discover your next route',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: const Color(0xFF191C1F),
                                fontWeight: FontWeight.w800,
                                height: 1.05,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: _GlobeOverview(
                      routes: routes,
                      isLoading: snapshot.connectionState !=
                          ConnectionState.done,
                      onRouteSelected: _openMap,
                      onExplorePressed: () => _openMap(),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
                    child: Text(
                      'Trending Adventures',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ),
                if (snapshot.hasError)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _ErrorPanel(
                        onRetry: () => setState(_loadRoutes),
                      ),
                    ),
                  )
                else if (routes.isEmpty &&
                    snapshot.connectionState != ConnectionState.done)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: _LoadingRoutes(),
                    ),
                  )
                else if (routes.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: _EmptyRoutes(),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                      child: _TrendingRoutesGrid(
                        routes: routes,
                        onRouteSelected: _openMap,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const _BottomNavBar(),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onSearchPressed});

  final VoidCallback onSearchPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xCCF8F9FD),
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              Icon(Icons.explore_outlined, color: colorScheme.primary),
              const SizedBox(width: 10),
              Text(
                'Roads',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Search',
                onPressed: onSearchPressed,
                icon: const Icon(Icons.search),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlobeOverview extends StatelessWidget {
  const _GlobeOverview({
    required this.routes,
    required this.isLoading,
    required this.onRouteSelected,
    required this.onExplorePressed,
  });

  final List<ScenicRoute> routes;
  final bool isLoading;
  final ValueChanged<ScenicRoute> onRouteSelected;
  final VoidCallback onExplorePressed;

  @override
  Widget build(BuildContext context) {
    final markerRoutes = routes.take(6).toList(growable: false);

    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE1E2E6),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF64748B).withOpacity(0.18),
                    blurRadius: 30,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: ClipOval(
                child: CustomPaint(
                  painter: _WorldPainter(),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Stack(
                  children: [
                    for (final route in markerRoutes)
                      _GlobeRouteMarker(
                        route: route,
                        size: constraints.biggest.shortestSide,
                        onTap: () => onRouteSelected(route),
                      ),
                  ],
                );
              },
            ),
          ),
          Positioned(
            right: -2,
            bottom: 76,
            child: _RoundGlobeButton(
              icon: Icons.add,
              onPressed: onExplorePressed,
              color: Colors.white,
              foregroundColor: const Color(0xFF191C1F),
            ),
          ),
          Positioned(
            right: -2,
            bottom: 20,
            child: _RoundGlobeButton(
              icon: Icons.remove,
              onPressed: onExplorePressed,
              color: Colors.white,
              foregroundColor: const Color(0xFF191C1F),
            ),
          ),
          Positioned(
            right: -2,
            bottom: -36,
            child: _RoundGlobeButton(
              icon: Icons.my_location,
              onPressed: onExplorePressed,
              color: const Color(0xFF007A63),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlobeRouteMarker extends StatelessWidget {
  const _GlobeRouteMarker({
    required this.route,
    required this.size,
    required this.onTap,
  });

  final ScenicRoute route;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final position = _projectToGlobe(route.center.latitude, route.center.longitude);

    return Positioned(
      left: (position.dx * size) - 11,
      top: (position.dy * size) - 11,
      child: Tooltip(
        message: route.name,
        child: GestureDetector(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF007A63),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF007A63).withOpacity(0.28),
                  blurRadius: 16,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: const SizedBox(width: 22, height: 22),
          ),
        ),
      ),
    );
  }

  Offset _projectToGlobe(double lat, double lng) {
    final x = ((lng + 180) / 360).clamp(0.08, 0.92);
    final y = ((90 - lat) / 180).clamp(0.16, 0.84);

    return Offset(x.toDouble(), y.toDouble());
  }
}

class _TrendingRoutesGrid extends StatelessWidget {
  const _TrendingRoutesGrid({
    required this.routes,
    required this.onRouteSelected,
  });

  final List<ScenicRoute> routes;
  final ValueChanged<ScenicRoute> onRouteSelected;

  @override
  Widget build(BuildContext context) {
    final visibleRoutes = routes.take(4).toList(growable: false);

    return Column(
      children: [
        for (var index = 0; index < visibleRoutes.length; index++)
          if (index == 1 && visibleRoutes.length > 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: SizedBox(
                height: 204,
                child: Row(
                  children: [
                    Expanded(
                      child: _RouteAdventureCard(
                        route: visibleRoutes[index],
                        imageUrl: _routeImageUrl(visibleRoutes[index].id),
                        isWide: false,
                        onTap: () => onRouteSelected(visibleRoutes[index]),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _RouteAdventureCard(
                        route: visibleRoutes[index + 1],
                        imageUrl: _routeImageUrl(visibleRoutes[index + 1].id),
                        isWide: false,
                        onTap: () => onRouteSelected(visibleRoutes[index + 1]),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (index == 2 && visibleRoutes.length > 2)
            const SizedBox.shrink()
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: SizedBox(
                height: 204,
                width: double.infinity,
                child: _RouteAdventureCard(
                  route: visibleRoutes[index],
                  imageUrl: _routeImageUrl(visibleRoutes[index].id),
                  isWide: true,
                  onTap: () => onRouteSelected(visibleRoutes[index]),
                ),
              ),
            ),
      ],
    );
  }
}

class _RoundGlobeButton extends StatelessWidget {
  const _RoundGlobeButton({
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
        tooltip: 'Open map',
        onPressed: onPressed,
        icon: Icon(icon, color: foregroundColor),
      ),
    );
  }
}

class _RouteAdventureCard extends StatelessWidget {
  const _RouteAdventureCard({
    required this.route,
    required this.imageUrl,
    required this.isWide,
    required this.onTap,
  });

  final ScenicRoute route;
  final String imageUrl;
  final bool isWide;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => ColoredBox(
                  color: const Color(0xFFE1E2E6),
                  child: CustomPaint(painter: _CardPatternPainter()),
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xCC000000)],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _regionForRoute(route.id).toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: const Color(0xFF6DFAD2),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      route.name,
                      maxLines: isWide ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xEEF8F9FD),
        border: Border(top: BorderSide(color: Color(0xFFE1E2E6))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _NavItem(icon: Icons.public, label: 'Explore', isSelected: true),
              _NavItem(icon: Icons.bookmark_border, label: 'Saved'),
              _NavItem(icon: Icons.person_outline, label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
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

class _LoadingRoutes extends StatelessWidget {
  const _LoadingRoutes();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 120,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _EmptyRoutes extends StatelessWidget {
  const _EmptyRoutes();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Text(
          'No routes yet.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Routes unavailable. Check the route source and try again.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _WorldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.55)
      ..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 1; i < 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    _drawBlob(canvas, size, paint, const [
      Offset(0.16, 0.34),
      Offset(0.29, 0.28),
      Offset(0.38, 0.42),
      Offset(0.30, 0.58),
      Offset(0.17, 0.52),
    ]);
    _drawBlob(canvas, size, paint, const [
      Offset(0.45, 0.30),
      Offset(0.56, 0.25),
      Offset(0.68, 0.34),
      Offset(0.63, 0.46),
      Offset(0.48, 0.42),
    ]);
    _drawBlob(canvas, size, paint, const [
      Offset(0.51, 0.47),
      Offset(0.61, 0.55),
      Offset(0.58, 0.72),
      Offset(0.47, 0.68),
      Offset(0.43, 0.56),
    ]);
    _drawBlob(canvas, size, paint, const [
      Offset(0.70, 0.52),
      Offset(0.82, 0.58),
      Offset(0.79, 0.72),
      Offset(0.67, 0.68),
    ]);

    final shade = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.45),
        radius: 0.95,
        colors: [
          Colors.white.withOpacity(0.22),
          Colors.black.withOpacity(0.10),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      shade,
    );
  }

  void _drawBlob(
    Canvas canvas,
    Size size,
    Paint paint,
    List<Offset> points,
  ) {
    final path = Path()
      ..moveTo(points.first.dx * size.width, points.first.dy * size.height);

    for (final point in points.skip(1)) {
      path.lineTo(point.dx * size.width, point.dy * size.height);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    for (var i = 0; i < 7; i++) {
      final y = size.height * (i + 1) / 8;
      final path = Path()..moveTo(0, y);
      for (var x = 0.0; x <= size.width; x += 24) {
        path.lineTo(x, y + math.sin((x / 24) + i) * 8);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

String _regionForRoute(String routeId) {
  return switch (routeId) {
    'tioga-pass' => 'Americas',
    'amalfi-coast' => 'Europe',
    'great-ocean-road' => 'Oceania',
    'garden-route' => 'Africa',
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
