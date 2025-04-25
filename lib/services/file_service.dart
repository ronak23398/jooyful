import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class FileService {
  /// Downloads a file from [url] and saves it to [savePath]
  /// Optionally reports progress through [onProgress] callback
  Future<File> downloadFile(
    String url, 
    String savePath, {
    Function(double)? onProgress,
  }) async {
    // Create the file
    final file = File(savePath);
    
    // Create parent directory if it doesn't exist
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    
    // Request file
    final request = http.Request('GET', Uri.parse(url));
    final response = await http.Client().send(request);
    
    // Get total size
    final contentLength = response.contentLength ?? 0;
    int downloaded = 0;
    
    // Download file with progress
    final sink = file.openWrite();
    await response.stream.listen(
      (List<int> chunk) {
        downloaded += chunk.length;
        sink.add(chunk);
        
        // Report progress
        if (contentLength > 0 && onProgress != null) {
          final progress = downloaded / contentLength;
          onProgress(progress);
        }
      },
      onDone: () async {
        await sink.flush();
        await sink.close();
        if (onProgress != null) {
          onProgress(1.0); // 100% complete
        }
      },
      onError: (e) {
        sink.close();
        throw e;
      },
      cancelOnError: true,
    ).asFuture();
    
    return file;
  }
  
  /// Gets the file extension from a file name or URL
  String getFileExtension(String fileNameOrUrl) {
    return path.extension(fileNameOrUrl).toLowerCase().replaceFirst('.', '');
  }
  
  /// Gets the file type (mime type) based on extension
  String? getFileType(String fileNameOrUrl) {
    String ext = getFileExtension(fileNameOrUrl);
    
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
      case 'docx':
        return 'application/msword';
      case 'xls':
      case 'xlsx':
        return 'application/vnd.ms-excel';
      case 'ppt':
      case 'pptx':
        return 'application/vnd.ms-powerpoint';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'txt':
        return 'text/plain';
      default:
        return null;
    }
  }
}