import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// How fast this device does each step, measured on its own past jobs. The
/// defaults are an iPhone XR's, used until the first job of each kind is
/// measured.
@immutable
class JobRates {
  const JobRates({
    this.sourceRealTimeFactor = 0.1,
    this.spokenWordsPerSecond = 2.0,
    this.outputTokensPerSecond = 8.0,
    this.outputTokensPerWord = 2.0,
  });

  /// Seconds of audio extraction plus transcription per second of audio.
  final double sourceRealTimeFactor;

  /// Words a transcript has per second of audio.
  final double spokenWordsPerSecond;

  /// Summary tokens written per second of summarization, all-in: model load,
  /// prompt prefill and generation. What the summary step's length is
  /// estimated from.
  final double outputTokensPerSecond;

  /// Model tokens per word of summary.
  final double outputTokensPerWord;

  /// Weight of a new measurement against what was known: recent jobs count
  /// most, and one unusual job cannot swing an estimate far.
  static const _blend = 0.5;

  /// These rates after a transcription of [audio] that took [elapsed] and
  /// produced [words].
  JobRates afterTranscription({
    required Duration audio,
    required Duration elapsed,
    required int words,
  }) {
    final seconds = audio.inMilliseconds / 1000;
    if (seconds < 1) return this;
    return _copy(
      sourceRealTimeFactor: _mix(sourceRealTimeFactor, elapsed.inMilliseconds / 1000 / seconds),
      spokenWordsPerSecond: words > 0 ? _mix(spokenWordsPerSecond, words / seconds) : null,
    );
  }

  /// These rates after a summary of [summaryWords] words that took [elapsed]
  /// and generated [outputTokens].
  JobRates afterSummary({
    required int outputTokens,
    required Duration elapsed,
    required int summaryWords,
  }) {
    final seconds = elapsed.inMilliseconds / 1000;
    if (outputTokens <= 0 || seconds <= 0) return this;
    return _copy(
      outputTokensPerSecond: _mix(outputTokensPerSecond, outputTokens / seconds),
      outputTokensPerWord: summaryWords > 0
          ? _mix(outputTokensPerWord, outputTokens / summaryWords)
          : null,
    );
  }

  static double _mix(double known, double measured) =>
      measured.isFinite && measured > 0 ? known * (1 - _blend) + measured * _blend : known;

  JobRates _copy({
    double? sourceRealTimeFactor,
    double? spokenWordsPerSecond,
    double? outputTokensPerSecond,
    double? outputTokensPerWord,
  }) => JobRates(
    sourceRealTimeFactor: sourceRealTimeFactor ?? this.sourceRealTimeFactor,
    spokenWordsPerSecond: spokenWordsPerSecond ?? this.spokenWordsPerSecond,
    outputTokensPerSecond: outputTokensPerSecond ?? this.outputTokensPerSecond,
    outputTokensPerWord: outputTokensPerWord ?? this.outputTokensPerWord,
  );

  Map<String, double> toJson() => {
    'sourceRealTimeFactor': sourceRealTimeFactor,
    'spokenWordsPerSecond': spokenWordsPerSecond,
    'outputTokensPerSecond': outputTokensPerSecond,
    'outputTokensPerWord': outputTokensPerWord,
  };

  /// Unknown or invalid fields fall back to the defaults.
  factory JobRates.fromJson(Map<String, Object?> json) {
    const d = JobRates();
    double read(String key, double fallback) {
      final value = json[key];
      return value is num && value.isFinite && value > 0 ? value.toDouble() : fallback;
    }

    return JobRates(
      sourceRealTimeFactor: read('sourceRealTimeFactor', d.sourceRealTimeFactor),
      spokenWordsPerSecond: read('spokenWordsPerSecond', d.spokenWordsPerSecond),
      outputTokensPerSecond: read('outputTokensPerSecond', d.outputTokensPerSecond),
      outputTokensPerWord: read('outputTokensPerWord', d.outputTokensPerWord),
    );
  }
}

/// Where [JobRates] are kept between launches.
abstract interface class JobRatesStore {
  JobRates load();

  Future<void> save(JobRates rates);
}

/// Keeps rates for the life of the process only. For tests.
class InMemoryJobRatesStore implements JobRatesStore {
  InMemoryJobRatesStore([this.rates = const JobRates()]);

  JobRates rates;

  @override
  JobRates load() => rates;

  @override
  Future<void> save(JobRates rates) async => this.rates = rates;
}

/// One job's time budget: how long each step should take, from [rates] and
/// what is known about the job so far. Progress is time done ÷ total time, so
/// the bar moves at a steady pace whichever step is running, and the app and
/// the lock screen show the same number.
///
/// Estimates sharpen as the job learns more (the audio length after
/// extraction, the transcript's length after transcription). The caller keeps
/// the bar from going backwards when they do.
class JobPlan {
  JobPlan({
    required this.rates,
    required this._summaryRatio,
    this._transcriptWords,
  });

  final JobRates rates;
  final double Function(int sourceWords) _summaryRatio;

  Duration? _audio;
  int? _transcriptWords;

  /// Learned when the audio has been extracted.
  set audio(Duration value) => _audio = value;

  /// Learned when the transcript exists (pasted text has it from the start).
  set transcriptWords(int value) => _transcriptWords = value;

  /// Whether there is enough to estimate the whole job. Before the audio
  /// length of a media job is known there is not.
  bool get isKnown => _transcriptWords != null || _audio != null;

  double get sourceSeconds {
    final audio = _audio;
    return audio == null ? 0 : audio.inMilliseconds / 1000 * rates.sourceRealTimeFactor;
  }

  /// Summary tokens the model is expected to write.
  double get expectedOutputTokens {
    final audio = _audio;
    final words =
        _transcriptWords ??
        (audio == null ? 0 : (audio.inMilliseconds / 1000 * rates.spokenWordsPerSecond).round());
    if (words == 0) return 0;
    return words * _summaryRatio(words) * rates.outputTokensPerWord;
  }

  double get summarySeconds => expectedOutputTokens / rates.outputTokensPerSecond;

  /// The estimated length of the whole job.
  Duration get total => Duration(milliseconds: ((sourceSeconds + summarySeconds) * 1000).round());

  double get _totalSeconds => math.max(sourceSeconds + summarySeconds, 0.001);

  /// Whole-job progress with the source step [done] (0–1) through.
  double duringSource(double done) => (done.clamp(0.0, 1.0) * sourceSeconds) / _totalSeconds;

  /// Whole-job progress with [outputTokens] of the summary written.
  /// [sectionFraction] is the summarizer's own count of sections done, which
  /// keeps the bar moving when the token estimate runs out early. Stops short
  /// of the end, which only completion reaches.
  double duringSummary({required int outputTokens, double sectionFraction = 0}) {
    final expected = expectedOutputTokens;
    final byTokens = expected <= 0 ? 0.0 : outputTokens / expected;
    final done = math.min(math.max(byTokens, sectionFraction), 0.98);
    return (sourceSeconds + done * summarySeconds) / _totalSeconds;
  }
}
