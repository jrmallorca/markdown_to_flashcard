import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_to_flashcard/core/errors/exception.dart';
import 'package:markdown_to_flashcard/features/read_markdown_file/domain/entities/note.dart';
import 'package:markdown_to_flashcard/features/read_markdown_file/domain/entities/question_answer_pair.dart';

void main() {
  final File noDeckMultipleTagsTitleMultipleQaFile = File(
      'test/fixtures/file_with__no-deck_multiple-tags_title_multiple-qa.md');
  final File deckNoTagsTitleMultipleQaFile =
      File('test/fixtures/file_with__deck_no-tags_title_multiple-qa.md');
  final File deckMultipleTagsNoTitleMultipleQaFile = File(
      'test/fixtures/file_with__deck_multiple-tags_no-title_multiple-qa.md');
  final File deckMultipleTagsTitleNoQaFile =
      File('test/fixtures/file_with__deck_multiple-tags_title_no-qa.md');
  final File deckMultipleTagsTitleMultipleQaFile =
      File('test/fixtures/file_with__deck_multiple-tags_title_multiple-qa.md');
  final File deckMultipleTagsTitleMultipleQaWithIdsFile = File(
      'test/fixtures/file_with__deck_multiple-tags_title_multiple-qa-with-ids.md');
  final File tagsAsList = File('test/fixtures/tags_as_list.md');

  group('get deck', () {
    String expected = 'test deck';

    test(
        'GIVEN a note with no deck, '
        "WHEN 'get deck' is called, "
        'THEN return ConversionException ', () async {
      File file = noDeckMultipleTagsTitleMultipleQaFile;
      Note note = Note(fileContents: file.readAsStringSync());

      expect(() => note.deck, throwsA(isA<ConversionException>()));
    });

    test(
        'GIVEN a note with a deck, '
        "WHEN 'get deck' is called, "
        'THEN return the note\'s deck ', () async {
      File file = deckMultipleTagsTitleMultipleQaFile;
      Note note = Note(fileContents: file.readAsStringSync());

      expect(note.deck, expected);
    });
  });

  group('get tags', () {
    List<String> expected = ['test-tag1', 'test-tag2', 'test-tag3'];

    test(
        'GIVEN a note with no tags, '
        "WHEN 'get tags' is called, "
        'THEN return ConversionException ', () async {
      File file = deckNoTagsTitleMultipleQaFile;
      Note note = Note(fileContents: file.readAsStringSync());

      expect(() => note.tags, throwsA(isA<ConversionException>()));
    });

    test(
        'GIVEN a note with tags, '
        "WHEN 'get tags' is called, "
        'THEN return the note\'s tags ', () async {
      File file = deckMultipleTagsTitleMultipleQaFile;
      Note note = Note(fileContents: file.readAsStringSync());

      expect(note.tags, expected);
    });

    test(
        'GIVEN a note with tags as list, '
        "WHEN 'get tags' is called, "
        'THEN return the note\'s tags ', () async {
      File file = tagsAsList;
      Note note = Note(fileContents: file.readAsStringSync());

      expect(note.tags, expected);
    });
  });

  group('get title', () {
    String expected = 'Title';

    test(
        'GIVEN a note with no title, '
        "WHEN 'get title' is called, "
        'THEN return ConversionException ', () async {
      File file = deckMultipleTagsNoTitleMultipleQaFile;
      Note note = Note(fileContents: file.readAsStringSync());

      expect(() => note.title, throwsA(isA<ConversionException>()));
    });

    test(
        'GIVEN a note with a title, '
        "WHEN 'get title' is called, "
        'THEN return the note\'s title ', () async {
      File file = deckMultipleTagsTitleMultipleQaFile;
      Note note = Note(fileContents: file.readAsStringSync());

      expect(note.title, expected);
    });
  });

  group('get questionAnswerPairs', () {
    test(
        'GIVEN a note with no question answer pairs, '
        "WHEN 'get questionAnswerPairs' is called, "
        'THEN return ConversionException ', () async {
      File file = deckMultipleTagsTitleNoQaFile;
      Note note = Note(fileContents: file.readAsStringSync());

      expect(
          () => note.questionAnswerPairs, throwsA(isA<ConversionException>()));
    });

    test(
        'GIVEN a note with question answer pairs with no IDs, '
        "WHEN 'get questionAnswerPairs' is called, "
        'THEN return the note\'s question answer pairs ', () async {
      List<QuestionAnswerPair> expected = [
        const QuestionAnswerPair(
            question: 'Test question 1', answer: 'Test answer 1'),
        const QuestionAnswerPair(
            question: 'Test question 2', answer: 'Test answer 2'),
        const QuestionAnswerPair(
            question: 'Test question 3', answer: 'Test answer 3'),
      ];

      File file = deckMultipleTagsTitleMultipleQaFile;
      Note note = Note(fileContents: file.readAsStringSync());

      expect(note.questionAnswerPairs, expected);
    });

    test(
        'GIVEN a note with question answer pairs that have IDs, '
        "WHEN 'get questionAnswerPairs' is called, "
        'THEN return the note\'s question answer pairs ', () async {
      List<QuestionAnswerPair> expected = [
        const QuestionAnswerPair(
          id: 123,
          question: 'Test question 1',
          answer: 'Test answer 1',
        ),
        const QuestionAnswerPair(
          id: 456,
          question: 'Test question 2',
          answer: 'Test answer 2',
        ),
        const QuestionAnswerPair(
          id: 789,
          question: 'Test question 3',
          answer: 'Test answer 3',
        ),
      ];

      File file = deckMultipleTagsTitleMultipleQaWithIdsFile;
      Note note = Note(fileContents: file.readAsStringSync());

      expect(note.questionAnswerPairs, expected);
    });
  });
}
