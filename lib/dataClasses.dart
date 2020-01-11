import 'package:firebase/firestore.dart';

class QuizData extends QuizLogic {
  final Map collatedScores;
  final Map questionScores;
  final QuizInfo quizInfo;

  QuizData({this.collatedScores, this.questionScores, this.quizInfo})
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
  // final ResponseList responseList;

  QuizInfo(
      {this.id,
      this.title,
      this.desc,
      this.instructions,
      this.resultsExplanation}); //, this.responseList);

  factory QuizInfo.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();

    return QuizInfo(
        id: doc.id ?? '',
        title: data['title'] ?? '',
        desc: data['desc'] ?? '',
        instructions: data['instructions'] ?? '',
        resultsExplanation: data['resultsExplanation'] ?? '');
  }
}

// class ResponseList {
//   final String email;
//   final List<Response> responses;

//   ResponseList(this.email, this.responses);
// }

// class Response {
//   final DateTime createdAt;
//   final String gender;
//   final Results results;

//   Response(this.createdAt, this.gender, this.results);
// }

// class Results {
//   final String outcome;
//   final Map collatedScores;
//   final Map questionScores;

//   Results(this.outcome, this.collatedScores, this.questionScores);
// }
