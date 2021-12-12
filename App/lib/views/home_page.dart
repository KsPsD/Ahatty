import 'package:chatbot/dio_server.dart';
import 'package:chatbot/models/chat_message.dart';
import 'package:chatbot/models/language.dart';
import 'package:chatbot/widgets/chat_message_list_item.dart';
import 'package:flutter/material.dart';
//import 'package:speech_to_text/speech_to_text.dart';
//import 'package:speech_to_text/speech_recognition_error.dart';
//import 'package:speech_to_text/speech_recognition_result.dart';
//import 'dart:async';
//import 'dart:math';
import 'package:speech_recognition/speech_recognition.dart';




class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}



class _HomePageState extends State<HomePage> {
  final _messageList = <ChatMessage>[];
  final _controllerText = new TextEditingController();
  SpeechRecognition _speech;
  bool _speechRecognitionAvailable = false;
  bool _isListening = false;
  String transcription = '';
  //String _currentLocale = 'en_US';
  Language selectedLang = languages.first;
//  bool _hasSpeech = false;
//  double level = 0.0;
//  double minSoundLevel = 50000;
//  double maxSoundLevel = -50000;
//  String lastWords = "";
//  String lastError = "";
//  String lastStatus = "";
//  String _currentLocaleId = "";
//  List<LocaleName> _localeNames = [];
//  final SpeechToText speech = SpeechToText();

  @override
  void dispose() {
    super.dispose();
    _controllerText.dispose();
  }

  @override
  initState() {
    super.initState();
    activateSpeechRecognizer();
  }

  void activateSpeechRecognizer() {
    print('_MyAppState.activateSpeechRecognizer... ');
    _speech = new SpeechRecognition();
    _speech.setAvailabilityHandler(onSpeechAvailability);
    _speech.setCurrentLocaleHandler(onCurrentLocale);
    _speech.setRecognitionStartedHandler(onRecognitionStarted);
    _speech.setRecognitionResultHandler(onRecognitionResult);
    _speech.setRecognitionCompleteHandler(onRecognitionComplete);
    _speech
        .activate()
        .then((res) => setState(() => _speechRecognitionAvailable = res));
  }

//  Future<void> initSpeechState() async {
//    bool hasSpeech = await speech.initialize(
//        onError: errorListener, onStatus: statusListener);
//    if (hasSpeech) {
//      _localeNames = await speech.locales();
//
//      var systemLocale = await speech.systemLocale();
//      _currentLocaleId = systemLocale.localeId;
//    }
//
//    if (!mounted) return;
//
//    setState(() {
//      _hasSpeech = hasSpeech;
//    });
//  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text('Chatbot - User'),
      ),
      body: Column(
        children: <Widget>[
          _buildList(),
          Divider(height: 1.0),
          _buildUserInput(),
        ],
      ),
    );
  }


  Widget _buildList() {
    return Flexible(
      child: ListView.builder(
        padding: EdgeInsets.all(8.0),
        reverse: true,
        itemBuilder: (_, int index) => ChatMessageListItem(chatMessage: _messageList[index]),
        itemCount: _messageList.length,
      ),
    );
  }

  Future _dialogRequest({String query}) async {


    _addMessage(
        name: 'Chatbot',
        text: 'Writing...',
        type: ChatMessageType.received);

      final String response = await server.postReq(query);

    setState(() {
      _messageList.removeAt(0);
    });


    _addMessage(
        name: 'Chatbot',
        text: response ?? '',
        type: ChatMessageType.received);
  }


  void _sendMessage({String text}) {
    _controllerText.clear();
    _addMessage(name: 'User', text: text, type: ChatMessageType.sent);
  }


  void _addMessage({String name, String text, ChatMessageType type}) {
    var message = ChatMessage(
        text: text, name: name, type: type);
    setState(() {
      _messageList.insert(0, message);
    });

    if (type == ChatMessageType.sent) {
      _dialogRequest(query: message.text);
    }
  }


  Widget _buildTextField() {
    return new Flexible(
      child: new TextField(
        controller: _controllerText,
        decoration: new InputDecoration.collapsed(
          hintText: "Message",
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return new Container(
      margin: new EdgeInsets.only(left: 8.0),
      child: new IconButton(
          icon: new Icon(Icons.send, color: Theme.of(context).accentColor),
          onPressed: () {
            if (_controllerText.text.isNotEmpty) {
              _sendMessage(text: _controllerText.text);
            }
          }),

    );
  }
Widget _speechButton(){
    return new Container(
        margin: new EdgeInsets.only(right: 8.0),
  child: new IconButton(
  icon: new Icon(_isListening ? Icons.mic :Icons.mic_none , color: Theme.of(context).accentColor),
    onPressed:_speechRecognitionAvailable && !_isListening?
        () => start(): null)
//    _speechRecognitionAvailable && !_isListening
//        ? () => start()
//        : null,
      );

}

  Widget _buildUserInput() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: new Row(
        children: <Widget>[
          _speechButton(),
          _buildTextField(),
          _buildSendButton(),
        ],
      ),
    );
  }
  void start() => _speech
      .listen(locale: selectedLang.code)
      .then((result) => print('_MyAppState.start => result ${result}'));

  void cancel() =>
      _speech.cancel().then((result) => setState(() => _isListening = result));

  void stop() =>
      _speech.stop().then((result) => setState(() => _isListening = result));

  void onSpeechAvailability(bool result) =>
      setState(() => _speechRecognitionAvailable = result);

  void onCurrentLocale(String locale) {
    print('_MyAppState.onCurrentLocale... $locale');
    setState(
            () => selectedLang = languages.firstWhere((l) => l.code == locale));
  }

  void onRecognitionStarted() => setState(() => _isListening = true);

  void onRecognitionResult(String text) => setState(() => _controllerText.text = text);

  void onRecognitionComplete() => setState(() => _isListening = false);


}
