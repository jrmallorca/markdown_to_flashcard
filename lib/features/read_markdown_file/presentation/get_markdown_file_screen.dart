import 'package:drop_shadow/drop_shadow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../theme/presentation/widgets/cycle_theme_button.dart';
import '../../tutorial/presentation/widgets/tutorial_button.dart';
import 'bloc/markdown_to_flashcard_cubit.dart';
import 'bloc/markdown_to_flashcard_state.dart';
import 'widgets/exception_dialog.dart';

class GetMarkdownFileScreen extends StatelessWidget {
  const GetMarkdownFileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _buildBody(context)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.import_export),
        onPressed: () =>
            context.read<MarkdownToFlashcardCubit>().getMarkdownFiles(),
      ),
      bottomNavigationBar: const BottomAppBar(
        shape: AutomaticNotchedShape(
          RoundedRectangleBorder(),
          StadiumBorder(side: BorderSide()),
        ),
        notchMargin: 8.0,
        child: Row(
          children: <Widget>[
            TutorialButton(),
            Spacer(),
            CycleThemeButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocConsumer<MarkdownToFlashcardCubit, MarkdownToFlashcardState>(
      listener: (context, state) {
        switch (state.status) {
          case GetMarkdownFilesStatus.failure:
            showDialog(
                context: context,
                builder: (context) =>
                    ExceptionDialog(message: state.errorMessage!));
            break;
          case GetMarkdownFilesStatus.cancelled:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('File selection cancelled')),
            );
            break;
          default:
        }
      },
      builder: (context, state) {
        return state.status == GetMarkdownFilesStatus.loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(child: _buildImage(context, state)),
                  Expanded(child: _buildDescription(context, state)),
                ],
              );
      },
    );
  }

  Widget _buildImage(BuildContext context, MarkdownToFlashcardState state) {
    switch (state.status) {
      case GetMarkdownFilesStatus.success:
        return const Center(
          child: Icon(
            Icons.check_circle_outline_rounded,
            size: 200.0,
            color: Colors.green,
          ),
        );
      default:
        return Center(
          child: DropShadow(
            offset: const Offset(8.0, 8.0),
            color: Colors.black54,
            child: Image.asset(
              'assets/images/anki.png',
              scale: 5.0,
            ),
          ),
        );
    }
  }

  Widget _buildDescription(
      BuildContext context, MarkdownToFlashcardState state) {
    String title;
    String description;

    switch (state.status) {
      case GetMarkdownFilesStatus.loading:
        title = '';
        description = '';
      case GetMarkdownFilesStatus.success:
        title = 'Success!';
        description = 'Imported the following:';
      default:
        title = 'Import to Anki';
        description =
            'Select a markdown or text file to import your flashcards from.';
    }

    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 36.0,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 25.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              Text(
                description,
                style: const TextStyle(
                  fontSize: 18.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25.0),
              if (state.notes.isNotEmpty)
                _buildImportedFilesList(context, state),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImportedFilesList(
      BuildContext context, MarkdownToFlashcardState state) {
    Color markdownColor = Theme.of(context).colorScheme.surfaceVariant;

    return Markdown(
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          code: TextStyle(backgroundColor: markdownColor),
          codeblockPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          codeblockDecoration: BoxDecoration(
              color: markdownColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)))),
      shrinkWrap: true,
      data: '''
```
${state.notes.map((note) => '- ${note.title}').join('\n')}
```
                ''',
    );
  }
}
