import 'package:flutter/material.dart';
import 'cam.dart';
import 'api.dart';

class DexHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('DexGPT'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/back.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Center(
                  child: SizedBox(
                    width: screenwidth,
                    height: screenwidth,
                    child: CameraWidget(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
