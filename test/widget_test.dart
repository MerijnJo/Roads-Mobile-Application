import 'package:flutter_test/flutter_test.dart';

import 'package:roads_mobile_application/main.dart';

void main() {
  testWidgets('Roads opens on the map discovery experience', (tester) async {
    await tester.pumpWidget(const RoadsApp());

    expect(find.text('Roads'), findsOneWidget);
    expect(find.text('Discover scenic drives nearby'), findsOneWidget);
    expect(find.text('Veluwe Ridge Drive'), findsOneWidget);
    expect(find.text('Posbank Lookout'), findsWidgets);
  });

  testWidgets('Selecting another route preview updates the active route',
      (tester) async {
    await tester.pumpWidget(const RoadsApp());
    await tester.tap(find.text('Rhine Bend'));
    await tester.pump();

    expect(find.text('Rhine Valley Scenic Loop'), findsOneWidget);
  });
}
