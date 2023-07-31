import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'api_service.dart';
import 'custom_button.dart';
import 'pick_image.dart';

class CompareImage extends StatefulWidget {
  const CompareImage({super.key});

  @override
  State<CompareImage> createState() => _CompareImageState();
}

class _CompareImageState extends State<CompareImage> {
  bool isComparingImage = false;
  String? imagePathForCompare;
  Map? imageTransferResult;

  Future compareImage() async {
    await pickImage().then((imagePath) {
      if (imagePath != null) {
        imagePathForCompare = imagePath;
        uploadPickedImage();
      }
    });
  }

  void clearSelectedImage() {
    setState(() => imagePathForCompare = null);
  }

  Future uploadPickedImage() async {
    setState(() => isComparingImage = true);
    await ApiService.postMultiPartQuery(
      imageCompareUrl,
      fields: {'user_id': '1'},
      files: {'image': '$imagePathForCompare'},
    ).then((res) {
      setState(() => isComparingImage = false);
      imageTransferResult = {'response': '$res'};
      if (res == null) return null;
      showToast('${jsonDecode(res)['response']}');
      setState(() {
        imageTransferResult = jsonDecode(res);
      });
    }).onError((error, stackTrace) {
      setState(() {
        imageTransferResult = {'response': '$error'};
        isComparingImage = false;
      });
      debugPrint('Error => $error');
      logger.e('StackTrace => $stackTrace');
      showToast('$error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Compare Image',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          const SizedBox(height: 25),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: compareImage,
            child: Card(
              child: SizedBox(
                height: 150,
                width: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    imagePathForCompare != null
                        ? Image.file(File(imagePathForCompare!))
                        : const Icon(Icons.image),
                    // if (selectedImagePath != null)
                    //   Positioned(
                    //     top: -10,
                    //     right: -10,
                    //     child: IconButton(
                    //       onPressed: clearSelectedImage,
                    //       icon: const Icon(Icons.cancel),
                    //     ),
                    //   ),
                  ],
                ),
              ),
            ),
          ),
          if (imageTransferResult != null)
            Row(
              children: [
                if (imageTransferResult!['response'] != null)
                  Expanded(
                    child: Text(
                      '${imageTransferResult!['response']}',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                if (imageTransferResult!['percentage'] != null)
                  Text(
                    double.parse('${imageTransferResult!['percentage']}')
                        .toStringAsFixed(2),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.amber),
                  ),
              ],
            ),
          const SizedBox(height: 20),
          CustomButton(
            onPressed: compareImage,
            isLoading: isComparingImage,
            btnTxt: 'Compare Image',
          ),
        ],
      ),
    );
  }
}
