import 'package:flutter/material.dart';
import 'package:nutq/features/jobs/data/models/job_models.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_status_chip.dart';

class JobCard extends StatelessWidget {
  const JobCard({super.key, required this.job});

  final JobModel job;

  String _formatDate(DateTime dateTime) {
    final local = dateTime.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        title: Text(job.sourceType[0].toUpperCase() + job.sourceType.substring(1)),
        subtitle: Text(_formatDate(job.createdAt)),
        trailing: JobStatusChip(status: job.status),
      ),
    );
  }
}
