import 'dart:async';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class CunningDocumentScanner {
  static const MethodChannel _channel =
      MethodChannel('cunning_document_scanner');

  /// Call this to start the get Picture workflow from the camera scanner.
  static Future<List<String>?> getPictures({
      int noOfPages = 100,
      bool isGalleryImportAllowed = false}) async {
    await _requestPermissions();

    final List<dynamic>? pictures = await _channel.invokeMethod('getPictures', {
      'noOfPages': noOfPages,
      'isGalleryImportAllowed': isGalleryImportAllowed,
    });
    return pictures?.map((e) => e as String).toList();
  }

  /// Call this method to pick a picture from the gallery.
  static Future<List<String>?> getPictureFromGallery() async {
    await _requestPermissions();

    final List<dynamic>? pictures = await _channel.invokeMethod('getPictureFromGallery');
    return pictures?.map((e) => e as String).toList();
  }

  static Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.photos, // Ensure this permission is requested for iOS
    ].request();
    if (statuses.containsValue(PermissionStatus.denied) ||
        statuses.containsValue(PermissionStatus.permanentlyDenied)) {
      throw Exception("Permission not granted");
    }
  }
}
