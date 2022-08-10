import 'dart:async';

import 'package:flutter/services.dart';

/// Scan mode which is either QR code or BARCODE
enum ScanMode { QR, BARCODE, DEFAULT }

/// Provides access to the barcode scanner.
///
/// This class is an interface between the native Android and iOS classes and a
/// Flutter project.
class FlutterBarcodeScanner {
  static const MethodChannel _channel =
      MethodChannel('flutter_barcode_scanner');

  static const EventChannel _eventChannel =
      EventChannel('flutter_barcode_scanner_receiver');

  static Stream? _onBarcodeReceiver;

  /// Scan with the camera until a barcode is identified, then return.
  ///
  /// Shows a scan line with [lineColor] over a scan window.
  static Future<String> scanBarcode(String lineColor, ScanMode scanMode) async {
    // Pass params to the plugin
    Map params = <String, dynamic>{
      'lineColor': lineColor,
      'isContinuousScan': false,
      'scanMode': scanMode.index
    };

    /// Get barcode scan result
    final barcodeResult =
        await _channel.invokeMethod('scanBarcode', params) ?? '';
    return barcodeResult;
  }

  /// Returns a continuous stream of barcode scans until the user cancels the
  /// operation.
  ///
  /// Shows a scan line with [lineColor] over a scan window.
  static Stream? getBarcodeStreamReceiver(String lineColor, ScanMode scanMode) {
    // Pass params to the plugin
    Map params = <String, dynamic>{
      'lineColor': lineColor,
      'isContinuousScan': true,
      'scanMode': scanMode.index
    };

    // Invoke method to open camera, and then create an event channel which will
    // return a stream
    _channel.invokeMethod('scanBarcode', params);
    _onBarcodeReceiver ??= _eventChannel.receiveBroadcastStream();
    return _onBarcodeReceiver;
  }
}
