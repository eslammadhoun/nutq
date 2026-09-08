import 'package:flutter_test/flutter_test.dart';
import 'package:nutq/features/jobs/data/sockets/job_update_message_mapper.dart';
import 'package:nutq/features/jobs/domain/entities/job_update_event.dart';

Map<String, dynamic> _jobJson({bool withProgress = false}) => {
  'id': 'job-1',
  'status': 'processing',
  'source_type': 'upload',
  'language': 'ar',
  'created_at': '2026-01-01T00:00:00.000Z',
  'updated_at': '2026-01-01T00:00:00.000Z',
  if (withProgress) ...{
    'is_terminal': false,
    'stage_index': 1,
    'stage_total': 4,
    'stages': ['queued', 'transcribing', 'summarizing', 'done'],
    'progress': 0.25,
  },
};

void main() {
  group('toJobUpdateEvent', () {
    test('snapshot — maps the job payload, including WS-only progress fields', () {
      final event = {'type': 'snapshot', 'job': _jobJson(withProgress: true)}.toJobUpdateEvent();

      expect(event, isA<JobUpdateSnapshot>());
      final job = (event! as JobUpdateSnapshot).job;
      expect(job.id, 'job-1');
      expect(job.isTerminal, isFalse);
      expect(job.stageIndex, 1);
      expect(job.stageTotal, 4);
      expect(job.stages, ['queued', 'transcribing', 'summarizing', 'done']);
      expect(job.progress, 0.25);
    });

    test('status — maps stage/progress fields', () {
      final event = {
        'type': 'status',
        'stage_index': 2,
        'stage_total': 4,
        'progress': 0.5,
        'status': 'processing',
      }.toJobUpdateEvent();

      expect(event, isA<JobUpdateStatus>());
      final status = event! as JobUpdateStatus;
      expect(status.stageIndex, 2);
      expect(status.stageTotal, 4);
      expect(status.progress, 0.5);
      expect(status.status, 'processing');
    });

    test('metadata — carries the free-form payload', () {
      final event = {
        'type': 'metadata',
        'data': {'duration': 12.5},
      }.toJobUpdateEvent();

      expect(event, isA<JobUpdateMetadata>());
      expect((event! as JobUpdateMetadata).data, {'duration': 12.5});
    });

    test('transcript_word — maps index + word', () {
      final event = {'type': 'transcript_word', 'index': 3, 'word': 'مرحبا'}.toJobUpdateEvent();

      expect(event, isA<JobUpdateTranscriptWord>());
      final word = event! as JobUpdateTranscriptWord;
      expect(word.index, 3);
      expect(word.word, 'مرحبا');
    });

    test('transcript_done', () {
      expect({'type': 'transcript_done'}.toJobUpdateEvent(), isA<JobUpdateTranscriptDone>());
    });

    test('summary_word — maps index + word', () {
      final event = {'type': 'summary_word', 'index': 1, 'word': 'Hello'}.toJobUpdateEvent();

      expect(event, isA<JobUpdateSummaryWord>());
      final word = event! as JobUpdateSummaryWord;
      expect(word.index, 1);
      expect(word.word, 'Hello');
    });

    test('summary_done', () {
      expect({'type': 'summary_done'}.toJobUpdateEvent(), isA<JobUpdateSummaryDone>());
    });

    test('done — maps the terminal job payload', () {
      final event = {'type': 'done', 'job': _jobJson(withProgress: true)}.toJobUpdateEvent();

      expect(event, isA<JobUpdateDone>());
      expect((event! as JobUpdateDone).job.id, 'job-1');
    });

    test(
      'snapshot for an already-terminal job inlines transcript/summary text '
      '(sibling of job, not nested inside it)',
      () {
        final event = {
          'type': 'snapshot',
          'job': _jobJson(),
          'transcript': {'available': true, 'text': 'مرحبا بالعالم'},
          'summary': {
            'available': true,
            'text': 'A short summary.',
            'takeaways': [
              {'text': 'Point one'},
            ],
          },
        }.toJobUpdateEvent();

        expect(event, isA<JobUpdateSnapshot>());
        final snapshot = event! as JobUpdateSnapshot;
        expect(snapshot.transcriptText, 'مرحبا بالعالم');
        expect(snapshot.summaryText, 'A short summary.');
        expect(snapshot.summaryTakeaways, [
          {'text': 'Point one'},
        ]);
      },
    );

    test('done inlines transcript/summary text the same way as snapshot', () {
      final event = {
        'type': 'done',
        'job': _jobJson(),
        'transcript': {'available': true, 'text': 'Final transcript.'},
        'summary': {'available': true, 'text': 'Final summary.', 'takeaways': []},
      }.toJobUpdateEvent();

      expect(event, isA<JobUpdateDone>());
      final done = event! as JobUpdateDone;
      expect(done.transcriptText, 'Final transcript.');
      expect(done.summaryText, 'Final summary.');
    });

    test('snapshot for a still-running job leaves transcript/summary text null', () {
      final event = {
        'type': 'snapshot',
        'job': _jobJson(withProgress: true),
        'transcript': {'available': false},
        'summary': {'available': false},
      }.toJobUpdateEvent();

      expect(event, isA<JobUpdateSnapshot>());
      final snapshot = event! as JobUpdateSnapshot;
      expect(snapshot.transcriptText, isNull);
      expect(snapshot.summaryText, isNull);
      expect(snapshot.summaryTakeaways, isNull);
    });

    test('error — maps message + code', () {
      final event = {
        'type': 'error',
        'message': 'Pipeline failed',
        'code': 'pipeline_error',
      }.toJobUpdateEvent();

      expect(event, isA<JobUpdateError>());
      final error = event! as JobUpdateError;
      expect(error.message, 'Pipeline failed');
      expect(error.code, 'pipeline_error');
    });

    test('heartbeat', () {
      expect({'type': 'heartbeat'}.toJobUpdateEvent(), isA<JobUpdateHeartbeat>());
    });

    test('pong', () {
      expect({'type': 'pong'}.toJobUpdateEvent(), isA<JobUpdatePong>());
    });

    test('an unknown type returns null instead of throwing', () {
      expect({'type': 'something_new'}.toJobUpdateEvent(), isNull);
    });

    test('a malformed frame (missing required field) returns null instead of throwing', () {
      // transcript_word with no 'index' — would throw a cast error if unguarded.
      expect({'type': 'transcript_word', 'word': 'oops'}.toJobUpdateEvent(), isNull);
    });
  });
}
