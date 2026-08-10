import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_cubit.dart';
import 'package:nutq/features/jobs/presentation/widgets/job_card.dart';
import 'package:nutq/features/jobs/presentation/widgets/new_text_job_sheet.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<JobsCubit>().loadJobs();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final nearBottom = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;
    if (nearBottom) {
      context.read<JobsCubit>().loadMore();
    }
  }

  void _openNewJobSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<JobsCubit>(),
        child: const NewTextJobSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Jobs')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openNewJobSheet,
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<JobsCubit, JobsState>(
        listenWhen: (previous, current) =>
            current is JobsLoaded && current.actionError != null,
        listener: (context, state) {
          final message = (state as JobsLoaded).actionError!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        },
        builder: (context, state) {
          return switch (state) {
            JobsInitial() || JobsLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            JobsError(:final message) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<JobsCubit>().loadJobs(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            JobsLoaded(:final jobs) when jobs.isEmpty => RefreshIndicator(
              onRefresh: () => context.read<JobsCubit>().refresh(),
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: constraints.maxHeight,
                    child: const Center(
                      child: Text('No jobs yet. Tap + to submit one.'),
                    ),
                  ),
                ),
              ),
            ),
            JobsLoaded(:final jobs, :final isLoadingMore) => RefreshIndicator(
              onRefresh: () => context.read<JobsCubit>().refresh(),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: jobs.length + (isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= jobs.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return JobCard(job: jobs[index]);
                },
              ),
            ),
          };
        },
      ),
    );
  }
}
