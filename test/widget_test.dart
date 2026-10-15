import 'package:dyve_toy_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('앱이 뜨고 하단 탭 4개가 보인다', (tester) async {
    await tester.pumpWidget(const DyveApp());

    final nav = find.byType(NavigationBar);
    expect(nav, findsOneWidget);
    for (final label in ['홈', '티켓', '베뉴', '마이']) {
      expect(find.descendant(of: nav, matching: find.text(label)), findsOneWidget);
    }
  });
}
