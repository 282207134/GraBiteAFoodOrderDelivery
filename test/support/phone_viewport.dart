import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void phoneViewport(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(375, 812);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
