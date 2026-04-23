import 'package:image_picker/image_picker.dart';

class CameraService {
  CameraService._();

  static final ImagePicker _picker = ImagePicker();

  static Future<String?> pickImageFromCamera() async {
    final x = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    return x?.path;
  }

  static Future<String?> pickImageFromGallery() async {
    final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    return x?.path;
  }

  static Future<String?> pickImage() async {
    final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    return x?.path;
  }
}
