import 'dart:js_interop';
@JS('frequencyPickImage') external JSPromise<JSString> _pickImage();
@JS('frequencyConvertImage') external JSPromise<JSString> _convertImage(JSString request);
@JS('frequencyDownloadImage') external void _downloadImage(JSString request);
Future<String> pickImage() async => (await _pickImage().toDart).toDart;
Future<String> convertImage(String request) async => (await _convertImage(request.toJS).toDart).toDart;
void downloadImage(String request) => _downloadImage(request.toJS);
