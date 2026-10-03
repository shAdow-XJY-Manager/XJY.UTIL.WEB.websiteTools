import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_tools/main.dart';

Future<void> withLargeText(
  WidgetTester tester,
  Future<void> Function() checks,
) async {
  tester.view.physicalSize = const Size(320, 800);
  tester.view.devicePixelRatio = 1;
  try {
    await tester.pumpWidget(Builder(builder: (context) {
      final app = const MyApp().build(context) as MaterialApp;
      return MaterialApp(
        title: app.title,
        theme: app.theme,
        darkTheme: app.darkTheme,
        themeMode: app.themeMode,
        home: app.home,
        debugShowCheckedModeBanner: false,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(2)),
          child: child!,
        ),
      );
    }));
    await tester.pump(const Duration(milliseconds: 100));
    await checks();
    expect(tester.takeException(), isNull);
  } finally {
    await tester.pumpWidget(const SizedBox.shrink());
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }
}

void expectScaledText(WidgetTester tester, String label, {Finder? finder}) {
  final text = finder ?? find.text(label);
  expect(text, findsOneWidget);
  expect(MediaQuery.textScalerOf(tester.element(text)).scale(14), 28);
  final rich = find.descendant(of: text, matching: find.byType(RichText));
  expect(rich, findsOneWidget);
  final paragraph = tester.renderObject<RenderParagraph>(rich);
  expect(paragraph.textScaler.scale(14), 28);
  expect(paragraph.didExceedMaxLines, isFalse, reason: '$label must be complete');
  expect(
    paragraph.getMaxIntrinsicHeight(paragraph.size.width),
    lessThanOrEqualTo(paragraph.size.height + 1),
    reason: '$label must not be clipped vertically',
  );
}

void expectTextInside(WidgetTester tester, Finder text, Finder available) {
  final glyphs = tester.getRect(text);
  final bounds = tester.getRect(available);
  expect(glyphs.left, greaterThanOrEqualTo(bounds.left - 1));
  expect(glyphs.right, lessThanOrEqualTo(bounds.right + 1));
  expect(glyphs.top, greaterThanOrEqualTo(bounds.top - 1));
  expect(glyphs.bottom, lessThanOrEqualTo(bounds.bottom + 1));
}

Future<void> expectSelectedDropdown(
  WidgetTester tester,
  Finder dropdown,
  String label,
) async {
  await tester.ensureVisible(dropdown);
  await tester.pump(const Duration(milliseconds: 100));
  final text = find.descendant(of: dropdown, matching: find.text(label));
  expectScaledText(tester, label, finder: text);
  final slot = find.ancestor(
    of: text,
    matching: find.byWidgetPredicate((w) => w is DropdownMenuItem<String>),
  );
  expect(slot, findsOneWidget);
  expectTextInside(tester, text, slot);
  expectTextInside(tester, slot, dropdown);
  expect(dropdown.hitTestable(), findsOneWidget);
}

