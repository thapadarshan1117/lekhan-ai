import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class MediaPickerService {
  final ImagePicker _picker = ImagePicker();
  static const int maxFileSizeInBytes = 10 * 1024 * 1024; // 10MB

  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      
      if (image != null && await image.length() > maxFileSizeInBytes) {
        throw Exception('File size exceeds 10MB limit');
      }
      
      return image;
    } catch (e) {
      rethrow;
    }
  }

  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      
      if (image != null && await image.length() > maxFileSizeInBytes) {
        throw Exception('File size exceeds 10MB limit');
      }
      
      return image;
    } catch (e) {
      rethrow;
    }
  }

  Future<FilePickerResult?> pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
        withData: true,
      );
      
      if (result != null && 
          result.files.single.size > maxFileSizeInBytes) {
        throw Exception('File size exceeds 10MB limit');
      }
      
      return result;
    } catch (e) {
      rethrow;
    }
  }
}