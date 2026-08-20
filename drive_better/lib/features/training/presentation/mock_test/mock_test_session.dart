class MockTestSession {
  final int score;
  final int total;
  final int secondsTaken;
  final List<int?> answers;
  final List<MockTestQuestion> questions;
  final int correctCount;
  final int minorWrong;
  final int seriousWrong;

  const MockTestSession({
    required this.score,
    required this.total,
    required this.secondsTaken,
    required this.answers,
    required this.questions,
    required this.correctCount,
    required this.minorWrong,
    required this.seriousWrong,
  });
}

class MockTestAnswerOption {
  final String text;
  const MockTestAnswerOption({required this.text});
}

class MockTestQuestion {
  final String externalId;
  final String text;
  final List<MockTestAnswerOption> options;
  final int correctIndex;
  final String? explanation;
  final String? imageAsset;
  final String topicId;
  final bool isSerious;

  const MockTestQuestion({
    this.externalId = '',
    required this.text,
    required this.options,
    required this.correctIndex,
    this.explanation,
    this.imageAsset,
    required this.topicId,
    this.isSerious = false,
  });
}
