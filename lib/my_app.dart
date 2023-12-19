import 'package:flutter/material.dart';
import 'dex_home_page.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DexGPT',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DexHomePage(),
    );
  }
}
