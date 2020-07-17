import 'dart:ffi';
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:pgs_health_plugin/pgs_health_plugin.dart';
import 'package:intl/intl.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final todayDate = DateTime.now();

  HealthData _hearRateData;
  String heartRate = '0';

  HealthData _bloodPressureSystolicData;
  String bloodPressureSystolic = '0';

  HealthData _bloodPressureDiastolicData;
  String bloodPressureDiastolic = '0';

  HealthData _pulseOximeterData;
  String pulseOximeter = '0';

  HealthData _bloodSugarData;
  String bloodSugar = '0';

  HealthData _waterData;
  String water = '0';

  HealthData _sleepData;
  String sleep = '0';

  List<HealthData> _mindfulnessData;
  String mindfulness = '0';

  HealthData _caloriesData;
  String calories = '0';

  List<HealthData> _stepsData;
  String steps = '0';

  String stepsToday = '0';
  String stepsLastWeek = '0';
  String stepsLastMonth = '0';
  List<HealthData> resultStepToday;
  List<HealthData> resultStepLastWeek;
  List<HealthData> resultStepLastMonth;

  String waterToday = '0';
  String waterYesterday = '0';
  String waterLastWeek = '0';
  List<HealthData> resultWaterToday;
  List<HealthData> resultWaterTodayAll;
  List<HealthData> resultWaterYesterday;
  List<HealthData> resultWaterLastWeek;

  String sleepLastNight = '';
  String sleepTimeLastNight = '';
  String sleepThisWeek = '';
  String sleepLastWeek = '';
  String sleepLastMonth = '';
  List<HealthData> resultSleepLastNight = [];
  List<HealthData> resultSleepThisWeek = [];
  List<HealthData> resultSleepLastWeek = [];
  List<HealthData> resultSleepLastMonth = [];

  String mindfulnessToday = '';
  String mindfulnessThisWeek = '';
  String mindfulnessLastWeek = '';
  String mindfulnessLastMonth = '';
  List<HealthData> resultMindfulnessToday = [];
  List<HealthData> resultMindfulnessThisWeek = [];
  List<HealthData> resultMindfulnessLastWeek = [];
  List<HealthData> resultMindfulnessLastMonth = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    bool permission;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      permission = await PgsHealthPlugin.requestPermissions(DataType.values);

      // Heart Rate
      await _heartRate();

      // Blood Pressure
      await _bloodPressure();

      // Pulse Oximeter
      await _pulseOximeter();

      // Blood Sugar
      await _bloodSugar();

      // Sleep
      await _sleep();

      // Mindfulness
      await _mindfulness();

      // Calories
      await _calories();

      // Steps
      await _stepCount();

      // Water
      await _water();
    } on PlatformException {
      permission = false;
    }

    print(permission);

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      // Heart Rate
      if (_hearRateData != null) {
        heartRate = _hearRateData.value.toString();
      }

      // Blood Pressure Systolic
      if (_bloodPressureSystolicData != null) {
        bloodPressureSystolic = _bloodPressureSystolicData.value.toString();
      }

      // Blood Pressure Diastolic
      if (_bloodPressureDiastolicData != null) {
        bloodPressureDiastolic = _bloodPressureDiastolicData.value.toString();
      }

      // Pulse Oximeter
      if (_pulseOximeterData != null) {
        pulseOximeter = _pulseOximeterData.value.toString();
      }

      // Blood Sugar
      if (_bloodSugarData != null) {
        bloodSugar = _bloodSugarData.value.toString();
      }

      // Water
      if (_waterData != null) {
        water = _waterData.value.toString();
      }

      // Sleep
      if (_sleepData != null) {
        Duration sleepDuration =
            _sleepData.dateTo.difference(_sleepData.dateFrom);

        sleep = sleepDuration.toString().split('.')[0];
      }

      // Mindfulness
      if (_mindfulnessData != null) {
        Duration mindfulnessDuration = _mindfulnessData.last.dateTo
            .difference(_mindfulnessData.last.dateFrom);

        mindfulness = mindfulnessDuration.toString().split('.')[0];
      }

      // Calories
      if (_caloriesData != null) {
        calories = _caloriesData.value.toString();
      }

      // Steps
      if (_stepsData != null) {
        int todaySteps = 0;

        _stepsData.forEach((f) {
          todaySteps += f.value.toInt();
        });

        steps = todaySteps.toString();
      }

      // Steps Today
      if (resultStepToday != null && resultStepToday.length > 0) {
        stepsToday = resultStepToday[0].value.toString();
      }

      // Steps Last Week
      if (resultStepLastWeek != null && resultStepLastWeek.length > 0) {
        int totalSteps = 0;
        int count = 0;

        resultStepLastWeek.forEach((f) {
          totalSteps += f.value.toInt();
          count++;
        });
        double avg = (totalSteps / count);
        stepsLastWeek = avg.round().toString();
      }

      // Steps Last Month
      if (resultStepLastMonth != null && resultStepLastMonth.length > 0) {
        int totalSteps = 0;
        int count = 0;
        resultStepLastMonth.forEach((f) {
          totalSteps += f.value.toInt();
          count++;
        });
        stepsLastMonth = (totalSteps / count).toString();
      }

      // Water Today
      if (resultWaterToday != null && resultWaterToday.length > 0) {
        int decimals = 1;
        int fac = pow(10, decimals);
        double d = resultWaterToday[0].value;
        d = (d * fac).round() / fac;

        waterToday = d.toString();
      }

      // Water Yesterday
      if (resultWaterYesterday != null && resultWaterYesterday.length > 0) {
        int decimals = 1;
        int fac = pow(10, decimals);
        double d = resultWaterYesterday[0].value;
        d = (d * fac).round() / fac;

        waterYesterday = d.toString();
      }

      // Steps Last Week
      if (resultWaterLastWeek != null && resultWaterLastWeek.length > 0) {
        int totalSteps = 0;

        resultWaterLastWeek.forEach((f) {
          totalSteps += f.value.toInt();
        });

        waterLastWeek = totalSteps.toString();
      }

      // Sleep Last Night
      if (resultSleepLastNight != null && resultSleepLastNight.length > 0) {
        Duration sleepDuration = resultSleepLastNight.last.dateTo
            .difference(resultSleepLastNight.last.dateFrom);

        String duration = sleepDuration.toString().split('.')[0];
        String hours = duration.split(':')[0];
        String minutes = duration.split(':')[1];

        String toTime = DateFormat('h:mm').format(
            DateTime.fromMicrosecondsSinceEpoch(
                _sleepData.dateTo.millisecondsSinceEpoch * 1000));
        String toTimeAmPm = DateFormat('a').format(
            DateTime.fromMicrosecondsSinceEpoch(
                _sleepData.dateTo.millisecondsSinceEpoch * 1000));

        String fromTime = DateFormat('h:mm').format(
            DateTime.fromMicrosecondsSinceEpoch(
                _sleepData.dateFrom.millisecondsSinceEpoch * 1000));
        String fromTimeAmPm = DateFormat('a').format(
            DateTime.fromMicrosecondsSinceEpoch(
                _sleepData.dateFrom.millisecondsSinceEpoch * 1000));

        sleepLastNight = '$hours hr. $minutes min.';
        sleepTimeLastNight = '$fromTime $fromTimeAmPm - $toTime $toTimeAmPm';
      }

      // Sleep This Week
      if (resultSleepThisWeek != null && resultSleepThisWeek.length > 0) {
        int totalSeconds = 0;
        int count = 0;

        resultSleepThisWeek.forEach((f) {
          Duration sleepDuration = f.dateTo.difference(f.dateFrom);

          totalSeconds += sleepDuration.inSeconds;
          count++;
        });

        double avgInMinutes = (totalSeconds / count);

        String duration =
            Duration(seconds: avgInMinutes.toInt()).toString().split('.')[0];
        String hours = duration.split(':')[0];
        int minutes = int.parse(duration.split(':')[1]);
        int seconds =
            int.parse(duration.split(':')[2]); //duration.split(':')[2];

        if (seconds >= 30) {
          minutes++;
        }

        sleepThisWeek = '$hours $minutes';
      }

      // Sleep Last Week
      if (resultSleepLastWeek != null && resultSleepLastWeek.length > 0) {
        int totalSeconds = 0;
        int count = 0;

        resultSleepLastWeek.forEach((f) {
          Duration sleepDuration = f.dateTo.difference(f.dateFrom);

          totalSeconds += sleepDuration.inSeconds;
          count++;
        });

        double avgInMinutes = (totalSeconds / count);

        String duration =
            Duration(seconds: avgInMinutes.toInt()).toString().split('.')[0];
        String hours = duration.split(':')[0];
        int minutes = int.parse(duration.split(':')[1]);
        int seconds =
            int.parse(duration.split(':')[2]); //duration.split(':')[2];

        if (seconds >= 30) {
          minutes++;
        }
        sleepLastWeek = '$hours $minutes';
      }

      // Sleep Last Month
      if (resultSleepLastMonth != null && resultSleepLastMonth.length > 0) {
        int totalSeconds = 0;
        int count = 0;

        resultSleepLastMonth.forEach((f) {
          Duration sleepDuration = f.dateTo.difference(f.dateFrom);

          totalSeconds += sleepDuration.inSeconds;
          count++;
        });

        double avgInMinutes = (totalSeconds / count);

        String duration =
            Duration(seconds: avgInMinutes.toInt()).toString().split('.')[0];
        String hours = duration.split(':')[0];
        int minutes = int.parse(duration.split(':')[1]);
        int seconds =
            int.parse(duration.split(':')[2]); //duration.split(':')[2];

        if (seconds >= 30) {
          minutes++;
        }
        sleepLastMonth = '$hours $minutes';
      }

      // Mindfulness Today
      if (resultMindfulnessToday != null && resultMindfulnessToday.length > 0) {
        int totalSeconds = 0;

        resultMindfulnessToday.forEach((f) {
          Duration duration = f.dateTo.difference(f.dateFrom);

          totalSeconds += duration.inSeconds;
        });

        mindfulnessToday =
            Duration(seconds: totalSeconds.toInt()).inMinutes.toString();
      }

      // Mindfulness This Week
      if (resultMindfulnessThisWeek != null &&
          resultMindfulnessThisWeek.length > 0) {
        int totalSeconds = 0;

        resultMindfulnessThisWeek.forEach((f) {
          Duration duration = f.dateTo.difference(f.dateFrom);

          totalSeconds += duration.inSeconds;
        });

        mindfulnessThisWeek =
            Duration(seconds: totalSeconds.toInt()).inMinutes.toString();
      }

      // Mindfulness Last Week
      if (resultMindfulnessLastWeek != null &&
          resultMindfulnessLastWeek.length > 0) {
        int totalSeconds = 0;

        resultMindfulnessLastWeek.forEach((f) {
          Duration duration = f.dateTo.difference(f.dateFrom);

          totalSeconds += duration.inSeconds;
        });

        mindfulnessLastWeek =
            Duration(seconds: totalSeconds.toInt()).inMinutes.toString();
      }

      // Mindfulness Last Month
      if (resultMindfulnessLastMonth != null &&
          resultMindfulnessLastMonth.length > 0) {
        int totalSeconds = 0;

        resultMindfulnessLastMonth.forEach((f) {
          Duration duration = f.dateTo.difference(f.dateFrom);

          totalSeconds += duration.inSeconds;
        });

        mindfulnessLastMonth =
            Duration(seconds: totalSeconds.toInt()).inMinutes.toString();
      }
    });
  }

  Future<Void> _calories() async {
    final resultCalories =
        await PgsHealthPlugin.readLast(DataType.ACTIVE_ENERGY_BURNED);
    if (resultCalories != null) {
      _caloriesData = resultCalories;
    }
  }

  Future<Void> _mindfulness() async {
    final resultMindfulness = await PgsHealthPlugin.read(DataType.MINDFULNESS);
    if (resultMindfulness != null) {
      _mindfulnessData = resultMindfulness;
    }

    // Mindfulness Today
    resultMindfulnessToday = await PgsHealthPlugin.readCategory(
        DataType.MINDFULNESS,
        dateFrom: todayDate.subtract(Duration(days: 1)),
        dateTo: todayDate,
        interval: 1);

    // Mindfulness This Week
    resultMindfulnessThisWeek = await PgsHealthPlugin.readCategory(
        DataType.MINDFULNESS,
        dateTo: todayDate,
        dateFrom: todayDate.subtract(Duration(days: 6)),
        interval: 1);

    // Mindfulness Last Week
    resultMindfulnessLastWeek = await PgsHealthPlugin.readCategory(
        DataType.MINDFULNESS,
        dateTo: todayDate.subtract(Duration(days: 7)),
        dateFrom: todayDate.subtract(Duration(days: 14)),
        interval: 1);

    // Mindfulness Last Month
    resultMindfulnessLastMonth = await PgsHealthPlugin.readCategory(
        DataType.MINDFULNESS,
        dateFrom: DateTime(todayDate.year, todayDate.month, 1),
        dateTo: todayDate,
        interval: 1);
  }

  Future<Void> _sleep() async {
    final resultSleep = await PgsHealthPlugin.readLast(DataType.SLEEP);
    if (resultSleep != null) {
      _sleepData = resultSleep;
    }

    // Sleep Last Night
    resultSleepLastNight = await PgsHealthPlugin.readCategory(DataType.SLEEP,
        dateFrom: todayDate.subtract(Duration(days: 1)),
        dateTo: todayDate,
        interval: 1);

    // Sleep This Week
    resultSleepThisWeek = await PgsHealthPlugin.readCategory(DataType.SLEEP,
        dateTo: todayDate,
        dateFrom: todayDate.subtract(Duration(days: 7)),
        interval: 1);

    resultSleepLastWeek = await PgsHealthPlugin.readCategory(DataType.SLEEP,
        dateTo: todayDate.subtract(Duration(days: 7)),
        dateFrom: todayDate.subtract(Duration(days: 14)),
        interval: 1);

    // Sleep Last Month
    resultSleepLastMonth = await PgsHealthPlugin.readCategory(DataType.SLEEP,
        dateFrom: DateTime(todayDate.year, todayDate.month, 1),
        dateTo: todayDate,
        interval: 1);
  }

  Future<Void> _bloodSugar() async {
    final resultBloodSugar =
        await PgsHealthPlugin.readLast(DataType.BLOOD_SUGAR);
    if (resultBloodSugar != null) {
      _bloodSugarData = resultBloodSugar;
    }
  }

  Future<Void> _pulseOximeter() async {
    final resultPulseOximeter =
        await PgsHealthPlugin.readLast(DataType.BLOOD_OXYGEN);
    if (resultPulseOximeter != null) {
      _pulseOximeterData = resultPulseOximeter;
    }
  }

  Future<Void> _bloodPressure() async {
    final resultBloodPressureSystolic =
        await PgsHealthPlugin.readLast(DataType.BLOOD_PRESSURE_SYSTOLIC);
    if (resultBloodPressureSystolic != null) {
      _bloodPressureSystolicData = resultBloodPressureSystolic;
    }

    final resultBloodPressureDiastolic =
        await PgsHealthPlugin.readLast(DataType.BLOOD_PRESSURE_DIASTOLIC);
    if (resultBloodPressureDiastolic != null) {
      _bloodPressureDiastolicData = resultBloodPressureDiastolic;
    }
  }

  Future<Void> _heartRate() async {
    final resultHeartRate = await PgsHealthPlugin.readLast(DataType.HEART_RATE);
    if (resultHeartRate != null) {
      _hearRateData = resultHeartRate;
    }
  }

  Future<Void> _water() async {
    final resultWater = await PgsHealthPlugin.readLast(DataType.WATER);
    if (resultWater != null) {
      _waterData = resultWater;
    }

    // Water Today All
    resultWaterTodayAll = await PgsHealthPlugin.read(DataType.WATER,
        dateFrom: todayDate.subtract(Duration(days: 1)), dateTo: todayDate);
    print(resultWaterTodayAll.toString());

    // Water Today
    resultWaterToday = await PgsHealthPlugin.readStats(DataType.WATER,
        dateFrom: todayDate, dateTo: todayDate, interval: 1);

    // Water Yesterday
    resultWaterYesterday = await PgsHealthPlugin.readStats(DataType.WATER,
        dateTo: todayDate.subtract(Duration(days: 1)),
        dateFrom: todayDate.subtract(Duration(days: 2)),
        interval: 1);

    // Water Last Week
    resultWaterLastWeek = await PgsHealthPlugin.readStats(DataType.WATER,
        dateFrom: todayDate.subtract(Duration(days: 6)),
        dateTo: todayDate,
        interval: 1);
  }

  Future<Void> _stepCount() async {
    // Steps Today
    resultStepToday = await PgsHealthPlugin.readStats(DataType.STEP_COUNT,
        dateFrom: todayDate, dateTo: todayDate, interval: 1);

    // Steps Last Week
    resultStepLastWeek = await PgsHealthPlugin.readStats(DataType.STEP_COUNT,
        dateFrom: todayDate.subtract(Duration(days: 6)),
        dateTo: todayDate,
        interval: 1);

    // Steps Last Month
    resultStepLastMonth = await PgsHealthPlugin.readStats(DataType.STEP_COUNT,
        dateFrom: DateTime(todayDate.year, todayDate.month, 1),
        dateTo: todayDate,
        interval: 1);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Heart Rate : $heartRate'),
              Text(
                  'Blood Pressure : $bloodPressureSystolic/$bloodPressureDiastolic'),
              Text('Pulse Oximeter : $pulseOximeter'),
              Text('Blood Sugar : $bloodSugar'),
              Text('Water : $water'),
              Text('Sleep : $sleep'),
              Text('Mindfulness : $mindfulness'),
              Text('Steps : $steps'),
              Text('Calories : $calories'),
              Card(
                child: Column(
                  children: <Widget>[
                    Text(
                      "Steps",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text("Today : $stepsToday"),
                    Text("Last Week : $stepsLastWeek"),
                    Text("Last Month : $stepsLastMonth")
                  ],
                ),
              ),
              Card(
                child: Column(
                  children: <Widget>[
                    Text("Water",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("Today : $waterToday"),
                    Text("Yesterday : $waterYesterday"),
                    Text("Last Week : $waterLastWeek")
                  ],
                ),
              ),
              Card(
                child: Column(
                  children: <Widget>[
                    Text("Sleep",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("Last Night Duration: $sleepLastNight"),
                    Text("Last Night Time : $sleepTimeLastNight"),
                    Text("This Week : $sleepThisWeek"),
                    Text("Last Week : $sleepLastWeek"),
                    Text("Last Month : $sleepLastMonth"),
                  ],
                ),
              ),
              Card(
                child: Column(
                  children: <Widget>[
                    Text("Mindfulness",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("Today : $mindfulnessToday"),
                    Text("This Week : $mindfulnessThisWeek"),
                    Text("Last Week : $mindfulnessLastWeek"),
                    Text("Last Month : $mindfulnessLastMonth"),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
