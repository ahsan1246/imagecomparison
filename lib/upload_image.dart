import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'custom_button.dart';
import 'pick_image.dart';
import 'api_service.dart';

class UploadImage extends StatefulWidget {
  const UploadImage({super.key});

  @override
  State<UploadImage> createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {
  bool isImageUploading = false;
  String? selectedImagePath;
  String? imageTransferResult;

  Future pickAnImage() async {
    await pickImage().then((imagePath) {
      if (imagePath != null) {
        setState(() {
          selectedImagePath = imagePath;
        });
      }
    });
  }

  void clearSelectedImage() => setState(() => selectedImagePath = null);

  Future uploadSelectedImage() async {
    setState(() {
      imageTransferResult = null;
      isImageUploading = true;
    });

    await ApiService.postMultiPartQuery(
      imageUploadUrl,
      fields: {'user_id': '1'},
      files: {'image': '$selectedImagePath'},
    ).then((res) {
      setState(() => isImageUploading = false);
      if (res == null) return null;
      showToast('${jsonDecode(res)['response']}');
      setState(() {
        imageTransferResult = res;
      });
    }).onError((error, stackTrace) {
      setState(() => isImageUploading = false);
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
              'Upload Image',
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
            onTap: pickAnImage,
            child: Card(
              child: SizedBox(
                height: 150,
                width: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    selectedImagePath != null
                        ? Image.file(File(selectedImagePath!))
                        : const Icon(Icons.add_a_photo_outlined),
                    if (selectedImagePath != null)
                      Positioned(
                        top: -10,
                        right: -10,
                        child: IconButton(
                          onPressed: clearSelectedImage,
                          icon: const Icon(Icons.cancel),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (imageTransferResult != null) Text('$imageTransferResult'),
          if (selectedImagePath != null)
            CustomButton(
              onPressed: uploadSelectedImage,
              isLoading: isImageUploading,
              btnTxt: 'Upload Image',
            ),
        ],
      ),
    );
  }
}
