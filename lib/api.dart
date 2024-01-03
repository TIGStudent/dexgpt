import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

String promt =
    'I will give you a image, you will identify the Pokémon in the picture. If there is no Pokémon in the picture but an another living thing, you will pretend it is a Pokémon and make up a name. I dont want you to mention that you are pretending.';

Future<String> apiFunc(String imgPath) async {
  var apiKey = '';
  var imagePath = imgPath;

  var base64String = await imageToBase64(imagePath);
  var response = await sendRequest(apiKey, base64String);

  print(response);
  return response;
}

Future<String> imageToBase64(String filePath) async {
  final file = File(filePath);
  final bytes = await file.readAsBytes();
  return 'data:image/jpeg;base64,' + base64Encode(bytes);
}

Future<String> sendRequest(String apiKey, String base64String) async {
  var url = Uri.parse('https://api.openai.com/v1/chat/completions');
  var headers = {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json'
  };
  print('api');
  var body = jsonEncode({
    'model': 'gpt-4-vision-preview',
    'messages': [
      {
        'role': 'user',
        'content': [
          {'type': 'text', 'text': promt},
          {
            'type': 'image_url',
            'image_url': {'url': base64String, 'detail': 'low'}
          }
        ],
      }
    ],
    'max_tokens': 300,
  });

  var response = await http.post(url, headers: headers, body: body);
  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'];
  } else {
    throw Exception('Failed to load data');
  }
}
