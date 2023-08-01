import 'dart:io';

import 'package:flutter/material.dart';
import 'package:taxiappuserimagecompare/models/compare_image_model.dart';

import '../components/custom_button.dart';
import '../components/pick_image.dart';
import '../services/api_service.dart';

class CompareImage extends StatefulWidget {
  const CompareImage({super.key});

  @override
  State<CompareImage> createState() => _CompareImageState();
}

class _CompareImageState extends State<CompareImage> {
  bool isComparingImage = false;
  String? imagePathForCompare;
  CompareImageModel? imageComparisonResult;

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
      imageComparisonResult = CompareImageModel(result: '$res');
      if (res == null) return null;
      final data = CompareImageModel.fromRawJson(res);
      showToast('${data.result}');
      setState(() {
        imageComparisonResult = data;
      });
    }).onError((error, stackTrace) {
      setState(() {
        imageComparisonResult = CompareImageModel(result: '$error');
        isComparingImage = false;
      });
      debugPrint('Error => $error');
      logger.e('StackTrace => $stackTrace');
      showToast('$error');
    });
  }

  String get matchStatus {
    if (double.parse(imageComparisonResult!.percentage!) > 80) {
      return 'Matched';
    } else {
      return 'Not Matched';
    }
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
          if (imageComparisonResult != null)
            Column(
              children: [
                Text(
                  '${imageComparisonResult!.result}',
                  style: const TextStyle(fontSize: 20),
                ),
                if (imageComparisonResult?.percentage != null)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          matchStatus,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      Text(
                        '${imageComparisonResult!.percentage}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.amber,
                        ),
                      ),
                    ],
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
