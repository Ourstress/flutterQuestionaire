import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dataClasses.dart';
import 'config.dart';

// Todos
// add placeholder eXXXXX@nus.edu
// check NUS email format
class SubmitQuizForm extends StatefulWidget {
  final QuizData quizData;

  const SubmitQuizForm({Key key, this.quizData}) : super(key: key);
  @override
  SubmitQuizFormState createState() {
    return SubmitQuizFormState();
  }
}

class SubmitQuizFormState extends State<SubmitQuizForm> {
  final _formKey = GlobalKey<FormState>();
  String _gender = 'Female';
  String _email = '';

  @override
  Widget build(BuildContext context) {
    return DisplayResults(quizData: widget.quizData);
  }
}

class DisplayResults extends StatelessWidget {
  final QuizData quizData;

  const DisplayResults({Key key, this.quizData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    QuizInfo _quizDataInfo = quizData.quizInfo;
    TabulatedScore _quizScores = quizData.tabulateScores();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ResultDisplayText(
            displayText: _quizDataInfo.title,
            padding: config['outermostPadding'],
            fontWeight: FontWeight.w600,
            fontSize: config['normalFontSize']),
        ResultDisplayText(
            displayText: _quizScores.outcome,
            padding: config['emphasisTextPadding'],
            fontWeight: FontWeight.w700,
            fontSize: config['quizResultsFontSize']),
        ResultDisplayText(
            // use .replaceAll("\\n", "\n") to show line breaks denoted by \n in Firebase
            displayText:
                _quizDataInfo.resultsExplanation.replaceAll("\\n", "\n"),
            padding: config['outermostPadding'],
            fontWeight: FontWeight.w300,
            fontSize: config['normalFontSize'])
      ],
    );
  }
}

class ResultDisplayText extends StatelessWidget {
  final String displayText;
  final double padding;
  final double fontSize;
  final FontWeight fontWeight;

  const ResultDisplayText(
      {Key key, this.displayText, this.padding, this.fontSize, this.fontWeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: config['cardContainerMaxWidth'],
        ),
        child: Padding(
            padding: EdgeInsets.all(padding),
            child: Text(displayText,
                style: TextStyle(fontWeight: fontWeight, fontSize: fontSize))));
  }
}
