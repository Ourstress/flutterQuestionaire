import 'package:flutter/material.dart';
import 'dataClasses.dart';

class Quiz extends StatefulWidget {
  @override
  QuizState createState() => QuizState();
}

class QuizState extends State<Quiz> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    QuizQuestion question = QuizQuestion([],
        '1 - Strongly disagree, 2 - Disagree, 3 - Neutral, 4 - Agree, 5 - Strongly agree',
        'hello',
        'hey');
    return Card(child: QuizQnTile(quizQn: question, index: 1));
  }

  @override
  bool get wantKeepAlive => true;
}

class QuizQnTile extends StatefulWidget {
  final QuizQuestion quizQn;
  final int index;
  const QuizQnTile({Key key, this.quizQn, this.index}) : super(key: key);

  @override
  QuizQnTileState createState() => QuizQnTileState();
}

class QuizQnTileState extends State<QuizQnTile> {
  int radioGroupScore = -1;
  void onSelectRadio(value) => setState(() {
        radioGroupScore = value;
      });
  @override
  Widget build(BuildContext context) {
    QuizQuestion quizQn = widget.quizQn;
    return ListTile(
        title: Text((widget.index + 1).toString() + '.  ' + quizQn.title),
        contentPadding: EdgeInsets.all(20.0),
        subtitle: Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.end,
                alignment: WrapAlignment.spaceEvenly,
                children: radioButtonBar(
                    quizQn: quizQn,
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
