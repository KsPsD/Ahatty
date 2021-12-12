import 'package:flutter/material.dart';
import 'package:chatbot/views/home.dart';
import 'package:chatbot/models.dart';
import 'package:chatbot/route.dart';
import 'package:chatbot/main.dart';
import '../views/notebook.dart';


class ResultDisplay extends StatelessWidget {
  final List<Correct> result;
  final List<False> result1;
  const ResultDisplay({Key key, this.result, this.result1}) : super(key:key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('정답 체크'),
      ),
      body: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          textBaseline: TextBaseline.ideographic,
          children: <Widget>[
            Expanded(
              flex: 5,
              child: Container(
                child: Center(
                  child: Text('점수 : ' + result.length.toString() + "/" + "${result1.length + result.length}", style: TextStyle(fontSize: 30),),
                ),
              ),
            ),
            Expanded(
                flex: 5,
                child: Center(child: Text('정답 리스트', style: TextStyle(color: Colors.green, fontSize: 30,),))),

            Expanded(
              flex: 20,
              child: ListView.builder(
                itemCount: result.length, 
                itemBuilder: (context, count) {
                  return ListTile(
                    title: Text(result[count].word.meaning + "\n" + result[count].word.word),
                  );
                  },),
            ),
            Expanded(
                flex: 5,
                child: Center(child: Text('오답 리스트', style: TextStyle(color: Colors.red, fontSize: 30),))),
            Expanded(
              flex: 20,
              child: ListView.builder(
                itemCount: result1.length,
                itemBuilder: (context, count) {
                  return ListTile(
                    title: Text(result1[count].word.meaning + "\n" + result1[count].word.word),
                  );
                },),
            ),
            Expanded(
              flex: 11,
              child: FlatButton(
                padding: EdgeInsets.all(40.0),
                child: Text(
                  '처음으로 이동',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
                color: Colors.blueAccent,
                onPressed: (){
                  print('home 으로 이동');
                  Navigator.push(context, MaterialPageRoute(builder:(context) {
                    return HomeDisplay();
                  }));
                },
              ),
            )
          ],
        ),
      )
      );
  }
}

/*
body: Center(
        child: Container(
              child : ListView.builder(
                itemCount: result.length, 
                itemBuilder: (context, count) {
                  return ListTile(
                    title: Text(result[count].result.toString()), 
                    subtitle: Text(result[count].word.meaning),
                  );
                },)
          ),
        ),
 */

