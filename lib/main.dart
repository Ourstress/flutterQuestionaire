import 'package:flutter/material.dart';
import 'config.dart';
import 'package:provider/provider.dart';
import 'notifiers.dart';
import 'dataClasses.dart';
import 'package:firebase/firebase.dart' as fb;
import 'responses.dart';
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
              ChangeNotifierProvider(create: (context) => Fa()),
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
          title: Text(config['appName']),
          actions: <Widget>[AdminSignInButton()]),
      body: DisplayCards(),
    );
  }
}

class AdminSignInButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text(
        'Site\n Admin',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () async {
        fb.Auth fbAuth = Provider.of<Fa>(context, listen: false).fbAuth;
        var provider = fb.GoogleAuthProvider();
        try {
          await fbAuth.signInWithPopup(provider);
        } catch (e) {
          print("Error in sign in with google: $e");
        }
      },
    );
  }
}

class DisplayCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(config['outermostPadding']),
        child: Wrap(
          spacing: config['wrapCardSpacing'],
          runSpacing: config['wrapCardRunSpacing'],
          children: generateCards(
              context: context, quizzes: Provider.of<List<QuizInfo>>(context)),
        ));
  }
}

List<Widget> generateCards({BuildContext context, List<QuizInfo> quizzes}) {
  // solve flutter flow-control-collections needed - https://stackoverflow.com/questions/59458433/flutter-flow-control-collections-are-needed-but-are-they
  return <Widget>[
    for (QuizInfo quizData in quizzes)
      Provider.of<Fa>(context).isAdmin || quizData.isPublic
          ? CardContainer(cardData: quizData)
          : SizedBox()
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
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CardContents(cardData: cardData),
            AdminControls(cardData: cardData)
          ],
        )));
  }
}

class AdminControls extends StatelessWidget {
  final QuizInfo cardData;

  const AdminControls({Key key, this.cardData}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Provider.of<Fa>(context).isAdmin
        ? Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            OpenResponsesTile(cardData: cardData),
            ToggleSwitch(cardData: cardData),
          ])
        : SizedBox();
  }
}

class OpenResponsesTile extends StatelessWidget {
  final QuizInfo cardData;

  const OpenResponsesTile({Key key, this.cardData}) : super(key: key);

  void openResponsesPage(BuildContext context) {
    var contextFirestore = Provider.of<Fs>(context, listen: false);
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return MultiProvider(providers: [
        ChangeNotifierProvider.value(value: contextFirestore),
        StreamProvider<List<QuizQuestion>>(
            create: (context) => Provider.of<Fs>(context, listen: false)
                .streamQuizQuestion(cardData.id),
            initialData: [])
      ], child: ResponsesPage(quizInfo: cardData));
    }));
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: Icon(Icons.insert_chart),
        title: Text(config['viewResponsesText']),
        trailing: IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: () => openResponsesPage(context),
        ),
        onTap: () => openResponsesPage(context));
  }
}

class ToggleSwitch extends StatefulWidget {
  final QuizInfo cardData;

  const ToggleSwitch({Key key, this.cardData}) : super(key: key);

  @override
  _ToggleSwitchState createState() => _ToggleSwitchState();
}

class _ToggleSwitchState extends State<ToggleSwitch> {
  bool _switchState;

  void initState() {
    _switchState = widget.cardData.isPublic;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
        child: SwitchListTile(
      title: Text(config['isPublicText']),
      value: _switchState,
      onChanged: (bool value) {
        Provider.of<Fs>(context, listen: false)
            .toggleQuizIsPublic(cardData: widget.cardData);
        setState(() {
          _switchState = value;
        });
      },
      secondary: Icon(Icons.public),
    ));
  }
}

class CardContents extends StatelessWidget {
  final QuizInfo cardData;

  const CardContents({Key key, this.cardData}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Flexible(
        child: ListTile(
      title: Text(cardData.title,
          style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: config['normalFontSize'])),
      onTap: () => openQuiz(context, cardData),
    ));
  }
}

void openQuiz(context, QuizInfo cardData) {
  var contextFirestore = Provider.of<Fs>(context, listen: false);
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider.value(value: contextFirestore),
      StreamProvider<List<QuizQuestion>>(
          create: (context) => Provider.of<Fs>(context, listen: false)
              .streamQuizQuestion(cardData.id),
          initialData: [])
    ], child: Quiz(quizInfo: cardData));
  }));
}
