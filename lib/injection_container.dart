import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:markdown_to_flashcard/features/theme/data/data_sources/theme_local_data_source.dart';
import 'package:markdown_to_flashcard/features/theme/data/repositories/theme_repository.dart';
import 'package:markdown_to_flashcard/features/theme/presentation/bloc/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/read_markdown_file/data/data_sources/markdown_file_picker_local_data_source.dart';
import 'features/read_markdown_file/data/repositories/markdown_file_repository.dart';
import 'features/read_markdown_file/domain/use_cases/add_question_answer_pairs_in_note_to_ankidroid_use_case.dart';
import 'features/read_markdown_file/domain/use_cases/convert_markdown_note_to_dart_note_use_case.dart';
import 'features/read_markdown_file/domain/use_cases/convert_markdown_to_html_use_case.dart';
import 'features/read_markdown_file/domain/use_cases/request_ankidroid_permission_use_case.dart';
import 'features/read_markdown_file/presentation/bloc/markdown_to_flashcard_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features
  sl.registerFactory(
    () => MarkdownToFlashcardCubit(
      convertMarkdownNoteToDartNote: sl(),
      convertMarkdownToHTMLUseCase: sl(),
      addQuestionAnswerPairsInNoteToAnkidroid: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => RequestAnkidroidPermissionUseCase(
      methodChannel: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => ConvertMarkdownNoteToDartNoteUseCase(
      repository: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => ConvertMarkdownToHTMLUseCase(),
  );

  sl.registerLazySingleton(
    () => AddQuestionAnswerPairsInNoteToAnkidroidUseCase(
      methodChannel: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => MarkdownFileRepository(
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => MarkdownFilePickerLocalDataSource(),
  );

  // Theme
  sl.registerFactory(() => ThemeCubit(repository: sl()));

  sl.registerLazySingleton(
    () => ThemeRepository(
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => ThemeLocalDataSource(
      key: 'themeStatus',
      preferences: sl(),
    ),
  );

  // Core
  sl.registerLazySingleton(
    () => const MethodChannel('app.jrmallorca.markdown_to_flashcard/ankidroid'),
  );

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}
