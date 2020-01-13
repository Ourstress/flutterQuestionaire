import 'package:flutter/material.dart';
import 'forms.dart';
import 'config.dart';
import 'dataClasses.dart';

class ResponsesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Responses')),
        body: SingleChildScrollView(
            padding: EdgeInsets.all(config['outermostPadding']),
            child: ResponseChartSettings()));
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
