import 'package:dexgpt/dex_provider.dart';
import 'package:flutter/material.dart';
import 'cam.dart';
import 'api.dart';
import 'camera_visibility_provider.dart';
import 'package:provider/provider.dart';

class DexHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool mode = context.read<DexProvider>().normalMode;
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
            Container(
              width: screenwidth,
              height: 400,
              child: Consumer<CameraVisibilityProvider>(
                builder: (context, provider, child) {
                  return provider.isCameraVisible
                      ? CameraWidget()
                      : Container();
                },
              ),
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
                onPressed: () => context.read<DexProvider>().toggleMode(),
                child: Text(context.watch<DexProvider>().normalMode
                    ? 'Mode: normal'
                    : 'Mode: Expanded'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
