import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:findom/config/app_config.dart';

class ImageUploadService {
  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    AppConfig.cloudinaryCloudName,
    AppConfig.cloudinaryUploadPreset, // Your unsigned upload preset
    cache: false,
  );

  Future<String?> uploadImage(File imageFile) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } on CloudinaryException catch (e) {
      print('Cloudinary Error: ${e.message}');
      return null;
    }
  }
}
