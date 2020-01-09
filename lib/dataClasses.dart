class QuizInfo {
  final String title;
  final String desc;
  // final ResponseList responseList;

  QuizInfo(this.title, this.desc); //, this.responseList);

  QuizInfo.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        desc = json['desc'];

  Map<String, dynamic> toJson() => {
        'title': title,
        'desc': desc,
      };
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
