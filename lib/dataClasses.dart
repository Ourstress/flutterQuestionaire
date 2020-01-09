import 'package:firebase/firestore.dart';

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
