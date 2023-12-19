import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dex_provider.dart';
import 'my_app.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => DexProvider(),
      child: MyApp(),
    ),
  );
}
