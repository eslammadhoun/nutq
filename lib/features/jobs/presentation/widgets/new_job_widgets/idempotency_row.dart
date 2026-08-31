import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_cubit.dart';
import 'package:nutq/features/jobs/presentation/cubit/new_job_state.dart';

class IdempotencyRow extends StatelessWidget {
  const IdempotencyRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      width: double.infinity,
      height: 40.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: context.appColors.subtle,
      ),
      child: Row(
        children: [
          Text('🔑', style: context.typography.bodyLarge),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              context.l10n.newJobIdempotencyKeyLabel,
              style: context.typography.bodyMedium.copyWith(
                color: context.appColors.textPrimary,
              ),
            ),
          ),
          BlocBuilder<NewJobCubit, NewJobState>(
            buildWhen: (previous, current) =>
                previous.idempotencyEnabled != current.idempotencyEnabled,
            builder: (context, state) {
              return SizedBox(
                height: 28.h,
                child: Switch(
                  value: state.idempotencyEnabled,
                  onChanged: (_) =>
                      context.read<NewJobCubit>().toggleIdempotency(),
                  thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return context.appColors.statusProcessing;
                    }
                    return Colors.white;
                  }),
                  trackColor: WidgetStateProperty.resolveWith<Color>((states) {
                    return context.appColors.borderDefault;
                  }),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
