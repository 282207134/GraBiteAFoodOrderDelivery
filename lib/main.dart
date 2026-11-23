import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(graBiteOverlay);
  final preferences = await SharedPreferences.getInstance();
  runApp(GraBiteApp(state: GraBiteState(preferences)));
}
