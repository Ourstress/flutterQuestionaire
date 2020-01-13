import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dataClasses.dart';
import 'config.dart';
import 'package:provider/provider.dart';
import 'notifiers.dart';

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
    return ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: config['cardContainerMaxWidth'],
        ),
        child: Form(
            key: submitQuizFormKey,
            child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              Flexible(
                  child: TextFormInput(
                setter: (value) => quizInput.email = value,
                labelText: config['inputEmailLabel'],
                hintText: config['emailHintText'],
                wrongInputMsg: config['incorrectInputEmailMsg'],
                regex: config['checkEmailRegex'],
              )),
              Flexible(
                  child: SelectDropdown(
                      dropdownValue: () => quizInput.gender,
                      setter: (value) => quizInput.gender = value,
                      labelText: config['inputGenderLabel'],
                      dropdownOptions: config['genderDropdownOptions'])),
              Flexible(
                  child: ProvideFs(
                      childWidget: SubmitQuizButton(
                          submitQuizFormKey: submitQuizFormKey,
                          quizData: widget.quizData,
                          quizInput: quizInput)))
            ]))));
  }
}

class TextFormInput extends StatelessWidget {
  final Function setter;
  final String labelText;
  final String hintText;
  final String wrongInputMsg;
  final String regex;

  const TextFormInput(
      {Key key,
      this.setter,
      this.labelText,
      this.hintText,
      this.wrongInputMsg,
      this.regex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onSaved: (String value) => setter(value),
      decoration: InputDecoration(
          labelText: labelText, hintText: hintText, errorMaxLines: 2),
      validator: (value) {
        RegExp pattern = RegExp(regex);
        if (value.isEmpty || !pattern.hasMatch(value)) {
          return wrongInputMsg;
        }
        return null;
      },
    );
  }
}

class SelectDropdown extends StatelessWidget {
  final Function dropdownValue;
  final Function setter;
  final String labelText;
  final List<String> dropdownOptions;

  SelectDropdown(
      {Key key,
      this.dropdownValue,
      this.setter,
      this.labelText,
      this.dropdownOptions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: dropdownValue(),
      decoration: InputDecoration(
        labelText: labelText,
      ),
      isExpanded: true,
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      onChanged: (String newValue) => setter(newValue),
      items: dropdownOptions.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
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
            Provider.of<Fs>(context, listen: false)
                .updateQuizResponse(quizData: quizData, quizInput: quizInput);
            Navigator.of(context).pop();
            showDialog(
                context: context,
                child:
                    AlertDialog(content: DisplayResults(quizData: quizData)));
          }
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
            fontSize: config['normalFontSize']),
        ResultDisplayText(
            displayText: 'Your Scores',
            padding: config['outermostPadding'],
            fontWeight: FontWeight.w600,
            fontSize: config['normalFontSize']),
        DataTable(
          columns: [
            DataColumn(
                label: DataTableText(
                    displayText: config['resultTableCategoryKey'])),
            DataColumn(
                label: DataTableText(
                    displayText: config['resultTableCategoryValue'])),
          ],
          rows: [
            for (MapEntry scoresMapEntry in _quizScores.tabulatedScores.entries)
              DataRow(cells: [
                DataCell(DataTableText(displayText: scoresMapEntry.key)),
                DataCell(
                    DataTableText(displayText: scoresMapEntry.value.toString()))
              ])
          ],
        )
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

class DataTableText extends StatelessWidget {
  final String displayText;

  const DataTableText({Key key, this.displayText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(displayText,
        style: TextStyle(fontSize: config['normalFontSize']));
  }
}
