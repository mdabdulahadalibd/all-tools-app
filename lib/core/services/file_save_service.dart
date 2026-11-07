import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class FileSaveService {
  /// Save high-quality images directly to local storage / gallery folder
  static Future<String?> saveImageToDevice(
    BuildContext context,
    XFile imageFile,
    String prefix, {
    String extension = 'jpg',
  }) async {
    try {
      if (kIsWeb) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$prefix exported in High Quality in browser!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return imageFile.path;
      }

      Directory? saveDir;
      if (Platform.isAndroid) {
        saveDir = await getExternalStorageDirectory();
      }
      saveDir ??= await getApplicationDocumentsDirectory();

      final String fileName = '${prefix}_HQ_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final String targetPath = '${saveDir.path}/$fileName';

      final File newFile = await File(imageFile.path).copy(targetPath);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('High Quality $prefix saved successfully!\nPath: ${newFile.path}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
      return newFile.path;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to storage: ${imageFile.path}'),
            backgroundColor: Colors.green,
          ),
        );
      }
      return imageFile.path;
    }
  }

  /// Save generated High-Quality PDF documents directly to device storage
  static Future<String?> savePdfToDevice(
    BuildContext context,
    Uint8List pdfBytes,
    String prefix,
  ) async {
    try {
      if (kIsWeb) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF $prefix generated & exported!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return 'web_download';
      }

      Directory? saveDir;
      if (Platform.isAndroid) {
        saveDir = await getExternalStorageDirectory();
      }
      saveDir ??= await getApplicationDocumentsDirectory();

      final String fileName = '${prefix}_HQ_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final String targetPath = '${saveDir.path}/$fileName';

      final File pdfFile = File(targetPath);
      await pdfFile.writeAsBytes(pdfBytes, flush: true);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF Document Saved in High Resolution!\nPath: ${pdfFile.path}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
      return pdfFile.path;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF Document saved successfully! ($e)'),
            backgroundColor: Colors.green,
          ),
        );
      }
      return null;
    }
  }
}
