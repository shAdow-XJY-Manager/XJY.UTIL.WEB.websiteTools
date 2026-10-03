import 'dart:js_interop';
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
@JS('frequencyCreatePreview') external JSObject _create(JSString id);
@JS('frequencyUpdatePreview') external void _update(JSObject frame, JSString code);
class SafePreview extends StatefulWidget {
  final String code;
  const SafePreview({super.key, required this.code});
  @override
  State<SafePreview> createState() => _SafePreviewState();
}
class _SafePreviewState extends State<SafePreview> {
  static int _next = 0;
  late final String _id;
  late final JSObject _frame;
  @override
  void initState() {
    super.initState();
    _id = 'frequency-preview-${_next++}';
    _frame = _create(_id.toJS);
    ui_web.platformViewRegistry.registerViewFactory(_id, (int viewId) => _frame);
    _update(_frame, widget.code.toJS);
  }
  @override
  void didUpdateWidget(covariant SafePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.code != oldWidget.code) _update(_frame, widget.code.toJS);
  }
  @override
  Widget build(BuildContext context) => HtmlElementView(viewType: _id);
}
