import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

/// Bytes read from the start of a WAV file. Headers written by FFmpeg are
/// under 100 bytes; the margin covers extra metadata chunks.
const _headerScanBytes = 4096;

/// Playing time of a PCM WAV file, read from its header alone.
///
/// Avoids decoding the audio or spawning `ffprobe` just to learn the length.
Future<Duration> readWavDuration(File file) async {
  final length = await file.length();
  final reader = await file.open();
  try {
    final head = await reader.read(math.min(length, _headerScanBytes));
    return wavDurationFromHeader(head, fileLength: length);
  } finally {
    await reader.close();
  }
}

/// Parses the RIFF chunks in [head] to find the audio format and data size.
///
/// Throws [FormatException] if [head] is not a PCM WAV header.
Duration wavDurationFromHeader(Uint8List head, {required int fileLength}) {
  final bytes = ByteData.sublistView(head);
  if (head.length < 12 || _tag(head, 0) != 'RIFF' || _tag(head, 8) != 'WAVE') {
    throw const FormatException('Not a WAV file');
  }

  int? byteRate;
  var offset = 12;
  while (offset + 8 <= head.length) {
    final id = _tag(head, offset);
    final size = bytes.getUint32(offset + 4, Endian.little);
    final body = offset + 8;

    if (id == 'fmt ' && body + 12 <= head.length) {
      byteRate = bytes.getUint32(body + 8, Endian.little);
    } else if (id == 'data') {
      if (byteRate == null || byteRate == 0) break;
      // A streamed file may declare a bogus size; the file length bounds it.
      final available = fileLength - body;
      final dataBytes = math.min(size, available);
      return Duration(microseconds: dataBytes * 1000000 ~/ byteRate);
    }
    // Chunks are padded to an even number of bytes.
    offset = body + size + (size.isOdd ? 1 : 0);
  }
  throw const FormatException('WAV header is missing its fmt or data chunk');
}

String _tag(Uint8List bytes, int offset) => String.fromCharCodes(bytes.sublist(offset, offset + 4));
