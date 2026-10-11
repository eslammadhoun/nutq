import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/domain/content_language.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/features/ai_models/domain/entities/model_pack.dart';
import 'package:nutq/features/ai_models/domain/entities/model_pack_status.dart';
import 'package:nutq/features/ai_models/presentation/cubit/model_download_cubit.dart';
import 'package:nutq/features/jobs/presentation/utils/job_display_format.dart';
import 'package:nutq/features/profile/presentation/widgets/settings_group.dart';
import 'package:nutq/l10n/app_localizations.dart';

/// Settings → AI models: each model's size and state. A missing one
/// downloads on tap, a downloading one pauses, a downloaded one offers to be
/// deleted.
class ModelsSection extends StatelessWidget {
  const ModelsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    return BlocBuilder<ModelDownloadCubit, ModelDownloadState>(
      builder: (context, state) => SettingsGroup(
        title: l10n.profileModels,
        children: [
          for (final pack in state.packs)
            SettingsRow(
              icon: pack.kind == ModelKind.summarizer
                  ? Icons.auto_awesome_rounded
                  : Icons.graphic_eq_rounded,
              iconColor: colors.primary,
              iconBackground: colors.primaryLighter,
              title: _name(l10n, pack),
              trailing: _Trailing(pack: pack, status: state.statusOf(pack.id)),
              onTap: () => _onTap(context, pack, state.statusOf(pack.id)),
            ),
        ],
      ),
    );
  }

  static String _name(AppLocalizations l10n, ModelPack pack) => switch (pack.kind) {
    ModelKind.summarizer => l10n.modelSummarizer,
    ModelKind.transcriber => switch (pack.language) {
      ContentLanguage.ar => l10n.modelSpeechArabic,
      ContentLanguage.en => l10n.modelSpeechEnglish,
    },
  };

  Future<void> _onTap(BuildContext context, ModelPack pack, ModelPackStatus status) async {
    final cubit = context.read<ModelDownloadCubit>();
    switch (status.phase) {
      case ModelPackPhase.downloading:
        cubit.pause();
      case ModelPackPhase.missing || ModelPackPhase.failed:
        cubit.download([pack.id]);
      case ModelPackPhase.ready:
        if (await _confirmDelete(context, pack)) await cubit.delete(pack.id);
    }
  }

  Future<bool> _confirmDelete(BuildContext context, ModelPack pack) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.modelDeleteTitle),
        content: Text(l10n.modelDeleteBody(formatBytes(pack.bytes))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.profileCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              l10n.profileDeleteAllConfirm,
              style: context.typography.labelMedium.copyWith(
                color: context.appColors.statusFailed,
              ),
            ),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
}

class _Trailing extends StatelessWidget {
  const _Trailing({required this.pack, required this.status});

  final ModelPack pack;
  final ModelPackStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final style = context.typography.caption.copyWith(color: colors.textSecondary);
    return switch (status.phase) {
      ModelPackPhase.ready => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(formatBytes(pack.bytes), style: style),
          SizedBox(width: 6.w),
          Icon(Icons.check_circle_rounded, size: 16.w, color: colors.statusDone),
        ],
      ),
      ModelPackPhase.downloading => Text('${(status.progress * 100).floor()}%', style: style),
      ModelPackPhase.failed => Icon(Icons.error_rounded, size: 18.w, color: colors.statusFailed),
      ModelPackPhase.missing => SettingsValue(
        '${context.l10n.modelNotDownloaded} · ${formatBytes(pack.bytes)}',
      ),
    };
  }
}
