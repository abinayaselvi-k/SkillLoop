import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Picks a profile image from the Android gallery and stores it under the
/// signed-in user's own Storage folder.
class ProfileImageService {
  final ImagePicker _picker;
  final FirebaseStorage _storage;

  ProfileImageService({ImagePicker? picker, FirebaseStorage? storage})
    : _picker = picker ?? ImagePicker(),
      _storage = storage ?? FirebaseStorage.instance;

  Future<String?> pickAndUpload(String userId) async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (image == null) return null;

    final extension = image.name.contains('.')
        ? image.name.substring(image.name.lastIndexOf('.') + 1)
        : 'jpg';
    final ref = _storage.ref(
      'profile_photos/$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.$extension',
    );
    await ref.putFile(File(image.path));
    return ref.getDownloadURL();
  }
}
