import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../../core/services/file_save_service.dart';

abstract class PdfPlatformAdapter {
  bool get isWeb => kIsWeb;
  bool get isMobile => !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);
  bool get isDesktop => !kIsWeb && (defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.linux);

  Future<String?> savePdf(BuildContext context, Uint8List pdfBytes, String filenamePrefix) {
    return FileSaveService.savePdfToDevice(context, pdfBytes, filenamePrefix);
  }

  Future<String?> saveImage(BuildContext context, Uint8List imageBytes, String filenamePrefix, {String extension = 'png'}) {
    return FileSaveService.saveImageBytesToDevice(context, imageBytes, filenamePrefix, extension: extension);
  }
}

class PdfDefaultPlatformAdapter extends PdfPlatformAdapter {}
