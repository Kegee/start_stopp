import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'stopp.dart';

main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    Color bleuF = Color(0xFF4da6ff);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OrdoSafE',
      theme: ThemeData(
        primaryColor: bleuF,
        fontFamily: 'Roboto',
        textTheme: TextTheme(
          title: TextStyle(
            color: bleuF,
            fontFamily: 'OpenSans',
            fontSize: 22,
          ),
          subtitle: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 15,
          ),
          body1: TextStyle(
            fontSize: 20,
            color: bleuF,
          ),
        ),
      ),
      home: StoppPage(),
    );
  }
}