import 'package:flutter/material.dart';
import 'package:chatbot/db.dart';
import 'package:chatbot/route.dart';

class DialogDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title : Text('학습 선택'),

      ),
      body : Container(
        child: ListView.builder(
            itemCount: dialogs.length,
            itemBuilder: (context, index) {
              return Card(
                child: FlatButton(
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                        (index+1).toString()+'. '+dialogs[index].dialogName,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  onPressed: (){
                    print('notebook으로 이동');
                    Navigator.pushNamed(context, '/notebook', arguments: dialogs[index].words);
                  },
                ),
              );
        }
        ),
      ),
    );
  }
}
