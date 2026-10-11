import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:nutq/features/ai_models/domain/entities/model_pack.dart';

/// The models the app can download: `assets/models/manifest.json`, bundled
/// with the app. Checksums are pinned in the app itself, so a changed file on
/// a server is rejected rather than trusted.
abstract final class ModelManifest {
  static const asset = 'assets/models/manifest.json';

  /// The manifest format this app reads.
  static const schema = 1;

  static Future<List<ModelPack>> load([AssetBundle? bundle]) async =>
      parse(await (bundle ?? rootBundle).loadString(asset));

  static List<ModelPack> parse(String source) {
    final json = jsonDecode(source) as Map<String, Object?>;
    if (json['schema'] != schema) {
      throw FormatException('model manifest schema ${json['schema']}, expected $schema');
    }
    return [
      for (final pack in json['models']! as List<Object?>)
        ModelPack.fromJson(pack! as Map<String, Object?>),
    ];
  }
}
