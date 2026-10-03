import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_tools/tool_logic.dart';

void main() {
  test('text conversions preserve UTF-8 and reject malformed input', () {
    const original = '你好🙂';
    expect(transformText(original, 'Base64', false), '5L2g5aW98J+Zgg==');
    expect(transformText('5L2g5aW98J+Zgg==', 'Base64', true), original);
    expect(
      transformText(original, 'URL component', false),
      '%E4%BD%A0%E5%A5%BD%F0%9F%99%82',
    );
    expect(
      transformText('%E4%BD%A0%E5%A5%BD%F0%9F%99%82', 'URL component', true),
      original,
    );
    expect(() => transformText('%%%', 'Base64', true), throwsFormatException);
    expect(() => transformText('/w==', 'Base64', true), throwsFormatException);
    expect(
      () => transformText('%Z1', 'URL component', true),
      throwsArgumentError,
    );
  });
  test('HEX colors distinguish RGB and RGBA and reject invalid values', () {
    expect(parseHexColor('#F4B45F'), [244, 180, 95, 255]);
    expect(parseHexColor('#11223344'), [17, 34, 51, 68]);
    expect(colorHex([17, 34, 51, 68]), '#11223344');
    expect(() => parseHexColor('#XYZ123'), throwsFormatException);
    expect(() => parseHexColor('#123'), throwsFormatException);
    expect(() => parseHexColor('D6#EF36'), throwsFormatException);
    expect(() => parseHexColor('##D6EF36'), throwsFormatException);
  });
}
