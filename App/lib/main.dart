import  'package:flutter/material.dart';
import 'package:chatbot/views/chatbot.dart';
import 'package:chatbot/views/home.dart';
import 'package:chatbot/route.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zomma English',
      home: Scaffold(
        appBar: AppBar(
          title: Text('줌마영어'),
        ),
        body: HomeDisplay(),
      ),
      routes: routes,
    );
  }
}
