import 'package:flutter/material.dart';
import 'forms.dart';
import 'config.dart';
import 'dataClasses.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:provider/provider.dart';

class ResponsesPage extends StatefulWidget {
  final QuizInfo quizInfo;

  const ResponsesPage({Key key, this.quizInfo}) : super(key: key);

  @override
  _ResponsesPageState createState() => _ResponsesPageState();
}

class _ResponsesPageState extends State<ResponsesPage> {
  ChartLogic chartLogic;
  List<charts.Series<ChartCoordinates, String>> _chartData;

  void didChangeDependencies() {
    chartLogic = ChartLogic(quizInfo: widget.quizInfo);
    _chartData = chartLogic.createChartData(
      data: chartLogic.toggleChartSettings(
          setting: 'all',
          semester: 'all',
          selectedMeasure: 'count',
          quizQns: Provider.of<List<QuizQuestion>>(context, listen: false)),
      context: context,
      selectedMeasure: 'count',
    );
    super.didChangeDependencies();
  }

  void changeChartDisplay(
      {String setting = 'all',
      String measure = 'count',
      String semester = 'all'}) {
    setState(() {
      _chartData = chartLogic.createChartData(
          data: chartLogic.toggleChartSettings(
              setting: setting,
              semester: semester,
              selectedMeasure: measure,
              quizQns: Provider.of<List<QuizQuestion>>(context, listen: false)),
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
            child: widget.quizInfo.responseList.responses.isNotEmpty
                ? Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    ResultDisplayText(
                        displayText: chartLogic.quizInfo.title,
                        padding: config['outermostPadding'],
                        fontWeight: FontWeight.w300,
                        fontSize: config['normalFontSize']),
                    ResponseChartSettings(
                        changeChartDisplay: changeChartDisplay,
                        semesterOptions: chartLogic.semesterOptions()),
                    ChartDisplay(coords: _chartData)
                  ])
                : Text('No data to display')));
  }
}

class ResponseChartSettings extends StatefulWidget {
  final Function changeChartDisplay;
  final List<String> semesterOptions;

  const ResponseChartSettings(
      {Key key, this.changeChartDisplay, this.semesterOptions})
      : super(key: key);

  @override
  _ResponseChartSettingsState createState() => _ResponseChartSettingsState();
}

class _ResponseChartSettingsState extends State<ResponseChartSettings> {
  SelectedChartSettings selectedSettings = SelectedChartSettings();

  void updateChartDisplay() => widget.changeChartDisplay(
      setting: selectedSettings.gender,
      measure: selectedSettings.measure,
      semester: selectedSettings.semester);

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
                  setter: (value) {
                    setState(() {
                      selectedSettings.semester = value;
                    });
                    updateChartDisplay();
                  },
                  labelText: config['semesterLabel'],
                  dropdownOptions: [...widget.semesterOptions, 'all'])),
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
    charts.TextStyleSpec normalFontStyle =
        charts.TextStyleSpec(fontSize: config['normalFontSize']);
    return Expanded(
        child: charts.BarChart(
      coords,
      // no need to supply any animation controller
      animate: true,
      behaviors: [
        charts.SeriesLegend(
            entryTextStyle: normalFontStyle, desiredMaxColumns: 3)
      ],
      domainAxis: charts.OrdinalAxisSpec(
          renderSpec: charts.SmallTickRendererSpec(
              labelStyle: normalFontStyle, labelRotation: 10)),
      barRendererDecorator: charts.BarLabelDecorator(
        labelPosition: charts.BarLabelPosition.outside,
        insideLabelStyleSpec: normalFontStyle,
        outsideLabelStyleSpec: normalFontStyle,
      ),
    ));
  }
}
