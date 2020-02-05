import 'package:firebase/firestore.dart';
import 'package:queries/collections.dart';
import 'config.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class ChartDataBase {
  // reference for working with collections https://github.com/mezoni/queries/blob/master/example/example.dart

  // eg after grouping by outcome, make map {outcome:[responses]}
  _queryToMap({IEnumerable query}) {
    var result = <String, List<Response>>{};
    for (var group in query.asIterable()) {
      result[group.key] = <Response>[];
      for (var child in group.asIterable()) {
        result[group.key].add(child);
      }
    }
    return result;
  }

  Map _keysToLowercase(Map mapForConversion) =>
      Map.fromEntries(mapForConversion.entries
          .map((entry) => MapEntry(entry.key.toLowerCase(), entry.value)));

  List<ChartCoordinates> coordsOfCounts(
      {Map<String, List<Response>> groupbyResult}) {
    return groupbyResult.entries.map((entry) {
      return ChartCoordinates(
          label: entry.key, values: {'count': entry.value.length});
    }).toList();
  }

  List<ChartCoordinates> coordsOfStats({Map<String, double> averageScores}) {
    return averageScores.entries.map((entry) {
      return ChartCoordinates(
          label: entry.key,
          values: {'average': double.parse(entry.value.toStringAsFixed(1))});
    }).toList();
  }

  Map<String, Map> collectionStats(
      {Collection collection, List<String> categories}) {
    Map<String, int> _totals = {};
    Map<String, double> _averages = {};

    categories.forEach(
        (category) => _totals[category] = collection.aggregate$1(0, (r, e) {
              Map scoresLowercase = _keysToLowercase(e.results.collatedScores);
              if (scoresLowercase.containsKey(category))
                return r + scoresLowercase[category];
              else
                return r + 0;
            }));

    _totals.forEach(
        (outcome, count) => _averages[outcome] = count / collection.length);

    return {'totals': _totals, 'averages': _averages};
  }

  Map<String, Map> collectionStatsByGender(
      {Collection collection,
      List<String> categories,
      Map<String, dynamic> genders}) {
    Map<String, Map<String, int>> _totals = {};
    Map<String, Map<String, double>> _averages = {};

    categories.forEach((category) {
      _totals[category] = {};
      genders['genderList'].forEach((gender) =>
          _totals[category][gender] = collection.aggregate$1(0, (r, e) {
            Map scoresLowercase = _keysToLowercase(e.results.collatedScores);
            if (scoresLowercase.containsKey(category) && e.gender == gender)
              return r + scoresLowercase[category];
            else
              return r + 0;
          }));
    });

    _totals.forEach((category, scoreByGender) {
      _averages[category] = {};
      scoreByGender.forEach((gender, totalScore) => _averages[category]
          [gender] = totalScore / genders['genderCount'][gender]);
    });

    return {'totals': _totals, 'averages': _averages};
  }

  // standardise keys to lowercase first then capitalise first letter
  String lowerThenCap(String s) {
    String intermediateString = s.toLowerCase();
    return intermediateString[0].toUpperCase() +
        intermediateString.substring(1);
  }

  IEnumerable _queryResponsesByOutcome({Collection collection}) =>
      collection.groupBy((response) => lowerThenCap(response.results.outcome));

  IEnumerable _queryResponsesByGender({Collection collection}) =>
      collection.groupBy((response) => response.gender);

  Map<String, List<Response>> groupResponsesByOutcome(
          {Collection collection}) =>
      _queryToMap(query: _queryResponsesByOutcome(collection: collection));

  Map<String, List<Response>> groupResponsesByGender({Collection collection}) =>
      _queryToMap(query: _queryResponsesByGender(collection: collection));

  List<String> listOfOutcomes({Collection collection}) =>
      groupResponsesByOutcome(collection: collection).keys.toList();

  Map<String, dynamic> listOfGenders({Collection collection}) {
    Map<String, dynamic> genderInfo = {};
    Map<String, List<Response>> dataByGender =
        groupResponsesByGender(collection: collection);
    genderInfo['genderList'] =
        groupResponsesByGender(collection: collection).keys.toList();
    genderInfo['genderCount'] = dataByGender.map((genderName, responseList) =>
        MapEntry(genderName, responseList.length));
    return genderInfo;
  }

  Map<String, Map> outcomeStats(
          {Collection collection, List<String> categories}) =>
      collectionStats(collection: collection, categories: categories);

  Map<String, List<ChartCoordinates>> chartCoordsByOutcome(
          {Collection collection, String chartName}) =>
      {
        chartName: coordsOfCounts(
            groupbyResult: groupResponsesByOutcome(collection: collection))
      };

  Map<String, List<ChartCoordinates>> chartCoordsByStats(
          {Collection collection, String chartName}) =>
      {
        chartName: coordsOfStats(
            averageScores: collectionStats(
                collection: collection,
                categories: listOfOutcomes(collection: collection))['averages'])
      };
}

