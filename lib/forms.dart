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
  final submitQuizFormKey = GlobalKey<FormState>();
  QuizSubmitDataInput quizInput = QuizSubmitDataInput();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: submitQuizFormKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Flexible(
              child: TextFormField(
            onSaved: (String value) => quizInput.setEmail = value,
            decoration: InputDecoration(
              labelText: config['inputEmailLabel'],
            ),
            validator: (value) {
              RegExp pattern = RegExp(config['checkEmailRegex']);
              if (value.isEmpty || !pattern.hasMatch(value)) {
                return config['incorrectInputEmailMsg'];
              }
              return null;
            },
          )),
          Flexible(
              child: DropdownButtonFormField<String>(
            value: quizInput.gender,
            decoration: InputDecoration(
              labelText: 'Please enter your gender',
            ),
            isExpanded: true,
            icon: Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            onChanged: (String newValue) {
              setState(() {
                quizInput.setGender = newValue;
              });
            },
            items: <String>['male', 'female']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          )),
          Flexible(
              child: SubmitQuizButton(
                  submitQuizFormKey: submitQuizFormKey,
                  quizData: widget.quizData,
                  quizInput: quizInput))
        ]));
    // return DisplayResults(quizData: widget.quizData);
  }
}

class SubmitQuizButton extends StatelessWidget {
  final GlobalKey<FormState> submitQuizFormKey;
  final QuizData quizData;
  final QuizSubmitDataInput quizInput;

  const SubmitQuizButton(
      {Key key, this.submitQuizFormKey, this.quizData, this.quizInput})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
        child: Text('Submit'),
        onPressed: () {
          if (submitQuizFormKey.currentState.validate()) {
            submitQuizFormKey.currentState.save();
          }
          print(quizData.tabulateScores().outcome);
        });
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
