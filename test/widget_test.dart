import 'package:flutter_test/flutter_test.dart';

import 'package:roads_mobile_application/features/map/repositories/local_route_repository.dart';
import 'package:roads_mobile_application/main.dart';

void main() {
  const routeRepository = LocalRouteRepository();

  testWidgets('Roads opens on the map discovery experience', (tester) async {
    await tester.pumpWidget(
      const RoadsApp(routeRepository: routeRepository),
    );
    await tester.pumpAndSettle();

    expect(find.text('Roads'), findsOneWidget);
    expect(find.text('Discover scenic drives nearby'), findsOneWidget);
    expect(find.text('Tioga Pass Road'), findsOneWidget);
    expect(find.text('Crane Flat'), findsWidgets);
  });

  testWidgets('Selecting another route stop updates the active stop',
      (tester) async {
    await tester.pumpWidget(
      const RoadsApp(routeRepository: routeRepository),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tenaya Lake'));
    await tester.pumpAndSettle();

    expect(find.text('Clear alpine water framed by granite slopes.'),
        findsOneWidget);
  });
}
