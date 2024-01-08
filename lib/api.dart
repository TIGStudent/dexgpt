import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'dex_provider.dart';
import 'pokemon.dart';

Future<Pokemon> apiFunc(String imgPath, bool dexMode) async {
  var apiKey = '';
  var imagePath = imgPath;

  var base64String = await imageToBase64(imagePath);
  var response = await sendRequest(apiKey, base64String, dexMode, imagePath);

  print(response);
  return response;
}

Future<String> imageToBase64(String filePath) async {
  final file = File(filePath);
  final bytes = await file.readAsBytes();
  return 'data:image/jpeg;base64,' + base64Encode(bytes);
}

Future<Pokemon> sendRequest(
    String apiKey, String base64String, bool dexMode, String imagePath) async {
  bool mode = dexMode;
  String basePromt =
      'I will give you a image, you will identify the Pokémon in the picture.';
  String modePromt = mode
      ? 'If there is no Pokémon in the picture or if you cant identify it i want you to ask for a new picture in the description part of the below json structure, and error as the value for the rest of the structure.'
      : 'If there is no Pokémon in the picture but an another living thing, you will pretend it is a Pokémon and make up a name. Dont mention that you are pretending.';
  String outputPromt =
      'I want the answer to follow the below json structure:{"pokemon": {"name": "NameOfPokemon","description": "Description of the Pokémon","type": "TypeOfPokemon"}}';
  String promt = basePromt + modePromt + outputPromt;

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
    print('200');
    print(response.body);

    var decodedResponse = jsonDecode(response.body);
    var choices = decodedResponse['choices'];
    if (choices.isNotEmpty) {
      var firstChoice = choices[0];
      var messageContent = firstChoice['message']['content'];
      print(messageContent);

      // Remove Markdown code block syntax
      String jsonPart = messageContent
          .replaceAll('```json\n', '')
          .replaceAll('\n```', '')
          .trim();

      // Decode the JSON string
      var pokemonData = jsonDecode(jsonPart);

      Pokemon pokemon = Pokemon.fromJson(pokemonData);
      pokemon.setImagePath = imagePath;
      return pokemon;
    } else {
      throw Exception('No choices available in the response');
    }
  } else {
    throw Exception('Failed to load data');
  }
}
