import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chatbot/models.dart';

List<Quiz> makeQuestions(List<Word> _words){
  List<Quiz> quiz = [];
  _words.forEach((a){
    List<String> options = [a.meaning,];
    int seek = _words.indexOf(a);
    while (options.length!=4) {
      seek >= _words.length-1 ? seek = 0 : seek += 1;
      options.add(_words[seek].meaning);
    }
    options.shuffle();
    quiz.add(Quiz(
      question: a.word,
      answer: a.meaning,
      options: options,
    ));
  });
  return quiz;
}