class ChartLogic extends ChartDataBase {
  final QuizInfo quizInfo;

  ChartLogic({this.quizInfo});

  Collection<Response> _masterResponses() =>
      Collection(<Response>[...quizInfo.responseList.responses]);

  Map<String, List<Response>> groupBySemesters() {
    var query = _masterResponses().groupBy((response) => response.acadSem());
    return _queryToMap(query: query);
  }

  List<String> semesterOptions() => [...groupBySemesters().keys];

  Map<String, List<ChartCoordinates>> toggleChartSettings(
      {String setting, String semester, String selectedMeasure}) {
    Collection _collectionBySem() {
      if (semester == 'all')
        return _masterResponses();
      else
        return Collection([...groupBySemesters()[semester]]);
    }

    if (selectedMeasure == 'average' && setting != 'gender')
      return chartCoordsByStats(
          collection: _collectionBySem(), chartName: 'Average scores');

    if (selectedMeasure == 'average' && setting == 'gender')
      return coordsOfStatsByGender(selectedCollection: _collectionBySem());

    if (setting == 'gender')
      return coordsByOutcomeThenGender(selectedCollection: _collectionBySem());
    else
      return chartCoordsByOutcome(
          collection: _collectionBySem(), chartName: 'Preferred type');
  }

  List<charts.Series<ChartCoordinates, String>> createChartData(
      {Map<String, List<ChartCoordinates>> data,
      BuildContext context,
      String selectedMeasure}) {
    final _colorPalettes =
        charts.MaterialPalette.getOrderedPalettes(data.length);
    return [
      for (int i = 0; i < data.length; i++)
        charts.Series<ChartCoordinates, String>(
          id: data.keys.elementAt(i),
          domainFn: (ChartCoordinates results, _) => results.label,
          measureFn: (ChartCoordinates results, _) =>
              results.values[selectedMeasure],
          data: data.values.elementAt(i),
          labelAccessorFn: (ChartCoordinates results, _) =>
              '${results.values[selectedMeasure]}',
          colorFn: (ChartCoordinates results, _) =>
              _colorPalettes[i].shadeDefault,
        ),
    ];
  }

  Map<String, Map<String, List<Response>>> _groupByOutcomeThenGender(
          {Collection selectedCollection}) =>
      groupResponsesByOutcome(collection: selectedCollection).map((key, value) {
        return MapEntry(
            key,
            _queryToMap(
                query: Collection(<Response>[...value])
                    .groupBy((response) => response.gender)));
      });

  Map<String, List<ChartCoordinates>> coordsByOutcomeThenGender(
      {Collection selectedCollection}) {
    Map<String, List<ChartCoordinates>> chartsList = {};
    _groupByOutcomeThenGender(selectedCollection: selectedCollection)
        .forEach((outcome, outcomeGroupedByGender) {
      List<ChartCoordinates> outcomeCoordsByGender =
          coordsOfCounts(groupbyResult: outcomeGroupedByGender);
      chartsList[outcome] = outcomeCoordsByGender;
    });
    return chartsList;
  }

