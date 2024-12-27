import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../../../../core/errors/exception.dart';
import 'question_answer_pair.dart';

class Note extends Equatable {
  final String? uri;
  final String fileContents;

  const Note({
    this.uri,
    required this.fileContents,
  });

  String get title {
    RegExp regex = RegExp(r'# ([^\n]+)');

    return regex.firstMatch(fileContents)?.group(1) ??
        (throw ConversionException(
          message: '''
We couldn't detect a title. Please check the file is formatted correctly.
        ''',
        ));
  }

  String get deck {
    RegExp regex = RegExp(r'deck: ([^\n]+)');

    return regex.firstMatch(fileContents)?.group(1) ??
        (throw ConversionException(
          message: '''
We couldn't detect a deck. Please check the file is formatted correctly:

$title
        ''',
        ));
  }

  List<String> get tags {
    RegExp tableTags = RegExp(r'tags: \[(.*)\]');
    String? tableTagsResult = tableTags.firstMatch(fileContents)?.group(1)!;

    if (tableTagsResult != null) {
      return _getTagsFromTable(tableTagsResult);
    } else {
      List<String> tags = [];

      bool isInTags = false;
      for (var line in _getFrontMatter()) {
        if (!isInTags && line.contains('tags:')) isInTags = true;

        if (isInTags) {
          List<String> delimitedLine = line.split('- ');

          if (delimitedLine.length > 1) {
            tags.add(delimitedLine[1].trim());
          }
        }
      }

      if (!isInTags) {
        throw ConversionException(
          message: '''
We couldn't detect any tags. Please check the file is formatted correctly:

$title
          ''',
        );
      } else {
        return tags;
      }
    }
  }

  List<String> _getTagsFromTable(String identifiedTags) {
    List<String> trimmedTags =
        identifiedTags.split(',').map((e) => e.trim()).toList();
    return identifiedTags.isEmpty ? [] : trimmedTags;
  }

  List<String> _getFrontMatter() {
    LineSplitter ls = const LineSplitter();
    List<String> lines = ls.convert(fileContents);

    // Start by 1 as the start of the front matter should always be at 0.
    for (int i = 1; i < lines.length; i++) {
      if (lines[i] == '---') return lines.getRange(0, i).toList();
    }

    throw ConversionException(
      message: '''
We couldn't detect the frontmatter. Please check the file is formatted correctly.
    ''',
    );
  }

  List<QuestionAnswerPair> get questionAnswerPairs {
    RegExp regex = RegExp(r'.* :: .*');
    Iterable<RegExpMatch> regexResult = regex.allMatches(fileContents);

    return regexResult.isNotEmpty
        ? regexResult
            .map((match) => _getQuestionAnswerPair(match.group(0)!))
            .toList()
        : throw ConversionException(
            message: '''
We couldn't detect any question-answer pairs. Please check the file is formatted correctly:

$title
        ''',
          );
  }

  QuestionAnswerPair _getQuestionAnswerPair(String flashcard) {
    RegExp regex = RegExp(r'^(.*?) :: (.*?)(?:\^(\d+))?$');

    String? question = regex.firstMatch(flashcard)?.group(1)!;
    String? answer = regex.firstMatch(flashcard)?.group(2)!;
    String? id = regex.firstMatch(flashcard)?.group(3);

    return QuestionAnswerPair(
      id: id != null ? int.parse(id) : null,
      question: question!,
      answer: answer!,
    );
  }

  Note copyWith({
    String? uri,
    String? fileContents,
  }) =>
      Note(
        uri: uri ?? this.uri,
        fileContents: fileContents ?? this.fileContents,
      );

  @override
  List<Object?> get props => [
        uri,
        fileContents,
      ];
}
