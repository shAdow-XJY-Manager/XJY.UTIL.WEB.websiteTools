import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_tools/frequency_tools.dart';

void main() {
  testWidgets(
    'RGBA keeps alpha in displayed and copied CSS; malformed HEX preserves color',
    (tester) async {
      final copied = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData')
            copied.add((call.arguments as Map)['text'] as String);
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: ColorWorkbench())),
        ),
      );
      await tester.enterText(find.byType(TextField), '#FFFFFF80');
      await tester.tap(find.text('应用颜色'));
      await tester.pump();
      const rgb = 'rgba(255, 255, 255, 0.50196)';
      const hsl = 'hsla(0.0, 0.00%, 100.00%, 0.50196)';
      expect(find.text('$rgb\n$hsl\n透明度 50%'), findsOneWidget);
      for (final label in ['复制 RGB', '复制 HSL']) {
        await tester.ensureVisible(find.text(label));
        await tester.tap(find.text(label));
        await tester.pump();
      }
      expect(copied, [rgb, hsl]);
      await tester.ensureVisible(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'D6#EF36');
      await tester.tap(find.text('应用颜色'));
      await tester.pump();
      expect(find.text('#FFFFFF80'), findsOneWidget);
      expect(find.text('请输入 6 位 HEX，或含透明度的 8 位 HEX。'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