  Map<String, List<ChartCoordinates>> coordsOfStatsByGender(
      {Collection selectedCollection}) {
    Map<String, List<ChartCoordinates>> chartsList = {};
    collectionStatsByGender(
            collection: selectedCollection,
            categories: listOfOutcomes(collection: selectedCollection),
            genders: listOfGenders(collection: selectedCollection))['averages']
        .forEach((outcome, countGroupedByGender) {
      List<ChartCoordinates> outcomeCoordsByGender =
          coordsOfStats(averageScores: countGroupedByGender);
      chartsList[outcome] = outcomeCoordsByGender;
    });
    return chartsList;
  }
}

class ChartCoordinates {
  final String label;
  final Map values;

  ChartCoordinates({this.label, this.values});

  @override
  String toString() {
    return 'label:$label, values: $values';
  }
}

class SelectedChartSettings {
  String gender = 'all';
  String semester = 'all';
  String measure = 'count';
}

class QuizSubmitDataInput {
  String email = '';
  String gender = 'female';
}

class QuizData extends QuizLogic {
  final Map collatedScores;
  final QuizInfo quizInfo;

  QuizData({this.collatedScores, this.quizInfo})
      : super(collatedScores: collatedScores);

  Map<String, dynamic> toJson() => {
        'quizName': quizInfo.title,
        'quizOutcome': tabulateScores().outcome,
        'quizResults': tabulateScores().tabulatedScores,
        'quizExplanation': quizInfo.resultsExplanation
      };
}

class QuizLogic {
  final Map collatedScores;

  QuizLogic({this.collatedScores});

  TabulatedScore tabulateScores() {
    List<QuizQnScore> _quizQnList = [];
    for (MapEntry qnAnswers in collatedScores.entries) {
      _quizQnList.add(QuizQnScore.fromMapEntry(qnAnswers));
    }
    Map tabulatedScores = _addScores(scores: _quizQnList);
    String quizOutcome = _findOutcome(tabulatedScores: tabulatedScores);
    return TabulatedScore(
        tabulatedScores: tabulatedScores, outcome: quizOutcome);
  }

  String _findOutcome({Map tabulatedScores}) {
    if (tabulatedScores.containsKey('totalScore') &&
        tabulatedScores.length == 1)
      return config['no-type-quiz-identifier'];
    else
      return _findOutcomeByType(tabulatedScores: tabulatedScores);
  }

  String _findOutcomeByType({Map tabulatedScores}) {
    int _highestScore = 0;
    String _outcome = '';
    for (String outcomeType in tabulatedScores.keys) {
      if (tabulatedScores[outcomeType] > _highestScore) {
        _outcome = outcomeType;
        _highestScore = tabulatedScores[outcomeType];
      } else if (tabulatedScores[outcomeType] == _highestScore) {
        _outcome += ' / ' + outcomeType;
      }
    }
    return _outcome;
  }

  Map _addScores({List<QuizQnScore> scores}) {
    var scoreCollection = Collection(<QuizQnScore>[...scores]);
    var scoreTypeFilter =
        scoreCollection.where((score) => score.type != '').toList();

    // below we check if all the questions in a quiz don't have specified type
    if (scoreTypeFilter.isEmpty)
      return _tabulateScoresWithoutType(scores: scores);
    else
      return _tabulateScoresByType(scores: scores);
  }

  Map _tabulateScoresWithoutType({List<QuizQnScore> scores}) {
    double totalScore = 0;
    scores.forEach((quizQnScore) => totalScore += quizQnScore.score);
    return {config['no-type-quiz-identifier']: totalScore};
  }

  Map _tabulateScoresByType({List<QuizQnScore> scores}) {
    Map tabulatedScores = {};
    scores.forEach((quizQnScore) {
      if (!tabulatedScores.containsKey(quizQnScore.type)) {
        tabulatedScores[quizQnScore.type] = 0;
      }
      tabulatedScores[quizQnScore.type] += quizQnScore.score;
    });
    return tabulatedScores;
  }
}

class TabulatedScore {
  final Map tabulatedScores;
  final String outcome;

  TabulatedScore({this.tabulatedScores, this.outcome});
}

class QuizQnScore {
  final String title;
  final String type;
  final int score;

