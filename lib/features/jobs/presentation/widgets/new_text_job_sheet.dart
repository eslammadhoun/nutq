import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutq/features/jobs/presentation/cubit/jobs_cubit.dart';

class NewTextJobSheet extends StatefulWidget {
  const NewTextJobSheet({super.key});

  @override
  State<NewTextJobSheet> createState() => _NewTextJobSheetState();
}

class _NewTextJobSheetState extends State<NewTextJobSheet> {
  final _textCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<JobsCubit>().submitTextJob(_textCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobsCubit, JobsState>(
      listenWhen: (previous, current) =>
          previous is JobsLoaded &&
          current is JobsLoaded &&
          previous.isSubmitting &&
          !current.isSubmitting,
      listener: (context, state) {
        if (state is JobsLoaded && state.actionError == null) {
          Navigator.of(context).pop();
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'New text job',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _textCtrl,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Text to summarize',
                  alignLabelWithHint: true,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter some text'
                    : null,
              ),
              const SizedBox(height: 16),
              BlocBuilder<JobsCubit, JobsState>(
                builder: (context, state) {
                  final isSubmitting = state is JobsLoaded && state.isSubmitting;
                  return ElevatedButton(
                    onPressed: isSubmitting ? null : _submit,
                    child: isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
