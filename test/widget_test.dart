import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:streaming_app/main.dart';

void main() {
  testWidgets('renders starter app', (tester) async {
    await tester.pumpWidget(const StreamingApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Start building here'), findsOneWidget);
  });
}
