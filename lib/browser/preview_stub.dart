import 'package:flutter/material.dart';
class SafePreview extends StatelessWidget {
  final String code;
  const SafePreview({super.key, required this.code});
  @override
  Widget build(BuildContext context) => const Center(child: Text('请在浏览器中查看 HTML / CSS 预览'));
}
