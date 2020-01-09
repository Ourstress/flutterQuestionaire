import 'package:flutter/foundation.dart';

// Todo: proxy data provider on connection to Firestore
class DataProvider with ChangeNotifier {
  List<String> quizzesData = [
    "{'title':'hello', 'desc':'hello world'}",
    "{'title':'hello2', 'desc':'hello world 2'}"
  ];

  List<String> get getQuizzes => quizzesData;
}
