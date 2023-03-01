
import 'package:error/timer.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await openDatabase(
    join(await getDatabasesPath(), 'timer_database.db'),
    onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE timer(id INTEGER PRIMARY KEY,date TEXT, seconds_elapsed INTEGER)');
    },
    version: 1,
  );
runApp(MaterialApp(  initialRoute:
          "/HomeScreen", //initial route mein back slash/ replace hojata hai
      routes: {
        "/": (context) =>  TimerApp(database: database,),

      },
  
));
}

  


class bsdk extends StatelessWidget {
  const bsdk({super.key});

  @override
  Widget build(BuildContext context) {
    //flutter k andr wudgets use ki jaati hain
    //e.g text , icons , status bar , app bar, body ,heiarchy widgets hoti h

    return MaterialApp(
      themeMode: ThemeMode.light,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,

      ),

      darkTheme: ThemeData(
        brightness: Brightness.light,
      ),
    
    );
  }
}