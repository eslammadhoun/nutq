import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/features/transcription/data/wav_duration.dart';

/// Builds a WAV header for 16 kHz mono PCM16 (byte rate 32000), optionally
/// with a LIST chunk before `data`, as FFmpeg writes.
Uint8List _header({
  required int dataSize,
  bool withListChunk = false,
  int? declaredDataSize,
}) {
  final out = BytesBuilder();
  void tag(String s) => out.add(s.codeUnits);
  void u32(int v) => out.add((ByteData(4)..setUint32(0, v, Endian.little)).buffer.asUint8List());
  void u16(int v) => out.add((ByteData(2)..setUint16(0, v, Endian.little)).buffer.asUint8List());

  tag('RIFF');
  u32(36 + dataSize);
  tag('WAVE');
  tag('fmt ');
  u32(16);
  u16(1); // PCM
  u16(1); // mono
  u32(16000);
  u32(32000); // byte rate
  u16(2);
  u16(16);
  if (withListChunk) {
    tag('LIST');
    u32(5); // odd size: exercises chunk padding
    out.add('INFOx'.codeUnits);
    out.addByte(0);
  }
  tag('data');
  u32(declaredDataSize ?? dataSize);
  return out.toBytes();
}

void main() {
  test('reads duration from a canonical header', () {
    final head = _header(dataSize: 32000 * 90);
    final duration = wavDurationFromHeader(head, fileLength: head.length + 32000 * 90);
    expect(duration, const Duration(seconds: 90));
  });

  test('skips extra chunks, including odd-sized padded ones', () {
    final head = _header(dataSize: 32000 * 10, withListChunk: true);
    final duration = wavDurationFromHeader(head, fileLength: head.length + 32000 * 10);
    expect(duration, const Duration(seconds: 10));
  });

  test('bounds a bogus declared size by the real file length', () {
    final head = _header(dataSize: 0, declaredDataSize: 0xFFFFFFFF);
    final duration = wavDurationFromHeader(head, fileLength: head.length + 32000 * 5);
    expect(duration, const Duration(seconds: 5));
  });

  test('rejects data that is not a WAV file', () {
    expect(
      () => wavDurationFromHeader(Uint8List.fromList(List.filled(64, 7)), fileLength: 64),
      throwsFormatException,
    );
  });

  test('rejects a header without a data chunk', () {
    final head = _header(dataSize: 0).sublist(0, 36);
    expect(() => wavDurationFromHeader(head, fileLength: 36), throwsFormatException);
  });
}
