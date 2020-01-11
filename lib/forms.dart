import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dataClasses.dart';

// Todos
// add placeholder eXXXXX@nus.edu
// check NUS email format
class EmailGenderForm extends StatefulWidget {
  final QuizData quizData;

  const EmailGenderForm({Key key, this.quizData}) : super(key: key);
  @override
  EmailGenderFormState createState() {
    return EmailGenderFormState();
  }
}

class EmailGenderFormState extends State<EmailGenderForm> {
  final _formKey = GlobalKey<FormState>();
  String _gender = 'Female';
  String _email = '';
  String _displayResults;

  void initState() {
    _displayResults = widget.quizData.tabulateScores().outcome;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_displayResults);
  }
}
