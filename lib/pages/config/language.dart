import 'package:twisskey/api/language/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class Language extends StatefulWidget {
  const Language({Key? key}) : super(key: key);
  @override
  _Language createState() => _Language();
}

class _Language extends State<Language> {
  Locale? _locale;

  Future<Locale> _fetchLocale() async {
    var languageCode = UserPreferences.getLanguage();
    return Locale(languageCode ?? 'ja'); // デフォルトを日本語に設定します
  }

  void _changeLanguage(String languageCode) async {
    await UserPreferences.setLanguage(languageCode); // 言語設定を保存します
    var locale = await _fetchLocale();
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.of(context)!.config_language),
      ),
      body: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.dangerous_outlined),
              Flexible(
                  child: Text(
                L10n.of(context)!.experimental,
                style: const TextStyle(
                  color: Color.fromRGBO(100, 100, 100, 1),
                ),
              ))
            ],
          ),
          DropdownButton(
            items: const [
              DropdownMenuItem(
                value: 'ja',
                child: Text('日本語'),
              ),
            ],
            onChanged: (value) {
              print(value);
            },
            value: _locale?.languageCode,
          )
        ],
      ),
    );
  }
}
