import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hejira_translator/language_selector.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

const String API_KEY =
    'trnsl.1.1.20181202T214350Z.98f43d74e03034d4.d5e046209b593e960100fe276137c4292393132f';
const String YANDEX_LINK = 'http://translate.yandex.com/';

class TranslateScreen extends StatefulWidget {
  @override
  TranslateScreenState createState() => new TranslateScreenState();
}

class TranslationObject {
  int code;
  String lang;
  List<String> text;
  bool isInvalid = false;

  TranslationObject({
    this.code,
    this.lang,
    this.text,
  });

  factory TranslationObject.fromJson(Map<String, dynamic> json) {
    return TranslationObject(
      code: json['code'],
      lang: json['lang'],
      text: new List<String>.from(json['text']),
    );
  }
}

class TranslateScreenState extends State<TranslateScreen> {
  TranslationObject translation;

  String originalLanguage = 'ru';
  String translateLanguage = 'en';

  Timer _debounce;

  bool isLoading = false;
  final inputController = TextEditingController();

  Future<TranslationObject> fetchTranslation(String text) async {
    final response = await http.post(
      'https://translate.yandex.net/api/v1.5/tr.json/translate?lang=$originalLanguage-$translateLanguage&key=$API_KEY',
      body: {
        'text': text,
      },
    );

    if (response.statusCode == 200) {
      return TranslationObject.fromJson(json.decode(response.body));
    }

    TranslationObject invalidTranslation = TranslationObject();
    invalidTranslation.isInvalid = true;

    return invalidTranslation;
  }

  renderTranslation() {
    String text = 'No translation';
    bool enabled = false;

    if (translation != null && !translation.isInvalid) {
      text = translation.text[0];
      enabled = true;
    }

    return TextField(
      controller: TextEditingController(text: text),
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: getLanguageTitle(translateLanguage),
        suffix: isLoading ? RefreshProgressIndicator() : null,
        enabled: enabled,
      ),
      style: TextStyle(
        color: enabled ? null : Colors.grey,
      ),
      keyboardType: TextInputType.multiline,
      maxLines: null,
    );
  }

  onTranslateAction(String text) async {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    setState(() {
      isLoading = true;
    });

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      TranslationObject translation = await fetchTranslation(text);
      setState(() {
        this.translation = translation;
        this.isLoading = false;
      });
    });
  }

  forceTranslate() {
    String text = inputController.value.text;
    onTranslateAction(text);
  }

  switchLanguages() {
    String tmp = originalLanguage;
    originalLanguage = translateLanguage;
    translateLanguage = tmp;

    forceTranslate();
  }

  Widget renderLanguageBar() {
    return new Row(
      children: <Widget>[
        new Container(
          width: MediaQuery.of(context).size.width * 0.40,
          child: LanguageSelector(
            language: originalLanguage,
            onChanged: (value) {
              setState(() {
                originalLanguage = value;
                forceTranslate();
              });
            },
          ),
        ),
        new Container(
          width: MediaQuery.of(context).size.width * 0.10,
          child: IconButton(
            icon: new Icon(Icons.cached),
            onPressed: () {
              switchLanguages();
            },
          ),
        ),
        new Container(
          width: MediaQuery.of(context).size.width * 0.40,
          child: LanguageSelector(
            language: translateLanguage,
            onChanged: (value) {
              setState(() {
                translateLanguage = value;
                forceTranslate();
              });
            },
          ),
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    );
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  Widget renderInputText() {
    return TextField(
      onChanged: (value) {
        onTranslateAction(value);
      },
      decoration: InputDecoration(
        labelText: 'What do you want to translate?',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.multiline,
      maxLines: null,
      controller: inputController,
    );
  }

  renderMainView() {
    return new Container(
      margin: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          new Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: renderLanguageBar(),
          ),
          new Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: renderInputText(),
          ),
          new Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: renderTranslation(),
          ),
          new Align(
            alignment: FractionalOffset.bottomCenter,
            child: InkWell(
              child: Text("Powered by Yandex.Translate"),
              onTap: () async {
                if (await canLaunch(YANDEX_LINK)) {
                  await launch(YANDEX_LINK);
                }
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hejira Translator'),
      ),
      body: renderMainView(),
    );
  }
}

// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: AppBar(
//       title: Text('Fetch Data Example'),
//     ),
//     body: FutureBuilder(
//       future: fetchTranslation("Hello World!"),
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           return renderMainView();
//         }

//         if (snapshot.hasError) {
//           return Text("${snapshot.error}");
//         }

//         // By default, show a loading spinner
//         return CircularProgressIndicator();
//       },
//     ),
//   );
// }
