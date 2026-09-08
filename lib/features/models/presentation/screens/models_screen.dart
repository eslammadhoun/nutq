import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:nutq/core/extensions/error_l10n_extension.dart';
import 'package:nutq/core/extensions/theme_extension.dart';
import 'package:nutq/features/models/presentation/cubit/model_tile_status.dart';
import 'package:nutq/features/models/presentation/cubit/models_cubit.dart';
import 'package:nutq/features/models/presentation/cubit/models_state.dart';

/// Minimal model-management screen (SRS: Models screen) — list the whisper
/// ASR tiers and the Gemma summarization tiers with download/delete +
/// progress, per CLAUDE.md's "keep it minimal, it's a placeholder feature"
/// guidance.
class ModelsScreen extends StatefulWidget {
  const ModelsScreen({super.key});

  @override
  State<ModelsScreen> createState() => _ModelsScreenState();
}

class _ModelsScreenState extends State<ModelsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ModelsCubit>().loadTiers();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocListener<ModelsCubit, ModelsState>(
      listenWhen: (previous, current) => current.lastError != null && previous.lastError != current.lastError,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(context.l10n.jobsErrorMessage(state.lastError!)),
              backgroundColor: context.appColors.statusFailed,
            ),
          );
        context.read<ModelsCubit>().clearError();
      },
      child: Scaffold(
        backgroundColor: context.appColors.base,
        appBar: AppBar(
          backgroundColor: context.appColors.base,
          elevation: 0,
          title: Text(l10n.modelsScreenTitle, style: context.typography.heading4),
        ),
        body: SafeArea(
          child: BlocBuilder<ModelsCubit, ModelsState>(
            builder: (context, state) {
              final asrTiers = state.tiers.where((t) => t.kind == 'whisper').toList();
              final llmTiers = state.tiers.where((t) => t.kind == 'llm').toList();
              return ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  if (asrTiers.isNotEmpty) ...[
                    Text(l10n.modelsSectionAsr, style: context.typography.heading6),
                    SizedBox(height: 8.h),
                    for (final tier in asrTiers) ...[_ModelTile(tier: tier), SizedBox(height: 12.h)],
                    SizedBox(height: 12.h),
                  ],
                  if (llmTiers.isNotEmpty) ...[
                    Text(l10n.modelsSectionSummarization, style: context.typography.heading6),
                    SizedBox(height: 8.h),
                    for (final tier in llmTiers) ...[_ModelTile(tier: tier), SizedBox(height: 12.h)],
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ModelTile extends StatelessWidget {
  const _ModelTile({required this.tier});

  final ModelTileState tier;

  String _tierName(BuildContext context) => switch (tier.id) {
    'base' => context.l10n.modelsTierBase,
    'small' => context.l10n.modelsTierSmall,
    'medium' => context.l10n.modelsTierMedium,
    '1b' => context.l10n.modelsTierGemma1b,
    '4b' => context.l10n.modelsTierGemma4b,
    _ => tier.displayName,
  };

  String _tierDescription(BuildContext context) => switch (tier.id) {
    'base' => context.l10n.modelsTierBaseDescription,
    'small' => context.l10n.modelsTierSmallDescription,
    'medium' => context.l10n.modelsTierMediumDescription,
    '1b' => context.l10n.modelsTierGemma1bDescription,
    '4b' => context.l10n.modelsTierGemma4bDescription,
    _ => '',
  };

  String _sizeLabel(BuildContext context, int approxSizeBytes) {
    final mb = approxSizeBytes / (1000 * 1000);
    if (mb >= 1000) {
      return context.l10n.modelsSizeGb((mb / 1000).toStringAsFixed(1));
    }
    return context.l10n.modelsSizeMb(mb.round().toString());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ramGated = tier.ramBlocked;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.appColors.card,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.appColors.borderSubtle),
      ),
      child: Opacity(
        opacity: ramGated ? 0.6 : 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(_tierName(context), style: context.typography.heading6),
                      if (tier.isDefault) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsetsDirectional.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: context.appColors.primaryLighter,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            l10n.modelsDefaultBadge,
                            style: context.typography.captionSmall.copyWith(color: context.appColors.textBrand),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  _sizeLabel(context, tier.approxSizeBytes),
                  style: context.typography.bodySmall.copyWith(color: context.appColors.textSecondary),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              _tierDescription(context),
              style: context.typography.bodySmall.copyWith(color: context.appColors.textSecondary),
            ),
            if (tier.ramBlocked || tier.ramUnknown) ...[
              SizedBox(height: 4.h),
              Text(
                tier.ramBlocked
                    ? l10n.modelsRamGateBlocked((tier.minRamBytes / (1000 * 1000 * 1000)).toStringAsFixed(0))
                    : l10n.modelsRamUnknownWarning((tier.minRamBytes / (1000 * 1000 * 1000)).toStringAsFixed(0)),
                style: context.typography.captionSmall.copyWith(color: context.appColors.statusFailed),
              ),
            ],
            SizedBox(height: 12.h),
            _statusRow(context, disabled: ramGated),
          ],
        ),
      ),
    );
  }

  Widget _statusRow(BuildContext context, {required bool disabled}) {
    final l10n = context.l10n;
    final cubit = context.read<ModelsCubit>();

    switch (tier.status) {
      case ModelTileStatus.installed:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.modelsInstalled, style: context.typography.bodySmall.copyWith(color: context.appColors.statusDone)),
            TextButton(
              onPressed: () => cubit.deleteModel(tier.id),
              child: Text(l10n.modelsDelete, style: TextStyle(color: context.appColors.statusFailed)),
            ),
          ],
        );
      case ModelTileStatus.downloading:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: tier.downloadProgress,
                minHeight: 6.h,
                backgroundColor: context.appColors.subtle,
                color: context.appColors.primary,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.modelsDownloading((tier.downloadProgress * 100).round()),
                  style: context.typography.bodySmall.copyWith(color: context.appColors.textSecondary),
                ),
                TextButton(
                  onPressed: () => cubit.cancelDownload(tier.id),
                  child: Text(l10n.modelsCancelDownload),
                ),
              ],
            ),
          ],
        );
      case ModelTileStatus.notInstalled:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.modelsNotInstalled,
              style: context.typography.bodySmall.copyWith(color: context.appColors.textTertiary),
            ),
            TextButton(
              onPressed: disabled ? null : () => cubit.download(tier.id),
              child: Text(l10n.modelsDownload),
            ),
          ],
        );
    }
  }
}
