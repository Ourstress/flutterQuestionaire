import 'package:flutter/material.dart';
import 'config.dart';
import 'package:provider/provider.dart';
import 'notifiers.dart';
import 'dataClasses.dart';
import 'package:firebase/firebase.dart' as fb;
import 'secrets.dart';
import 'quiz.dart';

void main() {
  if (fb.apps.length == 0) {
    fb.initializeApp(
        apiKey: secrets['apiKey'],
        authDomain: secrets['authDomain'],
        databaseURL: secrets['databaseURL'],
        projectId: secrets['projectId'],
        storageBucket: secrets['storageBucket'],
        messagingSenderId: secrets['messagingSenderId'],
        appId: secrets['appId'],
        measurementId: secrets['measurementId']);
  }
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'IS3013 app',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        home: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (context) => Fs()),
            ],
            // reference for streamProvider https://github.com/fireship-io/185-advanced-flutter-firestore/blob/master/lib/main.dart
            child: StreamProvider<List<QuizInfo>>(
                create: (context) =>
                    Provider.of<Fs>(context, listen: false).streamQuizzes(),
                initialData: [],
                child: MyHomePage())));
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IS3103 App'),
      ),
      body: DisplayCards(),
    );
  }
}

class DisplayCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(12.0),
        child: Wrap(
          spacing: config['wrapCardSpacing'],
          runSpacing: config['wrapCardRunSpacing'],
          children: generateCards(Provider.of<List<QuizInfo>>(context)),
        ));
  }
}

List<Widget> generateCards(quizzes) {
  // solve flutter flow-control-collections needed - https://stackoverflow.com/questions/59458433/flutter-flow-control-collections-are-needed-but-are-they
  return <Widget>[
    for (QuizInfo quizData in quizzes) CardContainer(cardData: quizData)
  ];
}

class CardContainer extends StatelessWidget {
  final QuizInfo cardData;

  const CardContainer({Key key, this.cardData}) : super(key: key);

  // constrainedBox makes a good combo with Card with Row as child that would auto-expand to fit constraints
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: config['cardContainerMaxWidth'],
            minHeight: config['cardContainerMinHeight']),
        child: Card(
            child: Row(
          children: <Widget>[CardContents(cardData: cardData)],
        )));
  }
}

class CardContents extends StatelessWidget {
  final QuizInfo cardData;

  const CardContents({Key key, this.cardData}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ListTile(
      title: Text(cardData.title),
      onTap: () => openQuiz(context),
    ));
  }
}

void openQuiz(context) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => Quiz()));
}