Future<void> chooseDropdown(
  WidgetTester tester,
  Finder dropdown,
  List<String> labels,
  String choice,
  String value,
) async {
  await tapVisible(tester, dropdown);
  await tester.pump(const Duration(milliseconds: 250));
  for (final label in labels) {
    // The popup is appended after the selected value in the original route.
    // hitTestable below proves this is the exposed popup option.
    final text = find.text(label).last;
    final option = find.ancestor(
      of: text,
      matching: find.byWidgetPredicate((w) => w is DropdownMenuItem<String>),
    );
    expect(option, findsOneWidget);
    await tester.ensureVisible(option);
    await tester.pump(const Duration(milliseconds: 100));
    expectScaledText(tester, label, finder: text);
    expectTextInside(tester, text, option);
    // Flutter wraps the item's left-aligned content in an InkWell. The
    // DropdownMenuItem's blank center need not belong to its child's hit path.
    final control = find.ancestor(
      of: option,
      matching: find.byWidgetPredicate((w) => w is InkWell),
    );
    expect(control, findsOneWidget);
    expect(tester.widget<DropdownMenuItem<String>>(option).enabled, isTrue);
    expect(tester.widget<InkWell>(control).onTap, isNotNull);
    expect(text.hitTestable(), findsOneWidget);
    expect(control.hitTestable(), findsOneWidget);
    expectTextInside(tester, option, control);
    final rect = tester.getRect(option);
    expect(rect.left, greaterThanOrEqualTo(-1));
    expect(rect.right, lessThanOrEqualTo(321));
    expect(rect.top, greaterThanOrEqualTo(-1));
    expect(rect.bottom, lessThanOrEqualTo(801));
  }
  final chosen = find.ancestor(
    of: find.text(choice).last,
    matching: find.byWidgetPredicate((w) => w is DropdownMenuItem<String>),
  );
  final chosenControl = find.ancestor(
    of: chosen,
    matching: find.byWidgetPredicate((w) => w is InkWell),
  );
  expect(chosenControl, findsOneWidget);
  expect(tester.widget<InkWell>(chosenControl).onTap, isNotNull);
  await tapVisible(tester, chosenControl);
  await tester.pump(const Duration(milliseconds: 250));
  expect(tester.widget<DropdownButton<String>>(dropdown).value, value);
  await expectSelectedDropdown(tester, dropdown, choice);
}

Finder button(String label) => find.ancestor(
  of: find.text(label),
  matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
);

Future<void> tapVisible(WidgetTester tester, Finder control) async {
  await tester.ensureVisible(control);
  await tester.pump(const Duration(milliseconds: 100));
  expect(control.hitTestable(), findsOneWidget);
  final rect = tester.getRect(control);
  expect(rect.left, greaterThanOrEqualTo(-1));
  expect(rect.right, lessThanOrEqualTo(321));
  expect(rect.top, greaterThanOrEqualTo(-1));
  expect(rect.bottom, lessThanOrEqualTo(801));
  expect(MediaQuery.textScalerOf(tester.element(control)).scale(14), 28);
  await tester.tap(control.hitTestable());
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  testWidgets('320px at real 200% text keeps conversion controls reachable',
      (tester) async {
    await withLargeText(tester, () async {
      expectScaledText(tester, '选择图片');
      final pick = button('选择图片');
      await tester.ensureVisible(pick);
      await tester.pump();
      expect(pick.hitTestable(), findsOneWidget);
      expect(tester.widget<OutlinedButton>(pick).onPressed, isNotNull);

      final format = find.byWidgetPredicate((w) => w is DropdownButton<String>);
      await expectSelectedDropdown(tester, format, 'PNG');
      await chooseDropdown(tester, format, ['PNG', 'JPEG', 'WEBP', 'ICO'],
          'WEBP', 'webp');

      expectScaledText(tester, '编码解码');
      await tapVisible(tester, find.widgetWithText(ChoiceChip, '编码解码'));
      final encoding = find.byWidgetPredicate((w) => w is DropdownButton<String>);
      await expectSelectedDropdown(tester, encoding, 'Base64');
      await chooseDropdown(tester, encoding, ['Base64', 'URL component'],
          'URL component', 'URL component');
      await chooseDropdown(tester, encoding, ['Base64', 'URL component'],
          'Base64', 'Base64');
      expectScaledText(tester, '转换文本');
      final input = find.byWidgetPredicate((w) =>
          w is TextField && w.decoration?.labelText == '输入文本');
      await tester.ensureVisible(input);
      await tester.enterText(input, 'hello');
      await tester.pump();
      await tapVisible(tester, button('转换文本'));
      final result = tester.widget<TextField>(find.byWidgetPredicate((w) =>
          w is TextField && w.decoration?.labelText == '转换结果'));
      expect(result.controller!.text, 'aGVsbG8=');
      expectScaledText(tester, '交换并切换方向');
      await tapVisible(tester,
          button('交换并切换方向'));
      await tapVisible(tester, button('转换文本'));
      expect(result.controller!.text, 'hello');
    });
  });
}
