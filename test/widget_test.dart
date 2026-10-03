import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_tools/main.dart';

void main() {
  testWidgets('tools start with image conversion disabled and switch workbenches', (tester) async {
    tester.view.physicalSize = const Size(1200, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('频率工具台'), findsOneWidget);
    expect(find.byType(ChoiceChip), findsNWidgets(5));
    final generate = find.ancestor(of: find.text('生成图片'), matching: find.byWidgetPredicate((w) => w is FilledButton));
    expect(tester.widget<FilledButton>(generate).onPressed, isNull);
    await tester.tap(find.byWidgetPredicate((w) => w is ChoiceChip && (w.label as Padding).child is Text && ((w.label as Padding).child as Text).data == '编码解码'));
    await tester.pump();
    expect(find.text('编码 / 解码'), findsOneWidget);
    expect(find.text('转换文本'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
