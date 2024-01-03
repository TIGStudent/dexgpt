import 'package:flutter/material.dart';
import 'cam.dart';
import 'api.dart';
import 'camera_visibility_provider.dart';
import 'package:provider/provider.dart';

class DexHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    var cameraProvider =
        Provider.of<CameraVisibilityProvider>(context, listen: false);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/back.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Consumer<CameraVisibilityProvider>(
              builder: (context, provider, child) {
                return provider.isCameraVisible
                    ? CameraWidget()
                    : Container();
              },
            ),
            Container(
              width: 160,
              child: ElevatedButton(
                onPressed: () => cameraProvider.toggleCameraVisibility(),
                child: Text(
                    context.watch<CameraVisibilityProvider>().isCameraVisible
                        ? 'Hide Camera'
                        : 'Show Camera'),
              ),
            ),
            Container(
              width: 160,
              child: ElevatedButton(
                onPressed: () => cameraProvider.toggleCameraVisibility(),
                child: Text(
                    context.watch<CameraVisibilityProvider>().isCameraVisible
                        ? 'Mode: Expanded'
                        : 'Mode: Normal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
