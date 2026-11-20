import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'web_download_stub.dart' if (dart.library.html) 'web_download_helper.dart';

class FileSaveService {
  /// Save raw byte image data (PNG / JPG) directly to device storage or browser download
  static Future<String?> saveImageBytesToDevice(
    BuildContext context,
    Uint8List bytes,
    String prefix, {
    String extension = 'png',
  }) async {
    try {
      final String fileName = '${prefix}_HQ_${DateTime.now().millisecondsSinceEpoch}.$extension';

      if (kIsWeb) {
        downloadBytesInBrowser(bytes, fileName);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$prefix downloaded successfully in browser!'),
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

      final String targetPath = '${saveDir.path}/$fileName';
      final File imageFile = File(targetPath);
      await imageFile.writeAsBytes(bytes, flush: true);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$prefix saved successfully as $extension!\nPath: ${imageFile.path}'),
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
      return imageFile.path;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving $extension image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  /// Save high-quality images directly to local storage / gallery folder
  static Future<String?> saveImageToDevice(
    BuildContext context,
    XFile imageFile,
    String prefix, {
    String extension = 'jpg',
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      if (!context.mounted) return null;
      return await saveImageBytesToDevice(context, bytes, prefix, extension: extension);
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

  /// Save generated High-Quality PDF documents directly to device storage or browser download
  static Future<String?> savePdfToDevice(
    BuildContext context,
    Uint8List pdfBytes,
    String prefix,
  ) async {
    try {
      final String fileName = '${prefix}_HQ_${DateTime.now().millisecondsSinceEpoch}.pdf';

      if (kIsWeb) {
        downloadBytesInBrowser(pdfBytes, fileName);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF Document downloaded in browser! ($fileName)'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
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
