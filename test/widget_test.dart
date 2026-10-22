import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_tools/main.dart';

Finder textInput(String label) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.labelText == label,
);

Future<void> selectTool(WidgetTester tester, String label) async {
  final control = find.text(label);
  await tester.ensureVisible(control);
  await tester.tap(control);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('tools start with conversion disabled and switch workbenches', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('频率工具台'), findsOneWidget);
    expect(find.widgetWithText(ListTile, '编码解码'), findsOneWidget);
    expect(find.byType(ChoiceChip), findsNothing);
    final generate = find.ancestor(
      of: find.text('生成图片').last,
      matching: find.byWidgetPredicate((w) => w is FilledButton),
    );
    expect(tester.widget<FilledButton>(generate).onPressed, isNull);
    await selectTool(tester, '编码解码');
    expect(find.text('编码 / 解码'), findsOneWidget);
    expect(find.text('转换文本'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'desktop image task reaches generate without scrolling at 720px',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      final controls = [
        find.ancestor(
          of: find.text('选择图片'),
          matching: find.byWidgetPredicate(
            (widget) => widget is OutlinedButton,
          ),
        ),
        textInput('宽度 / px'),
        textInput('高度 / px'),
        find.byType(DropdownButtonFormField<String>),
        find.byType(CheckboxListTile),
        find.ancestor(
          of: find.text('生成图片').last,
          matching: find.byWidgetPredicate((widget) => widget is FilledButton),
        ),
      ];
      for (final control in controls) {
        expect(control, findsOneWidget);
        final bounds = tester.getRect(control);
        expect(bounds.top, greaterThanOrEqualTo(0));
        expect(bounds.bottom, lessThanOrEqualTo(720));
      }
      final divider = tester.element(find.byType(Divider).first);
      expect(DividerTheme.of(divider).color, const Color(0xFF343C3F));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'input and output survive tool changes and responsive reparenting',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      await selectTool(tester, '编码解码');
      await tester.enterText(textInput('输入文本'), 'hello');
      await tester.ensureVisible(find.text('转换文本'));
      await tester.tap(find.text('转换文本'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(textInput('转换结果')).controller!.text,
        'aGVsbG8=',
      );

      await selectTool(tester, '颜色工作台');
      await selectTool(tester, '编码解码');
      expect(
        tester.widget<TextField>(textInput('输入文本')).controller!.text,
        'hello',
      );

      tester.view.physicalSize = const Size(390, 844);
      await tester.pumpAndSettle();
      expect(find.byType(ChoiceChip), findsNWidgets(5));
      expect(
        tester.widget<TextField>(textInput('输入文本')).controller!.text,
        'hello',
      );
      expect(
        tester.widget<TextField>(textInput('转换结果')).controller!.text,
        'aGVsbG8=',
      );

      tester.view.physicalSize = const Size(1200, 1100);
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(textInput('输入文本')).controller!.text,
        'hello',
      );
      expect(
        tester.widget<TextField>(textInput('转换结果')).controller!.text,
        'aGVsbG8=',
      );
      expect(tester.takeException(), isNull);
    },
  );
}
