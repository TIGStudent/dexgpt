import 'package:camera/camera.dart';
import 'package:dexgpt/dex_provider.dart';
import 'package:dexgpt/pokemon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'api.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data'; // Import this for Uint8List
import 'tts.dart';

class CameraWidget extends StatefulWidget {
  @override
  _CameraWidgetState createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  CameraController? controller;

  Future<Pokemon> _takePicture(bool dexMode) async {
    if (!controller!.value.isInitialized) {
      print('Error: select a camera first.');
      throw Exception('Camera not initialized');
    }

    if (controller!.value.isTakingPicture) {
      throw Exception('A picture is already being taken');
    }

    try {
      final image = await controller!.takePicture();
      String imagePath = image.path;

      // Read the image file
      File originalImageFile = File(imagePath);
      Uint8List imageBytes = await originalImageFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        throw Exception('Failed to decode image');
      }

      // Convert to JPEG (or PNG)
      List<int> jpegBytes = img.encodeJpg(originalImage);

      // Save the JPEG image
      String newImagePath = imagePath.replaceAll('.jpg', '_converted.jpg');
      await File(newImagePath).writeAsBytes(Uint8List.fromList(jpegBytes));

      Pokemon pokemon = await apiFunc(newImagePath, dexMode);
      return pokemon;
    } catch (e) {
      print(e);
      throw Exception('Failed to take picture: $e');
    }
  }

  void _showImageDialog(Pokemon pokemon) {
    speak(pokemon.description);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding:
              EdgeInsets.all(0), // Remove padding to expand to full screen
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisSize:
                  MainAxisSize.max, // Makes column expand to fit the container
              children: [
                Expanded(
                  child: Image.file(File(pokemon.imagePath),
                      fit: BoxFit
                          .cover), // Adjusts image to cover available space
                ),
                Text(pokemon.description),
                TextButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    availableCameras().then((cameras) {
      if (cameras.isNotEmpty) {
        controller = CameraController(
          cameras.first,
          ResolutionPreset.high,
          imageFormatGroup:
              ImageFormatGroup.bgra8888, // Specify the image format group here
        );
        controller!.initialize().then((_) {
          if (!mounted) {
            return;
          }
          setState(() {});
        });
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool dexMode = context.watch<DexProvider>().normalMode;
    if (controller == null || !controller!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        AspectRatio(
          aspectRatio: 4.0 / 3.0,
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(20.0), // Set your desired radius
            child: CameraPreview(controller!),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: FloatingActionButton(
            onPressed: () async {
              try {
                Pokemon pokemon = await _takePicture(dexMode);
                // Handle the Pokemon object as needed, e.g., display in dialog
                //_showImageDialog(
                //    pokemon); // Make sure you have the image path available here

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PokemonDetailsPage(pokemon: pokemon),
                  ),
                );
              } catch (e) {
                // Handle any errors here
                print('Error taking picture: $e');
              }
            },
            child: Icon(Icons.camera),
          ),
        ),
      ],
    );
  }
}

class PokemonDetailsPage extends StatelessWidget {
  final Pokemon pokemon;

  PokemonDetailsPage({Key? key, required this.pokemon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    speak(pokemon.name + pokemon.description);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        title: Text(
          'Pokemon Details',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/back.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 300.0, // Set your desired width
                height: 200.0, // Set your desired height
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(20.0), // Set your desired radius
                  child: Image.file(
                    File(pokemon.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                    color: Color.fromARGB(150, 255, 255, 255),
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(pokemon.name,
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Type: '),
                          Text(
                            pokemon.type,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(''),
                      Text(pokemon.description),
                      Text(''),
                    ],
                  ),
                ),
              ),
              // Add more details as needed
            ],
          ),
        ),
      ),
    );
  }
}
