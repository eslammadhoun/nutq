import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/di/dependency_injection.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/features/ai_models/domain/entities/model_pack.dart';
import 'package:nutq/features/ai_models/presentation/cubit/model_download_cubit.dart';
import 'package:nutq/features/ai_models/presentation/widgets/model_download_panel.dart';

/// Offers the download of [packs] a job is waiting for. True once they are
/// ready and the user continued; false when the sheet was dismissed (a
/// running download carries on).
Future<bool> showModelDownloadSheet(BuildContext context, List<ModelPack> packs) async {
  final colors = context.appColors;
  final ready = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: colors.navBarBg,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (sheetContext) => BlocProvider<ModelDownloadCubit>(
      create: (_) => sl<ModelDownloadCubit>(param1: packs),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 16.h),
          child: ModelDownloadPanel(
            title: sheetContext.l10n.modelsNeededTitle,
            onDone: () => Navigator.pop(sheetContext, true),
          ),
        ),
      ),
    ),
  );
  return ready ?? false;
}
