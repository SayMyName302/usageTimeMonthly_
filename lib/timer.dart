import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TimerApp extends StatefulWidget {
  final Database database;

  const TimerApp({Key? key, required this.database}) : super(key: key);

  @override
  _TimerAppState createState() => _TimerAppState();
}

class _TimerAppState extends State<TimerApp> with WidgetsBindingObserver {
  late Timer _timer;
  int _secondsElapsed = 0;
  late DateTime _startDate;

  Database get database => widget.database;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _getSecondsElapsed();
    _startTimer();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance?.removeObserver(this);
    _stopTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _secondsElapsed = DateTime.now().difference(_startDate).inSeconds;
        _updateSecondsElapsed(_secondsElapsed);
      });
    });
  }

  void _stopTimer() {
    _timer.cancel();
  }

  Future<void> _getSecondsElapsed() async {
    final List<Map<String, dynamic>> rows = await database.query('timer', orderBy: 'id DESC', limit: 1);
    if (rows.isNotEmpty) {
      final Map<String, dynamic> row = rows.first;
      _startDate = DateTime.parse(row['date']);
      final DateTime currentDate = DateTime.now();
      if (currentDate.year != _startDate.year || currentDate.month != _startDate.month || currentDate.day != _startDate.day) {
        await _insertNewRow(currentDate);
      } else {
        _secondsElapsed = row['seconds_elapsed'] as int;
      }
    } else {
      await _insertNewRow(DateTime.now());
    }
     final List<Map<String, dynamic>> maps = await database.query('timer');
  if (maps.isNotEmpty) {
    setState(() {
      _secondsElapsed = 0;
    });
  }
  print('All rows in timer table:');
  print(maps);
}
  

  Future<void> _updateSecondsElapsed(int secondsElapsed) async {
    await database.update(
      'timer',
      {
        'seconds_elapsed': secondsElapsed,
      },
      where: 'id = (SELECT MAX(id) FROM timer)',
    );
  }

  Future<void> _insertNewRow(DateTime date) async {
    _startDate = date;
    await database.insert(
      'timer',
      {
        'date': _startDate.toIso8601String(),
        'seconds_elapsed': 0,
      },
    );
    _secondsElapsed = 0;
  }

  String getTimerString() {
    final int hours = _secondsElapsed ~/ 3600;
    final int minutes = (_secondsElapsed % 3600) ~/ 60;
    final int seconds = _secondsElapsed % 60;

    final String hourString = hours > 0 ? '$hours hour ' : '';
    final String minuteString = minutes > 0 || hours > 0 ? '$minutes minute ' : '';
    final String secondString = '$seconds second';

    return '$hourString$minuteString$secondString';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer App'),
      ),
      body: Center(
        child: Text(
          'Time elapsed: ${getTimerString()}',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _stopTimer();
    } else if (state == AppLifecycleState.resumed) {
      _getSecondsElapsed();
      _startTimer();
    }
  }
}