import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:h3_flutter/h3_flutter.dart';

void main() {
  const MethodChannel channel = MethodChannel('h3_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await H3Flutter.platformVersion, '42');
  });
}
