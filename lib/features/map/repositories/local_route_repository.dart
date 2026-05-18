import 'package:latlong2/latlong.dart';

import '../models/route_stop.dart';
import '../models/scenic_route.dart';
import 'route_repository.dart';

class LocalRouteRepository implements RouteRepository {
  const LocalRouteRepository();

  @override
  Future<List<ScenicRoute>> fetchFeaturedRoutes() async {
    return const [
      ScenicRoute(
        id: 'tioga-pass',
        name: 'Tioga Pass Road',
        description:
            'A high Sierra drive across Yosemite, linking granite domes, meadows, lakes, and the eastern escarpment near Lee Vining.',
        distanceLabel: '68 mi',
        durationLabel: '2-3 hr',
        center: LatLng(37.8554, -119.4926),
        path: [
          LatLng(37.808873, -119.872007),
          LatLng(37.788871, -119.876539),
          LatLng(37.776026, -119.861371),
          LatLng(37.766754, -119.859451),
          LatLng(37.762304, -119.834116),
          LatLng(37.75201, -119.824642),
          LatLng(37.755981, -119.817391),
          LatLng(37.747342, -119.80349),
          LatLng(37.752483, -119.797557),
          LatLng(37.758188, -119.80486),
          LatLng(37.760689, -119.802353),
          LatLng(37.756866, -119.791591),
          LatLng(37.759428, -119.779188),
          LatLng(37.755414, -119.772158),
          LatLng(37.769072, -119.770966),
          LatLng(37.775295, -119.752391),
          LatLng(37.788849, -119.735325),
          LatLng(37.789682, -119.724364),
          LatLng(37.811122, -119.713226),
          LatLng(37.819605, -119.714091),
          LatLng(37.821587, -119.704908),
          LatLng(37.831222, -119.701719),
          LatLng(37.849911, -119.671426),
          LatLng(37.850127, -119.653716),
          LatLng(37.85764, -119.64346),
          LatLng(37.849833, -119.625977),
          LatLng(37.84873, -119.597175),
          LatLng(37.839037, -119.59221),
          LatLng(37.851922, -119.57468),
          LatLng(37.848289, -119.571751),
          LatLng(37.828113, -119.581353),
          LatLng(37.815459, -119.580558),
          LatLng(37.808365, -119.568936),
          LatLng(37.806785, -119.544601),
          LatLng(37.81796, -119.516124),
          LatLng(37.816703, -119.508083),
          LatLng(37.811146, -119.50843),
          LatLng(37.81717, -119.497524),
          LatLng(37.810956, -119.484735),
          LatLng(37.823749, -119.477029),
          LatLng(37.840304, -119.449844),
          LatLng(37.873547, -119.425161),
          LatLng(37.876577, -119.406742),
          LatLng(37.881493, -119.400699),
          LatLng(37.873745, -119.386834),
          LatLng(37.87194, -119.36919),
          LatLng(37.882131, -119.324009),
          LatLng(37.879333, -119.276647),
          LatLng(37.893334, -119.260041),
          LatLng(37.925991, -119.256228),
          LatLng(37.937759, -119.249297),
          LatLng(37.940243, -119.240474),
          LatLng(37.935899, -119.231663),
          LatLng(37.952533, -119.225535),
          LatLng(37.947828, -119.189323),
          LatLng(37.932612, -119.176691),
          LatLng(37.930409, -119.168711),
          LatLng(37.940229, -119.134136),
          LatLng(37.940226, -119.120144),
          LatLng(37.950419, -119.113095),
          LatLng(37.9575, -119.120209),
        ],
        stops: [
          RouteStop(
            id: 'crane-flat',
            name: 'Crane Flat',
            description: 'Western gateway toward Tioga Road and high country.',
            position: LatLng(37.808873, -119.872007),
          ),
          RouteStop(
            id: 'tenaya-lake',
            name: 'Tenaya Lake',
            description: 'Clear alpine water framed by granite slopes.',
            position: LatLng(37.839037, -119.59221),
          ),
          RouteStop(
            id: 'tuolumne-meadows',
            name: 'Tuolumne Meadows',
            description: 'Broad subalpine meadows in Yosemite high country.',
            position: LatLng(37.873745, -119.386834),
          ),
          RouteStop(
            id: 'tioga-pass',
            name: 'Tioga Pass',
            description: 'The eastern pass and Yosemite entrance area.',
            position: LatLng(37.944485, -119.2082),
          ),
          RouteStop(
            id: 'lee-vining',
            name: 'Lee Vining',
            description: 'Eastern endpoint near Mono Lake and US 395.',
            position: LatLng(37.9575, -119.120209),
          ),
        ],
      ),
    ];
  }
}
