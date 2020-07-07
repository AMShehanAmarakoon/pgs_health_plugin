import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pgs_health_plugin/pgs_health_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('pgs_health_plugin');

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
    expect(await PgsHealthPlugin.platformVersion, '42');
  });
}
