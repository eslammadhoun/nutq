import 'package:nutq/core/ml/models/model_spec.dart';

/// Static metadata for the three whisper.cpp GGML model tiers offered to
/// the user, per the plan's accuracy/size trade-off (not `tiny` — Arabic
/// WER is materially worse at that tier).
///
/// URLs follow the same Hugging Face mirror the `whisper_ggml` package
/// itself resolves against (`WhisperModel.modelUri`,
/// `ggerganov/whisper.cpp` on Hugging Face) — full-precision (non-quantized)
/// `ggml-{tier}.bin` files, matching the plan's stated approximate sizes.
class WhisperModelSpec implements ModelSpec {
  const WhisperModelSpec({
    required this.id,
    required this.displayName,
    required this.approxSizeBytes,
    required this.downloadUrl,
    required this.isDefault,
  });

  /// Stable id, also used as the `modelId` in the `installed_models` table
  /// and as the on-disk filename (`ggml-{id}.bin`).
  @override
  final String id;
  @override
  final String displayName;
  @override
  final int approxSizeBytes;
  @override
  final Uri downloadUrl;
  @override
  final bool isDefault;

  @override
  String get kind => 'whisper';

  static final base = WhisperModelSpec(
    id: 'base',
    displayName: 'Base',
    approxSizeBytes: 148 * 1000 * 1000, // ~140 MB
    downloadUrl: Uri.parse('https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.bin'),
    isDefault: false,
  );

  static final small = WhisperModelSpec(
    id: 'small',
    displayName: 'Small',
    approxSizeBytes: 488 * 1000 * 1000, // ~460 MB
    downloadUrl: Uri.parse('https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.bin'),
    isDefault: true,
  );

  static final medium = WhisperModelSpec(
    id: 'medium',
    displayName: 'Medium',
    approxSizeBytes: 1530 * 1000 * 1000, // ~1.5 GB
    downloadUrl: Uri.parse('https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-medium.bin'),
    isDefault: false,
  );

  static final all = [base, small, medium];

  static WhisperModelSpec? byId(String id) {
    for (final spec in all) {
      if (spec.id == id) return spec;
    }
    return null;
  }

  @override
  String get fileName => 'ggml-$id.bin';
}
