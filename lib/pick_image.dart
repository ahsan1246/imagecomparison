import 'package:image_picker/image_picker.dart';

Future<String?> pickImage() async {
  XFile? photo = await ImagePicker().pickImage(
    source: ImageSource.camera,
    imageQuality: 90,
    preferredCameraDevice: CameraDevice.rear,
  );
  return photo?.path;
}
