import 'package:flutter/foundation.dart';
import 'package:nutq/core/domain/content_language.dart';

/// What a model does in the pipeline.
enum ModelKind { summarizer, transcriber }

/// One file of a [ModelPack], as listed in `assets/models/manifest.json`.
@immutable
class ModelFile {
  const ModelFile({
    required this.name,
    required this.url,
    required this.bytes,
    required this.sha256,
  });

  factory ModelFile.fromJson(Map<String, Object?> json) => ModelFile(
    name: json['name']! as String,
    url: Uri.parse(json['url']! as String),
    bytes: json['bytes']! as int,
    sha256: json['sha256']! as String,
  );

  /// Name on disk, inside the pack's folder.
  final String name;
  final Uri url;
  final int bytes;

  /// Lowercase hex digest. A download is used only when it matches.
  final String sha256;
}

/// A model the app downloads on demand: one file (Gemma) or a folder of files
/// (Moonshine, which loads a whole directory).
@immutable
class ModelPack {
  const ModelPack({
    required this.id,
    required this.kind,
    required this.language,
    required this.version,
    required this.files,
  });

  factory ModelPack.fromJson(Map<String, Object?> json) => ModelPack(
    id: json['id']! as String,
    kind: ModelKind.values.byName(json['kind']! as String),
    language: ContentLanguage.fromCode(json['language']! as String),
    version: json['version']! as String,
    files: [
      for (final file in json['files']! as List<Object?>)
        ModelFile.fromJson(file! as Map<String, Object?>),
    ],
  );

  final String id;
  final ModelKind kind;

  /// The language a transcriber recognizes. The summarizer reads and writes
  /// both languages; its value is the one it was fine-tuned on.
  final ContentLanguage language;

  /// A new version is stored in its own folder, so an update never mixes
  /// files from two releases.
  final String version;
  final List<ModelFile> files;

  int get bytes => files.fold(0, (sum, file) => sum + file.bytes);
}
