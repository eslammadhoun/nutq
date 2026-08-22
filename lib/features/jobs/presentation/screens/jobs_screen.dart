import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_cubit.dart';
import 'package:nutq/features/jobs/presentation/widgets/jobs_filter_chips.dart';
import 'package:nutq/features/jobs/presentation/widgets/jobs_fab.dart';
import 'package:nutq/features/jobs/presentation/widgets/jobs_header.dart';
import 'package:nutq/features/jobs/presentation/widgets/jobs_list.dart';
import 'package:nutq/features/jobs/presentation/widgets/jobs_search_bar.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<JobsCubit>().fetchJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const JobsHeader(),
            SizedBox(height: 20.h),
            const JobsSearchBar(),
            SizedBox(height: 12.h),
            const JobsFilterChips(),
            const Expanded(child: JobsList()),
          ],
        ),
      ),
      floatingActionButton: const JobsFab(),
    );
  }
}
