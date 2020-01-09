import 'package:flutter/foundation.dart';
import 'dataClasses.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:firebase/firestore.dart';

class Fs with ChangeNotifier {
  Firestore store = fb.firestore();
  Firestore get getStore => store;

  CollectionReference quizRef() => getStore.collection('quiz');

  Stream<List<QuizInfo>> streamQuizzes() => quizRef().onSnapshot.map(
      (list) => list.docs.map((doc) => QuizInfo.fromFirestore(doc)).toList());
}
