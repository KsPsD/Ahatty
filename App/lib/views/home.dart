import 'dart:io';

import  'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:chatbot/dio_server.dart';
import 'dart:convert';
import 'chatbot.dart';
class HomeDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Center(
              child: Container( //컨테이너 1번 엉클션 사진
                child: Image.network('https://story-img.kakaocdn.net/dn/Z8Ypx/hygpTD0Hn3/mZqTajuKYg0CT4Met2nusk/img_l.jpg?width=1920&height=1587'),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: Container( // 컨테이나 2번 버튼 제작
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    FlatButton(
                      padding: EdgeInsets.all(30.0),
                      child: Text(
                        '교재 학습',
                        style: TextStyle(color: Colors.white, fontSize: 30),
                      ),
                      color: Colors.green,
                      onPressed: (){
                        print('dialog로 이동');
                        Navigator.pushNamed(context, '/dialog');
                      },
                    ),
                    Padding(padding: EdgeInsets.all(8)),
                    FlatButton(
                      padding: EdgeInsets.all(30.0),
                      child: Text(
                        '챗봇',
                        style: TextStyle(color: Colors.white, fontSize: 30),
                      ),
                      color: Colors.deepOrange,
                      onPressed: () async {
                        _sendChpater(context);
                      },
                    ),
                    Padding(padding: EdgeInsets.all(8)),
                    FlatButton(
                      padding: EdgeInsets.all(30.0),
                      child: Text(
                        '만족도 조사하기',
                        style: TextStyle(color: Colors.white, fontSize: 30),
                      ),
                      color: Colors.amber,
                      onPressed:
                        _launchURL,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _sendChpater(BuildContext context) async{

  Map<String, dynamic> firstMap;
  final String first = await server.getReq();
    firstMap  = jsonDecode(first);
    print(firstMap);
  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(chapter: firstMap),
      ));
}


_launchURL() async {
  const url = 'https://docs.google.com/forms/d/1RQ2Nu7CHQczc3DqEvuUu0haw5itXG5afxwLl19DyjgM/edit';

  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}