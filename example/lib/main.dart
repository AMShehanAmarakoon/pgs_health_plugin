import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:pgs_health_plugin/pgs_health_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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

  HealthData _mindfulnessData;
  String mindfulness = '0';

  HealthData _caloriesData;
  String calories = '0';

  List<HealthData> _stepsData;
  String steps = '0';

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

      final resultHeartRate =
          await PgsHealthPlugin.readLast(DataType.HEART_RATE);
      if (resultHeartRate != null) {
        _hearRateData = resultHeartRate;
      }

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

      final resultPulseOximeter =
          await PgsHealthPlugin.readLast(DataType.BLOOD_OXYGEN);
      if (resultPulseOximeter != null) {
        _pulseOximeterData = resultPulseOximeter;
      }

      final resultBloodSugar =
          await PgsHealthPlugin.readLast(DataType.BLOOD_SUGAR);
      if (resultBloodSugar != null) {
        _bloodSugarData = resultBloodSugar;
      }

      final resultWater = await PgsHealthPlugin.readLast(DataType.WATER);
      if (resultWater != null) {
        _waterData = resultWater;
      }

      final resultSleep = await PgsHealthPlugin.readLast(DataType.SLEEP);
      if (resultSleep != null) {
        _sleepData = resultSleep;
      }

      final resultMindfulness =
          await PgsHealthPlugin.readLast(DataType.MINDFULNESS);
      if (resultMindfulness != null) {
        _mindfulnessData = resultMindfulness;
      }

      final resultCalories =
          await PgsHealthPlugin.readLast(DataType.ACTIVE_ENERGY_BURNED);
      if (resultCalories != null) {
        _caloriesData = resultCalories;
      }

      final results = await PgsHealthPlugin.read(
        DataType.STEP_COUNT,
        dateFrom: DateTime.now().subtract(Duration(days: 1)),
        dateTo: DateTime.now(),
      );

      _stepsData = results;
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
        Duration mindfulnessDuration =
            _mindfulnessData.dateTo.difference(_mindfulnessData.dateFrom);

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
    });
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
            ],
          ),
        ),
      ),
    );
  }
}
