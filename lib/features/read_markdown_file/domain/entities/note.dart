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
    RegExp regex = RegExp(r'tags: \[(.*)\]');
    String? regexResult = regex.firstMatch(fileContents)?.group(1)!;

    if (regexResult != null) {
      List<String> trimmedTags =
          regexResult.split(',').map((e) => e.trim()).toList();

      return regexResult.isEmpty ? [] : trimmedTags;
    } else {
      throw ConversionException(
        message: '''
We couldn't detect any tags. Please check the file is formatted correctly:

$title
        ''',
      );
    }
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
