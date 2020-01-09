import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dataClasses.dart';

// Todo: proxy data provider on connection to Firestore
class DataProvider with ChangeNotifier {
  final String responseBody = """[{"title":"hello", "desc":"hello world"},
    {"title":"hello2", "desc":"hello world 2"}]""";

  parseJson() => json.decode(responseBody).cast<Map<String, dynamic>>();
  List<QuizInfo> parseQuizzes() =>
      parseJson().map<QuizInfo>((json) => QuizInfo.fromJson(json)).toList();

  List<QuizInfo> get getQuizzes => parseQuizzes();
}
