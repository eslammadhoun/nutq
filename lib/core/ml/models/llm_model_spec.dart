import 'package:nutq/core/ml/models/model_spec.dart';

/// Static metadata for the two Gemma 3 instruction-tuned GGUF tiers offered
/// for on-device summarization (plan Section 5).
///
/// Both files are `Q4_K_M` quantizations from `bartowski/google_gemma-3-*
/// -it-GGUF` on Hugging Face — chosen over `google/gemma-3-*-it-qat-q4_0
/// -gguf` because bartowski's repo publishes the `Q4_K_M` variant
/// specifically (a better quality/size trade-off than the QAT-only `Q4_0`
/// google ships) and is the same well-known community quantizer whisper's
/// sibling model tiers already reference in spirit (plan Section 5's
/// "bartowski or unsloth" guidance). Both URLs were verified live via
/// `curl -I` against the Hugging Face `resolve/main` redirect during this
/// workstream — the `x-linked-size` response header matches
/// [approxSizeBytes] below to the byte:
///  - 1B: `x-linked-size: 806058496` (~806 MB)
///  - 4B: `x-linked-size: 2489758112` (~2.49 GB)
class LlmModelSpec implements ModelSpec {
  const LlmModelSpec({
    required this.id,
    required this.displayName,
    required this.approxSizeBytes,
    required this.downloadUrl,
    required this.isDefault,
    required this.minRamBytes,
    required this.contextLength,
  });

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

  /// Minimum device RAM this tier is offered at. See `RamGate` — enforced
  /// only when a RAM reading is actually available on the device; see that
  /// class's doc comment for the fallback when it isn't.
  final int minRamBytes;

  /// `n_ctx` recommended for this tier — informational for `ContextParams`
  /// callers (not consumed by this spec itself).
  final int contextLength;

  @override
  String get kind => 'llm';

  @override
  String get fileName => 'gemma-3-$id-it-q4_k_m.gguf';

  static final oneB = LlmModelSpec(
    id: '1b',
    displayName: 'Gemma 3 1B',
    approxSizeBytes: 806058496, // ~806 MB, verified via HF resolve HEAD (x-linked-size)
    downloadUrl: Uri.parse(
      'https://huggingface.co/bartowski/google_gemma-3-1b-it-GGUF/resolve/main/google_gemma-3-1b-it-Q4_K_M.gguf',
    ),
    isDefault: true,
    minRamBytes: 0, // no RAM floor — smallest tier, offered unconditionally
    contextLength: 4096,
  );

  static final fourB = LlmModelSpec(
    id: '4b',
    displayName: 'Gemma 3 4B',
    approxSizeBytes: 2489758112, // ~2.49 GB, verified via HF resolve HEAD (x-linked-size)
    downloadUrl: Uri.parse(
      'https://huggingface.co/bartowski/google_gemma-3-4b-it-GGUF/resolve/main/google_gemma-3-4b-it-Q4_K_M.gguf',
    ),
    isDefault: false,
    // Plan-mandated RAM gate for the opt-in 4B tier.
    minRamBytes: 6 * 1000 * 1000 * 1000,
    contextLength: 4096,
  );

  static final all = [oneB, fourB];

  static LlmModelSpec? byId(String id) {
    for (final spec in all) {
      if (spec.id == id) return spec;
    }
    return null;
  }
}
