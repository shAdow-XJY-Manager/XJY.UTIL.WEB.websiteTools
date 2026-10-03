import 'dart:convert';

String transformText(String value, String kind, bool decode) {
  if (kind == 'Base64') {
    return decode ? utf8.decode(base64.decode(value.trim())) : base64.encode(utf8.encode(value));
  }
  return decode ? Uri.decodeComponent(value) : Uri.encodeComponent(value);
}

List<int> parseHexColor(String value) {
  final clean = value.trim().replaceFirst(RegExp(r'^#'), '');
  if (!RegExp(r'^[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$').hasMatch(clean)) {
    throw const FormatException('请输入 6 位 HEX，或含透明度的 8 位 HEX。');
  }
  return [for (var i = 0; i < clean.length; i += 2) int.parse(clean.substring(i, i + 2), radix: 16), if (clean.length == 6) 255];
}

String colorHex(List<int> values) => '#${values.map((v) => v.toRadixString(16).padLeft(2, '0')).join().toUpperCase()}';
