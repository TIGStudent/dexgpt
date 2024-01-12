import 'package:flutter_tts/flutter_tts.dart';

FlutterTts flutterTts = FlutterTts();

Future speak(String text) async {
  await flutterTts.setSharedInstance(true);
  await flutterTts.setLanguage('en-US');
  await flutterTts.speak(text);
}
