import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/read_markdown_file/data/data_sources/agnostic_os_files_local_data_source.dart';
import 'features/read_markdown_file/data/data_sources/android_os_files_local_data_source.dart';
import 'features/read_markdown_file/data/data_sources/markdown_files_local_data_source.dart';
import 'features/read_markdown_file/data/repositories/note_repository.dart';
import 'features/read_markdown_file/domain/use_cases/add_flashcard_ids_to_note_use_case.dart';
import 'features/read_markdown_file/domain/use_cases/convert_markdown_to_html_use_case.dart';
import 'features/read_markdown_file/domain/use_cases/create_or_update_flashcards_in_note_to_ankidroid_use_case.dart';
import 'features/read_markdown_file/domain/use_cases/request_ankidroid_permission_use_case.dart';
import 'features/read_markdown_file/presentation/bloc/markdown_to_flashcard_cubit.dart';
import 'features/theme/data/data_sources/theme_local_data_source.dart';
import 'features/theme/data/repositories/theme_repository.dart';
import 'features/theme/presentation/bloc/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features
  sl.registerFactory(
    () => MarkdownToFlashcardCubit(
        noteRepository: sl(),
        convertMarkdownToHTML: sl(),
        addQuestionAnswerPairsInNoteToAnkidroidAndGetIDs: sl(),
        addFlashcardIDsToNote: sl()),
  );

  sl.registerLazySingleton(
    () => RequestAnkidroidPermissionUseCase(
      methodChannel: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => ConvertMarkdownToHTMLUseCase(markdownToHTMLProxy: sl()),
  );

  sl.registerLazySingleton(
    () => CreateOrUpdateFlashcardsInNoteToAnkidroidUseCase(
      methodChannel: sl(),
    ),
  );

  sl.registerLazySingleton(() => AddFlashcardIDsToNoteUseCase());

  sl.registerLazySingleton(
    () => NoteRepository(
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton(() => platformDataSource());

  sl.registerLazySingleton(() => PickFilesProxy());

  sl.registerLazySingleton(() => MarkdownToHTMLProxy());

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

MarkdownFilesLocalDataSource platformDataSource() {
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return AndroidOSFilesLocalDataSource(methodChannel: sl());
    default:
      return AgnosticOSFilesLocalDataSource(pickFilesProxy: sl());
  }
}
