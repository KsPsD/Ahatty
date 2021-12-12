class Quiz{
  String question;
  String answer;
  List<String> options;

  Quiz({this.question, this.answer, this.options});
}

class Dialog{
  int dId;
  String dialogName;
  String dialogNameKr;
  List<Word> words;

  Dialog(this.dId, this.dialogName, this.dialogNameKr, this.words);
}

class Word{
  String word;
  String meaning;

  Word(this.word, this.meaning);
}


class Correct{
  bool result;
  Word word;

  Correct(this.result, this.word);
}

class False{
  bool result;
  Word word;

  False(this.result, this.word);
}
