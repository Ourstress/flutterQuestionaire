import 'package:firebase/firestore.dart';

class QuizQuestion {
  final List<String> quiz;
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

  QuizQuestion(this.quiz, this.scales, this.title, this.type);
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
  // final ResponseList responseList;

  QuizInfo({this.id, this.title, this.desc}); //, this.responseList);

  factory QuizInfo.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();

    return QuizInfo(
      id: doc.id ?? '',
      title: data['title'] ?? '',
      desc: data['desc'] ?? '',
    );
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
