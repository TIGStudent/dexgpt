import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'api.dart';

class CameraWidget extends StatefulWidget {
  @override
  _CameraWidgetState createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  CameraController? controller;

  Future<void> _takePicture() async {
    if (!controller!.value.isInitialized) {
      // Display an error
      print('Error: select a camera first.');
      return;
    }

    if (controller!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return;
    }

    try {
      final image = await controller!.takePicture();
      String imagePath = image.path;
      String desText = await apiFunc(imagePath);
      _showImageDialog(image.path, desText);
    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
    }
  }

  void _showImageDialog(String imagePath, String text) {
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
        controller = CameraController(cameras.first, ResolutionPreset.low);
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
