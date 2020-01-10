import 'package:flutter/material.dart';
import 'dataClasses.dart';
import 'config.dart';
import 'package:provider/provider.dart';

class Quiz extends StatefulWidget {
  final QuizInfo quizInfo;

  const Quiz({Key key, this.quizInfo}) : super(key: key);
  @override
  QuizState createState() => QuizState();
}

class QuizState extends State<Quiz> with AutomaticKeepAliveClientMixin {
  Map _scores = {};

  void updateQuizScore({String question, String questionType, int value}) {
    if (!_scores.containsKey(question)) {
      _scores[question] = {};
      _scores[question]['type'] = questionType;
    }
    _scores[question]['score'] = value;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print(Provider.of<List<QuizQuestion>>(context));
    List<QuizQuestion> questions = Provider.of<List<QuizQuestion>>(context);
    return Scaffold(
        appBar: AppBar(title: Text('Quiz')),
        body: ListView(
            padding: EdgeInsets.all(config['outermostPadding']),
            children: <Widget>[
              for (QuizQuestion question in questions)
                Card(
                    margin: EdgeInsets.all(config['outermostPadding']),
                    child: QuizQnTile(
                        quizQn: question,
                        index: 1,
                        updateQuizScore: updateQuizScore)),
              // use Align to prevent RaisedButton from being max width https://stackoverflow.com/questions/55580066/how-can-you-reduce-the-width-of-a-raisedbutton-inside-a-listview-builder
              Align(
                  child: RaisedButton(
                onPressed: () {},
                child: Text('Submit'),
              )),
            ]));
  }

  @override
  bool get wantKeepAlive => true;
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
