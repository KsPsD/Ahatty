import 'package:flutter/material.dart';
import 'package:chatbot/views/quiz.dart';
import 'package:chatbot/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chatbot/models.dart';
import '../views/quiz.dart';
import 'package:chatbot/util/quiz_util.dart';

class NotebookDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Word> _word = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text('문장 목록'),
      ),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex:10,
              child: ListView.builder(
                  itemCount: _word.length,
                  itemBuilder: (context, count) {
                    return ListTile(
                      title: Text(
                        (count+1).toString() + '. ' + _word[count].word,
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                      subtitle: Text(
                        _word[count].meaning,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    );
                  }),
            ),
            Expanded(
              flex: 1,
              child: FlatButton(
                color: Colors.redAccent,
                child: Text('문장 퀴즈',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                ),
                ),
                onPressed: () {
                  print('퀴즈로 이동');
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return QuizDisplay(quiz: makeQuestions(_word),);
                  }
                  ));
                }
            ),
            ),
          ],
        ),
    );
  }
}


/*
Expanded(
              flex:1,
              child: FlatButton(
                color: Colors.redAccent,
                child:Text(
                  '단어 퀴즈',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                  ),
                ),
                onPressed: (){
                  print('quiz로 이동');
                  Navigator.push(context, MaterialPageRoute(builder:(context){
                    _word.shuffle();
                    String question = _word[0].word;
                    String answer = _word[0].meaning;
                    List<String> options = [
                      _word[0].meaning,
                      _word[1].meaning,
                      _word[2].meaning,
                      _word[3].meaning,
                    ];
                    options.shuffle();
                    return QuizDisplay(
                        quiz: Quiz(question: question, answer: answer, options: options),
                    );
                  }
                  ));
                },
              ),
            ),
 */