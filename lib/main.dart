import 'package:flutter/material.dart';
import 'config.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IS3013 app',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: MyHomePage(),
    );
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
        padding: EdgeInsets.all(16.0),
        child: Wrap(
          spacing: config['wrapCardSpacing'],
          runSpacing: config['wrapCardRunSpacing'],
          children: <Widget>[CardContainer()],
        ));
  }
}

class CardContainer extends StatelessWidget {
  // constrainedBox makes a good combo with Card with Row as child that would auto-expand to fit constraints
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: config['cardContainerMaxWidth'],
            minHeight: config['cardContainerMinHeight']),
        child: Card(
            child: Row(
          children: <Widget>[CardContents()],
        )));
  }
}

class CardContents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(child: ListTile(title: Text('hi')));
  }
}
