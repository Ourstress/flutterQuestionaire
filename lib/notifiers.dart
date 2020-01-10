import 'package:flutter/foundation.dart';
import 'dataClasses.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:firebase/firestore.dart';

class Fs with ChangeNotifier {
  Firestore store = fb.firestore();
  Firestore get getStore => store;

  CollectionReference quizRef() => getStore.collection('quiz');
  CollectionReference quizQnRef() => getStore.collection('questions');

  Stream<List<QuizInfo>> streamQuizzes() => quizRef().onSnapshot.map(
      (list) => list.docs.map((doc) => QuizInfo.fromFirestore(doc)).toList());

  Stream<List<QuizQuestion>> streamQuizQuestion(quizId) => quizQnRef()
      .where('quiz', 'array-contains', quizId)
      .onSnapshot
      .map((list) =>
          list.docs.map((doc) => QuizQuestion.fromFirestore(doc)).toList());
}
