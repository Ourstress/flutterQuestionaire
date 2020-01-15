import 'package:firebase/firestore.dart';
import 'package:queries/collections.dart';
import 'config.dart';

class ChartLogic {
  final QuizInfo quizInfo;

  ChartLogic({this.quizInfo});

  Collection<Response> responseCollection() =>
      Collection(<Response>[...quizInfo.responseList.responses]);

  Map<String, List<Response>> groupByAttribute(query) {
    var result = <String, List<Response>>{};
    for (var group in query.asIterable()) {
      result[group.key] = <Response>[];
      for (var child in group.asIterable()) {
        result[group.key].add(child);
      }
    }
    return result;
  }

  Map<String, List<Response>> groupByGender() {
    var query = responseCollection().groupBy((response) => response.gender);
    return groupByAttribute(query);
  }

  Map<String, List<Response>> groupByOutcome() {
    var query =
        responseCollection().groupBy((response) => response.results.outcome);
    return groupByAttribute(query);
  }

  List<ChartCoordinates> chartCoordsByOutcome() => groupByOutcome()
      .entries
      .map((entry) =>
          ChartCoordinates(label: entry.key, number: entry.value.length))
      .toList();
}

class ChartCoordinates {
  final String label;
  final int number;

  ChartCoordinates({this.label, this.number});
}

class SelectedChartSettings {
  String gender = 'all';
  String semester = 'all';
  String measure = 'count';
}

class QuizSubmitDataInput {
  String email = '';
  String gender = 'female';
}

class QuizData extends QuizLogic {
  final Map collatedScores;
  final QuizInfo quizInfo;

  QuizData({this.collatedScores, this.quizInfo})
      : super(collatedScores: collatedScores);
}

class QuizLogic {
  final Map collatedScores;

  QuizLogic({this.collatedScores});

  TabulatedScore tabulateScores() {
    List<QuizQnScore> _quizQnList = [];
    for (MapEntry qnAnswers in collatedScores.entries) {
      _quizQnList.add(QuizQnScore.fromMapEntry(qnAnswers));
    }
    Map tabulatedScores = _addScores(scores: _quizQnList);
    String quizOutcome = _findOutcome(tabulatedScores: tabulatedScores);
    return TabulatedScore(
        tabulatedScores: tabulatedScores, outcome: quizOutcome);
  }

  String _findOutcome({Map tabulatedScores}) {
    if (tabulatedScores.containsKey('totalScore') &&
        tabulatedScores.length == 1)
      return config['no-type-quiz-identifier'];
    else
      return _findOutcomeByType(tabulatedScores: tabulatedScores);
  }

  String _findOutcomeByType({Map tabulatedScores}) {
    int _highestScore = 0;
    String _outcome = '';
    for (String outcomeType in tabulatedScores.keys) {
      if (tabulatedScores[outcomeType] > _highestScore) {
        _outcome = outcomeType;
        _highestScore = tabulatedScores[outcomeType];
      } else if (tabulatedScores[outcomeType] == _highestScore) {
        _outcome += ' / ' + outcomeType;
      }
    }
    return _outcome;
  }

  Map _addScores({List<QuizQnScore> scores}) {
    var scoreCollection = Collection(<QuizQnScore>[...scores]);
    var scoreTypeFilter =
        scoreCollection.where((score) => score.type != '').toList();

    // below we check if all the questions in a quiz don't have specified type
    if (scoreTypeFilter.isEmpty)
      return _tabulateScoresWithoutType(scores: scores);
    else
      return _tabulateScoresByType(scores: scores);
  }

  Map _tabulateScoresWithoutType({List<QuizQnScore> scores}) {
    double totalScore = 0;
    scores.forEach((quizQnScore) => totalScore += quizQnScore.score);
    return {config['no-type-quiz-identifier']: totalScore};
  }

  Map _tabulateScoresByType({List<QuizQnScore> scores}) {
    Map tabulatedScores = {};
    scores.forEach((quizQnScore) {
      if (!tabulatedScores.containsKey(quizQnScore.type)) {
        tabulatedScores[quizQnScore.type] = 0;
      }
      tabulatedScores[quizQnScore.type] += quizQnScore.score;
    });
    return tabulatedScores;
  }
}

