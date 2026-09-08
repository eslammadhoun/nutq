/// Maps the REST API base URL to the WebSocket URL for a job's live-update
/// stream, per the `nutq_api` contract: `GET /v1/jobs/{job_id}/ws`.
///
/// `http`/`https` base URLs become `ws`/`wss` respectively; the job id is
/// appended as `/jobs/{jobId}/ws`. Pure function — no I/O, easy to unit test
/// in isolation from the socket service itself.
Uri buildJobSocketUri(String baseUrl, String jobId) {
  final base = Uri.parse(baseUrl);
  final scheme = switch (base.scheme) {
    'https' => 'wss',
    'http' => 'ws',
    final other => other,
  };

  final basePath = base.path.endsWith('/')
      ? base.path.substring(0, base.path.length - 1)
      : base.path;

  return base.replace(scheme: scheme, path: '$basePath/jobs/$jobId/ws');
}
