import 'package:flutter/foundation.dart';
import 'dataClasses.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:firebase/firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Fa with ChangeNotifier {
  fb.Auth fbAuth = fb.auth();
  fb.User user;
  bool isAdmin = false;

  Fa() {
    fbAuth.onAuthStateChanged.listen((e) {
      user = e;
      adminUserCheck(user);
      notifyListeners();
    });
  }

  adminUserCheck(user) => isAdmin = user != null ? true : false;
}

class Fs with ChangeNotifier {
  Firestore store = fb.firestore();

  CollectionReference quizRef() => store.collection('quiz');
  CollectionReference quizQnRef() => store.collection('questions');

  Stream<List<QuizInfo>> streamQuizzes() => quizRef().onSnapshot.map(
      (list) => list.docs.map((doc) => QuizInfo.fromFirestore(doc)).toList());

  Stream<List<QuizQuestion>> streamQuizQuestion(quizId) => quizQnRef()
      .where('quiz', 'array-contains', quizId)
      .onSnapshot
      .map((list) =>
          list.docs.map((doc) => QuizQuestion.fromFirestore(doc)).toList());

  Future updateQuizResponse(
      {QuizData quizData, QuizSubmitDataInput quizInput}) {
    Map<String, dynamic> updatedResponse = {
      'responseList.${quizInput.email.replaceAll('.', '%2E')}': {
        'results': {
          'collatedScores': quizData.collatedScores,
          'questionScores': quizData.questionScores,
          'outcome': quizData.tabulateScores().outcome
        },
        'gender': quizInput.gender,
        'createdAt': FieldValue.serverTimestamp()
      }
    };
    return quizRef().doc(quizData.quizInfo.id).update(data: updatedResponse);
  }
}

class ProvideFs extends StatelessWidget {
  final Widget childWidget;

  const ProvideFs({Key key, this.childWidget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var contextFirestore = Provider.of<Fs>(context, listen: false);
    return ChangeNotifierProvider.value(
        value: contextFirestore, child: childWidget);
  }
}

Future showDialogWithFS({BuildContext context, Widget childWidget}) {
  var contextFirestore = Provider.of<Fs>(context, listen: false);
  return showDialog(
      context: context,
      child: ChangeNotifierProvider.value(
          value: contextFirestore, child: childWidget));
}
