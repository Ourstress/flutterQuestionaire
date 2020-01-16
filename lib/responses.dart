import 'package:flutter/material.dart';
import 'forms.dart';
import 'config.dart';
import 'dataClasses.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ResponsesPage extends StatefulWidget {
  final QuizInfo quizInfo;

  const ResponsesPage({Key key, this.quizInfo}) : super(key: key);

  @override
  _ResponsesPageState createState() => _ResponsesPageState();
}

class _ResponsesPageState extends State<ResponsesPage> {
  ChartLogic chartLogic;

  void initState() {
    chartLogic = ChartLogic(quizInfo: widget.quizInfo);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Responses')),
        body: Padding(
            padding: EdgeInsets.all(config['outermostPadding']),
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              // FlatButton is temporarily here
              FlatButton(
                  child: Text('hello'),
                  onPressed: () {
                    print(chartLogic.toggleChartSettings(setting: 'gender'));
                  }),
              ResponseChartSettings(),
              ChartDisplay(
                  coords: chartLogic.createChartData(
                      data: chartLogic.toggleChartSettings(setting: 'gender'),
                      context: context,
                      selectedMeasure: 'count'))
            ])));
  }
}

class ResponseChartSettings extends StatefulWidget {
  @override
  _ResponseChartSettingsState createState() => _ResponseChartSettingsState();
}

class _ResponseChartSettingsState extends State<ResponseChartSettings> {
  SelectedChartSettings selectedSettings = SelectedChartSettings();

  @override
  Widget build(BuildContext context) {
    return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: config['wrapSpacing'],
        children: <Widget>[
          SizedBox(
              width: config['dropdownWidth'],
              child: SelectDropdown(
                  dropdownValue: () => selectedSettings.gender,
                  setter: (value) => setState(() {
                        selectedSettings.gender = value;
                      }),
                  labelText: config['genderLabel'],
                  dropdownOptions: [
                    ...config['genderDropdownOptions'],
                    'all'
                  ])),
          SizedBox(
              width: config['dropdownWidth'],
              child: SelectDropdown(
                  dropdownValue: () => selectedSettings.semester,
                  setter: (value) => setState(() {
                        selectedSettings.semester = value;
                      }),
                  labelText: config['semesterLabel'],
                  dropdownOptions: ['dummy1', 'dummy2', 'all'])),
          SizedBox(
              width: config['dropdownWidth'],
              child: SelectDropdown(
                  dropdownValue: () => selectedSettings.measure,
                  setter: (value) => setState(() {
                        selectedSettings.measure = value;
                      }),
                  labelText: config['measureLabel'],
                  dropdownOptions: config['measureOptions']))
        ]);
  }
}

class ChartDisplay extends StatelessWidget {
  final List<charts.Series<ChartCoordinates, String>> coords;

  const ChartDisplay({Key key, this.coords}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: charts.BarChart(
      coords,
      animate: false,
    ));
  }
}
