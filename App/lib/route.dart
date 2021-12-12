import 'package:flutter/material.dart';
import 'package:chatbot/views/chatbot.dart';
import 'package:chatbot/views/dialog.dart';
import 'package:chatbot/views/home.dart';
import 'package:chatbot/views/notebook.dart';
import 'package:chatbot/views/quiz.dart';
import 'package:chatbot/views/result.dart';


final routes = {
  '/home': (context)=> HomeDisplay(),
  '/notebook': (context)=> NotebookDisplay(),
  '/chatbot': (context)=> HomePage(),
  '/quiz': (context)=> QuizDisplay(),
  '/dialog': (context) => DialogDisplay(),
  '/result': (context) => ResultDisplay(),
};