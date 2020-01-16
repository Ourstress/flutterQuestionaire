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
  List<charts.Series<ChartCoordinates, String>> _chartData;

  void initState() {
    chartLogic = ChartLogic(quizInfo: widget.quizInfo);
    _chartData = chartLogic.createChartData(
        data: chartLogic.toggleChartSettings(setting: 'all'),
        context: context,
        selectedMeasure: 'count');
    super.initState();
  }

  void changeChartDisplay({String setting = 'all', String measure = 'count'}) {
    setState(() {
      _chartData = chartLogic.createChartData(
          data: chartLogic.toggleChartSettings(setting: setting),
          context: context,
          selectedMeasure: measure);
    });
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
                    changeChartDisplay(setting: 'gender');
                  }),
              ResponseChartSettings(changeChartDisplay: changeChartDisplay),
              ChartDisplay(coords: _chartData)
            ])));
  }
}

class ResponseChartSettings extends StatefulWidget {
  final Function changeChartDisplay;

  const ResponseChartSettings({Key key, this.changeChartDisplay})
      : super(key: key);

  @override
  _ResponseChartSettingsState createState() => _ResponseChartSettingsState();
}

class _ResponseChartSettingsState extends State<ResponseChartSettings> {
  SelectedChartSettings selectedSettings = SelectedChartSettings();

  void updateChartDisplay() => widget.changeChartDisplay(
      setting: selectedSettings.gender, measure: selectedSettings.measure);

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
                  setter: (value) {
                    setState(() {
                      selectedSettings.gender = value;
                    });
                    updateChartDisplay();
                  },
                  labelText: config['genderLabel'],
                  dropdownOptions: config['genderOptions'])),
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
                  setter: (value) {
                    setState(() {
                      selectedSettings.measure = value;
                    });
                    updateChartDisplay();
                  },
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
