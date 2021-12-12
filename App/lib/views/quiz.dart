import 'package:flutter/material.dart';
import 'package:chatbot/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'result.dart';



class QuizDisplay extends StatefulWidget {
  final List<Quiz> quiz;
  const QuizDisplay({Key key, this.quiz}) : super(key:key);
  @override
  _QuizDisplayState createState() => _QuizDisplayState();
}

class _QuizDisplayState extends State<QuizDisplay> {
  PageController _p = PageController();
  List<Correct> result = [];
  List<False> result1 = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('문장 퀴즈'),
      ),
      body: Container(
          child: PageView.builder(
              controller: _p,
              itemCount: widget.quiz.length,
              itemBuilder: (context, q){
                return Column(
                  children: <Widget>[
                    Expanded(
                      flex:1,
                      child: Center(
                        child: Container(
                          child: Text(widget.quiz[q].question,
                          style: TextStyle(
                            fontSize: 25,
                          ),),
                        ),
                      ),
                    ),
                    Expanded(
                      flex:1,
                      child: Container(
                        child: ListView.builder(
                            itemCount: widget.quiz[q].options.length,
                            itemBuilder: (context, count){
                              return FlatButton(
                                child: Text(widget.quiz[q].options[count]),
                                onPressed: (){
                                  widget.quiz[q].options[count] == widget.quiz[q].answer
                                      ? result.add(Correct(true, Word(widget.quiz[q].answer, widget.quiz[q].question)))
                                      : result1.add(False(false, Word(widget.quiz[q].answer, widget.quiz[q].question)));
                                  _p.page == widget.quiz.length-1
                                      ? Navigator.push(context, MaterialPageRoute(builder:(context) {
                                    return ResultDisplay(result: result, result1: result1,);
                                  }))
                                      : _p.nextPage(duration: Duration(milliseconds: 300), curve: Curves.linear);

                                },
                              );
                            }
                        ),
                      ),
                    ),
                  ],
                );
              }
          )
      ),
    );
  }
}