  QuizQnScore({this.title, this.type, this.score});

  factory QuizQnScore.fromMapEntry(MapEntry quizQnScore) {
    String qnTitle = quizQnScore.key;
    Map qnValues = quizQnScore.value;
    return QuizQnScore(
      title: qnTitle ?? '',
      type: qnValues['type'] ?? '',
      score: qnValues['score'] ?? 0,
    );
  }
}

class QuizQuestion {
  final String id;
  final List quiz;
  final String scales;
  final String title;
  final String type;

  List<QuizQnScale> get getQuizScales {
    return scales.split(',').map((String scale) {
      // Firefox doesn't recognise named groups, switched to unnamed group - https://stackoverflow.com/questions/55774080/firefox-gives-syntaxerror-invalid-regexp-group
      RegExp pattern = RegExp(r"(\d+) - (.*)");
      RegExpMatch matches = pattern.firstMatch(scale);
      int value = int.parse(matches.group(1));
      String label = matches.group(2);
      return QuizQnScale(value, label);
    }).toList();
  }

  QuizQuestion({this.id, this.quiz, this.scales, this.title, this.type});

  factory QuizQuestion.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();

    return QuizQuestion(
      id: doc.id ?? '',
      quiz: data['quiz'] ?? [],
      title: data['title'] ?? '',
      scales: data['scale'] ??
          '1 - Strongly disagree, 2 - Disagree, 3 - Neutral, 4 - Agree, 5 - Strongly agree',
      type: data['type'] ?? '',
    );
  }
}

class QuizQnScale {
  final int value;
  final String label;

  QuizQnScale(this.value, this.label);
}

class QuizInfo {
  final String id;
  final String title;
  final String desc;
  final String instructions;
  final String resultsExplanation;
  final ResponseList responseList;
  final bool isPublic;

  QuizInfo(
      {this.id,
      this.title,
      this.desc,
      this.instructions,
      this.resultsExplanation,
      this.responseList,
      this.isPublic});

  factory QuizInfo.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();

    return QuizInfo(
        id: doc.id ?? '',
        title: data['title'] ?? '',
        desc: data['desc'] ?? '',
        instructions: data['instructions'] ?? '',
        resultsExplanation: data['resultsExplanation'] ?? '',
        responseList: ResponseList.fromFirestore(data['responseList']),
        isPublic: data['isPublic'] ?? false);
  }
}

class ResponseList {
  final List<Response> responses;

  ResponseList({this.responses});

  factory ResponseList.fromFirestore(Map responsesMap) {
    return responsesMap != null
        ? ResponseList(responses: [
            for (MapEntry responseMapEntry in responsesMap.entries)
              Response.fromFirestore(responseMapEntry)
          ])
        : ResponseList(responses: []);
  }
}

class Response {
  final DateTime createdAt;
  final String gender;
  final Results results;
  final String email;

  Response({this.createdAt, this.gender, this.results, this.email});

  String acadSem() {
    int responseYear = createdAt.year;
    int responseMonth = createdAt.month;
    return responseMonth > 6
        ? 'AY$responseYear-${responseYear + 1} sem1'
        : 'AY${responseYear - 1}-$responseYear sem2';
  }

  factory Response.fromFirestore(MapEntry responseMapEntry) {
    return Response(
        createdAt: responseMapEntry.value['createdAt'] ?? DateTime.now(),
        gender: responseMapEntry.value['gender'] ?? '',
        email: responseMapEntry.key ?? '',
        results: Results.fromFirestore(responseMapEntry.value['results']) ??
            Results(outcome: '', collatedScores: {}, questionScores: {}));
  }
}

class Results {
  final String outcome;
  final Map collatedScores;
  final Map questionScores;

  Results({this.outcome, this.collatedScores, this.questionScores});

  factory Results.fromFirestore(Map firestoreResults) {
    return Results(
        outcome: firestoreResults['outcome'] ?? '',
        collatedScores: firestoreResults['collatedScores'] ?? {},
        questionScores: firestoreResults['questionScores'] ?? {});
  }
}
