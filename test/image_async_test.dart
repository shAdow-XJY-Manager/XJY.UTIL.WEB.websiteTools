import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_tools/frequency_tools.dart';
import 'package:shadow_tools/theme/frequency_theme.dart';

const imageData =
    'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg==';
Finder field(String label) => find.byWidgetPredicate(
  (w) => w is TextField && w.decoration?.labelText == label,
);
Finder control<T extends Widget>(String label) => find.ancestor(
  of: find.text(label).last,
  matching: find.byWidgetPredicate((w) => w is T),
);

Future<void> startJpeg(
  WidgetTester tester,
  Completer<String> completion,
) async {
  tester.view.physicalSize = const Size(1280, 1100);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: FrequencyTheme.dark(),
      home: Scaffold(
        body: SingleChildScrollView(
          child: ImageWorkbench(
            resize: true,
            pickImage: () async => jsonEncode({
              'name': 'source.png',
              'data': imageData,
              'width': 1,
              'height': 1,
            }),
            convertImage: (_) => completion.future,
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('选择图片'));
  await tester.pumpAndSettle();
  final format = tester.widget<DropdownButtonFormField<String>>(
    find.byType(DropdownButtonFormField<String>),
  );
  format.onChanged!('jpeg');
  await tester.pumpAndSettle();
  final generate = control<FilledButton>('生成图片');
  await tester.ensureVisible(generate);
  await tester.tap(generate);
  await tester.pump();
}

void main() {
  testWidgets('JPEG conversion locks every parameter until completion', (
    tester,
  ) async {
    final completion = Completer<String>();
    await startJpeg(tester, completion);
    for (final label in ['宽度 / px', '高度 / px', '透明区域底色 / HEX']) {
      expect(tester.widget<TextField>(field(label)).enabled, isFalse);
    }
    expect(
      tester
          .widget<DropdownButtonFormField<String>>(
            find.byType(DropdownButtonFormField<String>),
          )
          .onChanged,
      isNull,
    );
    expect(
      tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).onChanged,
      isNull,
    );
    expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNull);
    expect(
      tester.widget<OutlinedButton>(control<OutlinedButton>('更换图片')).onPressed,
      isNull,
    );
    completion.complete(jsonEncode({'error': '测试编码失败'}));
    await tester.pumpAndSettle();
    expect(find.text('测试编码失败'), findsOneWidget);
    expect(tester.widget<TextField>(field('透明区域底色 / HEX')).enabled, isTrue);
    expect(tester.takeException(), isNull);
  });

  for (final failed in [false, true]) {
    testWidgets(
      'changed parameters reject stale ${failed ? 'error' : 'result'}',
      (tester) async {
        final completion = Completer<String>();
        await startJpeg(tester, completion);
        // A controller update can arrive outside a disabled UI (e.g. restored state).
        tester.widget<TextField>(field('透明区域底色 / HEX')).controller!.text =
            '#000000';
        completion.complete(
          jsonEncode(
            failed
                ? {'error': '旧请求错误'}
                : {
                    'data': imageData,
                    'preview': imageData,
                    'format': 'jpeg',
                    'width': 1,
                    'height': 1,
                    'bytes': 100,
                  },
          ),
        );
        await tester.pumpAndSettle();
        expect(find.textContaining('转换完成'), findsNothing);
        expect(find.text('旧请求错误'), findsNothing);
        expect(
          tester
              .widget<OutlinedButton>(control<OutlinedButton>('下载图片'))
              .onPressed,
          isNull,
        );
        expect(
          tester.widget<TextField>(field('透明区域底色 / HEX')).controller!.text,
          '#000000',
        );
        expect(tester.widget<TextField>(field('透明区域底色 / HEX')).enabled, isTrue);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
