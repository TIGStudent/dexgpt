import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dex_provider.dart';
import './camera_visibility_provider.dart';
import 'my_app.dart';
// Import other providers if you have any

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DexProvider()),
        ChangeNotifierProvider(create: (context) => CameraVisibilityProvider()),
      ],
      child: MyApp(),
    ),
  );
}
