import 'package:flutter/material.dart';
import 'dataClasses.dart';
import 'config.dart';
import 'package:provider/provider.dart';
import 'forms.dart';
import 'notifiers.dart';

class Quiz extends StatefulWidget {
  final QuizInfo quizInfo;

  const Quiz({Key key, this.quizInfo}) : super(key: key);
  @override
  QuizState createState() => QuizState();
}

class QuizState extends State<Quiz> with AutomaticKeepAliveClientMixin {
  QuizData quizData;

  void initState() {
    quizData = QuizData(
        collatedScores: {}, questionScores: {}, quizInfo: widget.quizInfo);
    super.initState();
  }

  void updateQuizScore({String question, String questionType, int value}) {
    if (!quizData.collatedScores.containsKey(question)) {
      quizData.collatedScores[question] = {};
      quizData.collatedScores[question]['type'] = questionType;
    }
    quizData.collatedScores[question]['score'] = value;
    quizData.questionScores[question] = value;
  }

  void onSubmit(questions) {
    if (quizData.questionScores.length != questions.length)
      showAlert(
          context: context,
          alertMessage: 'Please answer all the questions before submitting');
    else
      showDialogWithFS(
          context: context,
          childWidget: AlertDialog(
              content: SubmitQuizForm(quizData: quizData),
              actions: [
                FlatButton(
                    child: const Text('EXIT'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ]));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // listening to provider in build method - see https://medium.com/flutter-community/flutter-statemanagement-with-provider-ee251bbc5ac1
    final List<QuizQuestion> questions =
        Provider.of<List<QuizQuestion>>(context);
    return Scaffold(
        appBar: AppBar(title: Text('Quiz')),
        body: QuestionList(
            questions: questions,
            scoreUpdater: updateQuizScore,
            onSubmit: () => onSubmit(questions)));
  }

  @override
  bool get wantKeepAlive => true;
}

Future showAlert({BuildContext context, String alertMessage}) {
  return showDialog(
      context: context,
      child: AlertDialog(title: Text(alertMessage), actions: [
        FlatButton(
            child: const Text('CLOSE'),
            onPressed: () => Navigator.of(context).pop()),
      ]));
}

class QuestionList extends StatelessWidget {
  final List<QuizQuestion> questions;
  final Function scoreUpdater;
  final Function onSubmit;

  const QuestionList(
      {Key key, this.questions, this.scoreUpdater, this.onSubmit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
        padding: EdgeInsets.all(config['outermostPadding']),
        children: <Widget>[
          // list items get an index through asMap() and iterate over mapEntries to get index
          for (MapEntry qnMapEntry in questions.asMap().entries)
            Card(
                margin: EdgeInsets.all(config['outermostPadding']),
                child: QuizQnTile(
                    quizQn: qnMapEntry.value,
                    index: qnMapEntry.key,
                    updateQuizScore: scoreUpdater)),
          // use Align to prevent RaisedButton from being max width https://stackoverflow.com/questions/55580066/how-can-you-reduce-the-width-of-a-raisedbutton-inside-a-listview-builder
          Align(
              child: RaisedButton(
            onPressed: () => onSubmit(),
            child: Text('Submit'),
          )),
        ]);
  }
}

class QuizQnTile extends StatefulWidget {
  final QuizQuestion quizQn;
  final int index;
  final Function updateQuizScore;
  const QuizQnTile({Key key, this.quizQn, this.index, this.updateQuizScore})
      : super(key: key);

  @override
  QuizQnTileState createState() => QuizQnTileState();
}

class QuizQnTileState extends State<QuizQnTile> {
  int radioGroupScore = -1;

  QuizQuestion quizQn() => widget.quizQn;

  void onSelectRadio(value) {
    setState(() {
      radioGroupScore = value;
    });
    widget.updateQuizScore(
        question: quizQn().title, questionType: quizQn().type, value: value);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text((widget.index + 1).toString() + '.  ' + quizQn().title),
        contentPadding: EdgeInsets.all(20.0),
        subtitle: Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.end,
                alignment: WrapAlignment.spaceEvenly,
                children: radioButtonBar(
                    quizQn: quizQn(),
                    radioGroupScore: radioGroupScore,
                    clickHandler: onSelectRadio))));
  }
}

List<Column> radioButtonBar(
    {QuizQuestion quizQn, int radioGroupScore, Function clickHandler}) {
  return [
    for (QuizQnScale scale in quizQn.getQuizScales)
      Column(children: <Widget>[
        RadioButtonText(title: scale.label),
        Radio(
            value: scale.value,
            groupValue: radioGroupScore,
            onChanged: clickHandler)
      ])
  ];
}

class RadioButtonText extends StatelessWidget {
  final String title;

  const RadioButtonText({Key key, this.title}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints(minWidth: 70.0),
        child: Text(
          title,
          textAlign: TextAlign.center,
        ));
  }
}
