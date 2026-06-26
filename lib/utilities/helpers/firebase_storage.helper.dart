import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class LNDFirebaseStorageHelper {
  LNDFirebaseStorageHelper._();

  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload multiple files with per-file progress.
  /// Returns List of download URLs.
  static Future<List<String>> uploadFiles({
    required List<File> files,
    required Function(String fileName, double progress) onProgress,
    String folder = "uploads",
  }) async {
    final List<String> downloadUrls = [];

    for (final file in files) {
      final url = await uploadFile(
        file: file,
        folder: folder,
        onProgress: onProgress,
      );

      downloadUrls.add(url);
    }

    return downloadUrls;
  }

  /// Upload a single file and return its download URL.
  static Future<String> uploadFile({
    required File file,
    required String folder,
    required Function(String fileName, double progress) onProgress,
    String? fileName,
    bool returnStoragePath = false,
  }) async {
    String env = const String.fromEnvironment('ENV', defaultValue: 'prod');
    final resolvedFileName =
        fileName ??
        "${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}";
    final ref = _storage.ref().child("$folder/$resolvedFileName");

    final uploadTask = ref.putFile(file);

    // Listen to progress
    uploadTask.snapshotEvents.listen((event) {
      final progress = event.bytesTransferred / event.totalBytes;
      onProgress(resolvedFileName, progress);
    }, onError: (_) {});

    // Wait for upload
    final snapshot = await uploadTask;

    // Get the download URL
    return returnStoragePath || env == 'local'
        ? snapshot.ref.fullPath
        : snapshot.ref.getDownloadURL();
  }
}
