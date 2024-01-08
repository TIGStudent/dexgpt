import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
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

  Future<void> _takePicture() async {
    if (!controller!.value.isInitialized) {
      print('Error: select a camera first.');
      return;
    }

    if (controller!.value.isTakingPicture) {
      return;
    }

    try {
      final image = await controller!.takePicture();
      String imagePath = image.path;

      // Read the image file
      File originalImageFile = File(imagePath);
      Uint8List imageBytes = await originalImageFile.readAsBytes(); // imageBytes is now Uint8List
      img.Image? originalImage = img.decodeImage(imageBytes);

      // Convert to JPEG (or PNG)
      List<int> jpegBytes = img.encodeJpg(originalImage!); // Use encodePng for PNG format

      // Save the JPEG image
      String newImagePath = imagePath.replaceAll('.jpg', '_converted.jpg'); // Change file extension as needed
      await File(newImagePath).writeAsBytes(Uint8List.fromList(jpegBytes)); // Convert jpegBytes back to Uint8List

      String desText = await apiFunc(newImagePath);
      _showImageDialog(newImagePath, desText);
    } catch (e) {
      print(e);
    }
  }


  void _showImageDialog(String imagePath, String text) {
    speak(text);

    showDialog(
      context: context,
      barrierDismissible:
          false, // Optional: makes it so you must tap a button to dismiss
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
                  child: Image.file(File(imagePath),
                      fit: BoxFit
                          .cover), // Adjusts image to cover available space
                ),
                Text(text),
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
          imageFormatGroup: ImageFormatGroup.bgra8888, // Specify the image format group here
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
    if (controller == null || !controller!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        AspectRatio(
          aspectRatio: controller!.value.aspectRatio,
          child: CameraPreview(controller!),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: FloatingActionButton(
            onPressed: _takePicture,
            child: Icon(Icons.camera),
          ),
        ),
      ],
    );
  }
}
