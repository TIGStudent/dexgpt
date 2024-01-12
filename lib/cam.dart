import 'package:camera/camera.dart';
import 'package:dexgpt/dex_provider.dart';
import 'package:dexgpt/pokemon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'api.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'PokemonDetailsPage.dart';

class CameraWidget extends StatefulWidget {
  @override
  _CameraWidgetState createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  CameraController? controller;
  bool isLoading = false;

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

      File originalImageFile = File(imagePath);
      Uint8List imageBytes = await originalImageFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        throw Exception('Failed to decode image');
      }

      List<int> jpegBytes = img.encodeJpg(originalImage);

      String newImagePath = imagePath.replaceAll('.jpg', '_converted.jpg');
      await File(newImagePath).writeAsBytes(Uint8List.fromList(jpegBytes));

      Pokemon pokemon = await apiFunc(newImagePath, dexMode);
      return pokemon;
    } catch (e) {
      print(e);
      throw Exception('Failed to take picture: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    availableCameras().then((cameras) {
      if (cameras.isNotEmpty) {
        controller = CameraController(
          cameras.first,
          ResolutionPreset.high,
          imageFormatGroup: ImageFormatGroup.bgra8888,
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

  void _showLoadingDialog() {
    showDialog(
      barrierColor: Colors.transparent,
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/back.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        );
      },
    );
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
            borderRadius: BorderRadius.circular(20.0),
            child: CameraPreview(controller!),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: FloatingActionButton(
            onPressed: () async {
              try {
                _showLoadingDialog();

                Pokemon pokemon = await _takePicture(dexMode);

                Navigator.of(context).pop();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PokemonDetailsPage(pokemon: pokemon),
                  ),
                );
              } catch (e) {
                Navigator.of(context).pop();
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
