import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mitra/main.dart';

void main() {
  testWidgets('Mitra Chatbot loads with basic UI', (WidgetTester tester) async {
    await tester.pumpWidget(const MitraApp());

    // Check if the app bar title is present
    expect(find.text('🤖 Mitra Chatbot'), findsOneWidget);

    // Check if there's a text input field
    expect(find.byType(TextField), findsOneWidget);

    // Check if there's a send icon button
    expect(find.byIcon(Icons.send), findsOneWidget);
  });
}