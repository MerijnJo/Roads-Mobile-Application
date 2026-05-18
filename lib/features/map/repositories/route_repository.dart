import '../models/scenic_route.dart';

abstract interface class RouteRepository {
  Future<List<ScenicRoute>> fetchFeaturedRoutes();
}
