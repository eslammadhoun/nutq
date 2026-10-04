/// A summarization model and how to drive it.
class SummarizerModel {
  const SummarizerModel({
    required this.asset,
    required this.contextTokens,
    required this.useTrainingPrompt,
  });

  /// Bundled `.litertlm`, listed under `flutter: assets:` in pubspec.yaml.
  /// Must be under `assets/`: flutter_gemma prefixes every asset path with
  /// `assets/`, so a model anywhere else is not found at install time.
  final String asset;

  /// Context window: prompt + generated output. Must not exceed the KV cache
  /// the `.litertlm` was converted with.
  final int contextTokens;

  /// Prompt Arabic text with the exact instruction the model was fine-tuned on
  /// (gemma_playground/training/finetune_gemma3_1b_arabic_summarization.ipynb).
  /// A fine-tune only behaves as trained when prompted the same way.
  final bool useTrainingPrompt;

  String get fileName => asset.split('/').last;

  /// Stored with every summary it produces.
  String get id => fileName.replaceAll('.litertlm', '');
}

/// Stock Gemma 3 1B instruct, int4. Weak in Arabic: loops and invents facts.
const stockGemma = SummarizerModel(
  asset: 'assets/models/gemma3-1b-it-q4.litertlm',
  contextTokens: 4096,
  useTrainingPrompt: false,
);

/// Gemma 3 1B fine-tuned on Arabic news summaries (XLSum + arabsummaries),
/// int4 with a 2048-token KV cache: 579 MB, which an iPhone XR (3 GB) holds
/// without paging the weights.
const arabicFinetunedV3 = SummarizerModel(
  asset: 'assets/models/gemma3-1b-arabic-summarizer-v3_q4_block32_ekv2048.litertlm',
  contextTokens: 2048,
  useTrainingPrompt: true,
);

/// The model the app uses.
const SummarizerModel activeSummarizerModel = arabicFinetunedV3;

/// Bump when the prompt templates change; stored with every summary.
const String summarizationPromptVersion = 'v2-sections';
