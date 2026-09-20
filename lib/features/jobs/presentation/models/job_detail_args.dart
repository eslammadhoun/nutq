import 'package:flutter/foundation.dart';

/// Route arguments for the Job Detail screen: the transcript to summarize on
/// the device and its language code.
@immutable
class JobDetailArgs {
  const JobDetailArgs({required this.text, this.language = 'ar'});

  final String text;
  final String language;
}