class TabulatedScore {
  final Map tabulatedScores;
  final String outcome;

  TabulatedScore({this.tabulatedScores, this.outcome});
}

class QuizQnScore {
  final String title;
  final String type;
  final int score;

  QuizQnScore({this.title, this.type, this.score});

  factory QuizQnScore.fromMapEntry(MapEntry quizQnScore) {
    String qnTitle = quizQnScore.key;
    Map qnValues = quizQnScore.value;
    return QuizQnScore(
      title: qnTitle ?? '',
      type: qnValues['type'] ?? '',
      score: qnValues['score'] ?? 0,
    );
  }
}

class QuizQuestion {
  final String id;
  final List quiz;
  final String scales;
  final String title;
  final String type;

  List<QuizQnScale> get getQuizScales {
    return scales.split(',').map((String scale) {
      // Firefox doesn't recognise named groups, switched to unnamed group - https://stackoverflow.com/questions/55774080/firefox-gives-syntaxerror-invalid-regexp-group
      RegExp pattern = RegExp(r"(\d+) - (.*)");
      RegExpMatch matches = pattern.firstMatch(scale);
      int value = int.parse(matches.group(1));
      String label = matches.group(2);
      return QuizQnScale(value, label);
    }).toList();
  }

  QuizQuestion({this.id, this.quiz, this.scales, this.title, this.type});

  factory QuizQuestion.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();

    return QuizQuestion(
      id: doc.id ?? '',
      quiz: data['quiz'] ?? [],
      title: data['title'] ?? '',
      scales: data['scales'] ??
          '1 - Strongly disagree, 2 - Disagree, 3 - Neutral, 4 - Agree, 5 - Strongly agree',
      type: data['type'] ?? '',
    );
  }
}

class QuizQnScale {
  final int value;
  final String label;

  QuizQnScale(this.value, this.label);
}

class QuizInfo {
  final String id;
  final String title;
  final String desc;
  final String instructions;
  final String resultsExplanation;
  final ResponseList responseList;
  final bool isPublic;

  QuizInfo(
      {this.id,
      this.title,
      this.desc,
      this.instructions,
      this.resultsExplanation,
      this.responseList,
      this.isPublic});

  factory QuizInfo.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();

    return QuizInfo(
        id: doc.id ?? '',
        title: data['title'] ?? '',
        desc: data['desc'] ?? '',
        instructions: data['instructions'] ?? '',
        resultsExplanation: data['resultsExplanation'] ?? '',
        responseList: ResponseList.fromFirestore(data['responseList']) ?? [],
        isPublic: data['isPublic'] ?? false);
  }
}

class ResponseList {
  final List<Response> responses;

  ResponseList({this.responses});

  factory ResponseList.fromFirestore(Map responsesMap) {
    return ResponseList(responses: [
      for (MapEntry responseMapEntry in responsesMap.entries)
        Response.fromFirestore(responseMapEntry)
    ]);
  }
}

class Response {
  final DateTime createdAt;
  final String gender;
  final Results results;
  final String email;

  Response({this.createdAt, this.gender, this.results, this.email});

  factory Response.fromFirestore(MapEntry responseMapEntry) {
    return Response(
        createdAt: responseMapEntry.value['createdAt'] ?? DateTime.now(),
        gender: responseMapEntry.value['gender'] ?? '',
        email: responseMapEntry.key ?? '',
        results: Results.fromFirestore(responseMapEntry.value['results']) ??
            Results(outcome: '', collatedScores: {}, questionScores: {}));
  }
}

class Results {
  final String outcome;
  final Map collatedScores;
  final Map questionScores;

  Results({this.outcome, this.collatedScores, this.questionScores});

  factory Results.fromFirestore(Map firestoreResults) {
    return Results(
        outcome: firestoreResults['outcome'] ?? '',
        collatedScores: firestoreResults['collatedScores'] ?? {},
        questionScores: firestoreResults['questionScores'] ?? {});
  }
}
