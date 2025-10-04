import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PickedImageResult {
  const PickedImageResult({required this.filePath, required this.mimeType});

  final String filePath;
  final String mimeType;
}

class ImagePickerAdapter {
  ImagePickerAdapter({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<PickedImageResult?> pickImage(ImageSource source) async {
    final xFile = await _picker.pickImage(source: source, imageQuality: 85);
    if (xFile == null) {
      return null;
    }
    final directory = await getApplicationDocumentsDirectory();
    final fileName = p.basename(xFile.path);
    final destination = File(p.join(directory.path, 'attachments', fileName));
    await destination.parent.create(recursive: true);
    await xFile.saveTo(destination.path);
    final extension = p.extension(destination.path).replaceFirst('.', '');
    final mimeType = extension.isNotEmpty ? 'image/$extension' : 'image/jpeg';
    return PickedImageResult(filePath: destination.path, mimeType: mimeType);
  }
}
