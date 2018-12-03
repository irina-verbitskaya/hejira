import 'package:flutter/material.dart';

const LANGUAGES = [
  {
    'key': 'en',
    'title': 'English',
  },
  {
    'key': 'bg',
    'title': 'Bulgarian',
  },
  {
    'key': 'ru',
    'title': 'Russian',
  },
  {
    'key': 'ja',
    'title': 'Japanese',
  },
  {
    'key': 'fr',
    'title': 'French',
  },
  {
    'key': 'de',
    'title': 'German',
  },
  {
    'key': 'ar',
    'title': 'Arabic',
  },
  {
    'key': 'es',
    'title': 'Spanish',
  },
  {
    'key': 'zh',
    'title': 'Chinese',
  },
];

String getLanguageTitle(String value) {
  Map language = LANGUAGES.firstWhere((Map lang) => lang['key'] == value);
  return language != null ? language['title'] : 'Translate';
}

class LanguageSelector extends StatefulWidget {
  final String language;
  final Function onChanged;

  LanguageSelector({
    Key key,
    @required this.language,
    @required this.onChanged,
  }) : super(key: key);

  @override
  LanguageSelectorState createState() => new LanguageSelectorState();
}

class LanguageSelectorState extends State<LanguageSelector> {
  String language;

  @override
  Widget build(BuildContext context) {
    return new DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        items: LANGUAGES.map((Map value) {
          return new DropdownMenuItem<String>(
            value: value['key'],
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Icon(Icons.language),
                ),
                Text(value['title']),
              ],
            ),
          );
        }).toList(),
        value: widget.language,
        style: TextStyle(),
        onChanged: (value) {
          widget.onChanged(value);
        },
      ),
    );
  }
}
