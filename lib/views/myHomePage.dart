// ignore_for_file: prefer_interpolation_to_compose_strings, avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool textScaning = false;
  XFile? imagefile;
  String scanText = "";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (imagefile != null)
                  Image.file(
                    width: MediaQuery.of(context).size.width - 50,
                    File(imagefile!.path),
                  ),
                if (textScaning) const CircularProgressIndicator(),
              ],
            ),
            /*Row(
              children: [
                Container(
                  color: Colors.grey,
                  width: 400,
                  height: 400,
                  child: CustomPaint(
                    painter: OpenPainter(),
                  ),
                ),
              ],
            ),*/
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    getImage(ImageSource.gallery);
                  },
                  child: const Text("galary"),
                ),
                TextButton(
                  onPressed: () {
                    getImage(ImageSource.camera);
                  },
                  child: const Text("Camera"),
                ),
              ],
            ),
            Expanded(
              child: Row(
                children: [
                  SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        scanText,
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void getRecognisedText(XFile image) async {
    scanText = "";
    bool exsist = false;
    final inputImage = InputImage.fromFilePath(image.path);
    final textDetector = GoogleMlKit.vision.textRecognizer();

    RecognizedText recognizedText = await textDetector.processImage(inputImage);
    await textDetector.close();
    const removetxt = "RO:,ROMÂNIA CARTE DE IDENTITATE,IDENTITY CARD,ROMANIA";

    var rmwords = removetxt.split(',');
    for (TextBlock block in recognizedText.blocks) {
      //print("bound " + block.boundingBox.topLeft.toString());
      //scanText = scanText + block.text + "\n";
      //scanText = scanText + "------\n";

      for (TextLine line in block.lines) {
        for (var rmword in rmwords) {
          if (rmword.trim() == line.text.trim()) {
            exsist = true;
          }
        }
        if (exsist == false) {
          print("print call");
          setText(line.text.trim());
        }
        exsist = false;
      }
    }

    setState(() {
      //scanText = scanText;
      textScaning = false;
    });
  }

  void setText(txt) {
    print("print " + txt.toString());
    scanText = scanText + txt + "\n";
    //scanText = scanText + "------\n";
  }

  void drawRect(Rect rect, Paint paint) {}

  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        imagefile = pickedImage;
        setState(() {
          textScaning = true;
        });
        getRecognisedText(pickedImage);
      }
    } catch (e) {
      textScaning = false;
      imagefile = null;
      setState(() {
        textScaning = false;
        scanText = "error Will cocceed ";
      });
    }
  }
}
