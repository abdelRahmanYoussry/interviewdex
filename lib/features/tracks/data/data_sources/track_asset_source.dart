import 'package:flutter/services.dart';

abstract interface class TrackAssetSource {
  Future<String> loadString(String path);
  Future<Uint8List> loadBytes(String path);
}

class FlutterTrackAssetSource implements TrackAssetSource {
  const FlutterTrackAssetSource({AssetBundle? bundle}) : _bundle = bundle;

  final AssetBundle? _bundle;

  @override
  Future<String> loadString(String path) {
    return (_bundle ?? rootBundle).loadString(path);
  }

  @override
  Future<Uint8List> loadBytes(String path) async {
    final data = await (_bundle ?? rootBundle).load(path);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
}
