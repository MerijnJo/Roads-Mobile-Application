import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/home/screens/explore_screen.dart';
import 'features/map/repositories/local_route_repository.dart';
import 'features/map/repositories/route_repository.dart';
import 'features/map/repositories/supabase_route_repository.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabasePublishableKey = String.fromEnvironment(
  'SUPABASE_PUBLISHABLE_KEY',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final routeRepository = await _createRouteRepository();

  runApp(RoadsApp(routeRepository: routeRepository));
}

class RoadsApp extends StatelessWidget {
  const RoadsApp({
    required this.routeRepository,
    super.key,
  });

  final RouteRepository routeRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roads',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007A63),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FD),
        useMaterial3: true,
      ),
      home: ExploreScreen(routeRepository: routeRepository),
    );
  }
}

Future<RouteRepository> _createRouteRepository() async {
  if (_supabaseUrl.isEmpty || _supabasePublishableKey.isEmpty) {
    return const LocalRouteRepository();
  }

  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabasePublishableKey,
  );

  return SupabaseRouteRepository(Supabase.instance.client);
}
