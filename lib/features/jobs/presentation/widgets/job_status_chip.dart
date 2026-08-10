import 'package:flutter/material.dart';

class JobStatusChip extends StatelessWidget {
  const JobStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    // Mirrors the backend's JobStatus enum (app/domain/entities/job.py):
    // pending -> uploaded -> extracting -> transcribing -> restoring ->
    // chunking -> summarizing -> clipping -> completed | failed | cancelled.
    // Unrecognized values fall back to showing the raw status rather than
    // crashing, in case the backend adds a stage this build predates.
    final (label, color) = switch (status) {
      'pending' => ('Pending', Colors.grey),
      'uploaded' => ('Uploaded', Colors.blue),
      'extracting' => ('Extracting audio', Colors.blue),
      'transcribing' => ('Transcribing', Colors.blue),
      'restoring' => ('Restoring text', Colors.blue),
      'chunking' => ('Chunking', Colors.blue),
      'summarizing' => ('Summarizing', Colors.blue),
      'clipping' => ('Clipping', Colors.blue),
      'completed' => ('Completed', Colors.green),
      'failed' => ('Failed', Colors.red),
      'cancelled' => ('Cancelled', Colors.orange),
      _ => (status, Colors.grey),
    };

    return Chip(
      label: Text(label, style: TextStyle(color: color, fontSize: 12)),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
