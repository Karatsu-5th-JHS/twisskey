//ライブラリ読み込み
import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twisskey/api/myAccount.dart';
import 'package:twisskey/authenticate.dart';
import 'package:twisskey/pages/top/sel_instance.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:twisskey/timelinePage.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'color_schemes.g.dart';
import 'package:twisskey/api/language/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

//アイコンの初期化
String iconImage = "";

//メイン呼び出し
void main() async {
  //Timeagoの言語設定をする
  timeago.setLocaleMessages("ja", timeago.JaMessages());
  WidgetsFlutterBinding.ensureInitialized();
  await UserPreferences.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _fetchLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
  }

  Future<Locale> _fetchLocale() async {
    var languageCode = UserPreferences.getLanguage();
    return Locale(languageCode ?? 'ja'); // デフォルトを日本語に設定します
  }

  /*void _changeLanguage(String languageCode) async {
    await UserPreferences.setLanguage(languageCode); // 言語設定を保存します
    var locale = await _fetchLocale();
    setState(() {
      _locale = locale;
    });
  }*/

  @override
  Widget build(BuildContext context) {
    if (_locale == null) {
      // Localeがまだ読み込まれていない場合は、ローディングスピナーを表示します
      return CircularProgressIndicator();
    } else {
      return MaterialApp(
        title: 'Twisskey',
        locale: _locale,
        localizationsDelegates: [
          L10n.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate
        ],
        theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme,
            primaryColor: lightColorScheme.primary,
            fontFamily: 'M PLUS 1'),
        darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme,
            primaryColor: darkColorScheme.primary,
            fontFamily: 'M PLUS 1'),
        themeMode: ThemeMode.system,
        home: const MyHomePage(title: 'Twisskey'),
        supportedLocales: const [Locale('ja', 'JP')],
      );
    }
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamSubscription? _sub;

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> init() async {
    _sub = uriLinkStream.listen((Uri? uri) {
      if (kDebugMode) {
        print(uri);
      }
      if (uri != null) {
        switch (uri.queryParameters["mode"]) {
          case "auth":
            var session = uri.queryParameters['session'];
            if (session == null) {
              pushPage(const TimelinePage());
            } else {
              pushPage(Authenticate(session: session));
            }
            break;
        }
      }
    });
  }

  Future<void> pushPage(Widget page) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return page;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      alignment: Alignment.center,
      child: FutureBuilder(
        future: loginCheck(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              if (snapshot.data != "false") {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TimelinePage()));
                });
                return Text(L10n.of(context)!.login);
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return const LoginScreen();
                  }));
                });
                return Text(L10n.of(context)!.login);
              }
            } else {
              return Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              );
            }
          } else {
            return Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    ));
  }

  Widget hyperlinkButton(String url) {
    final uri = Uri.parse(url);
    return ElevatedButton(
      onPressed: () async {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri); // URLを開く
        }
      },
      child: Text(url),
    );
  }

  Widget loginButton(instance) {
    return ElevatedButton(
        onPressed: () {
          auth(instance);
        },
        //login
        child: Text(L10n.of(context)!.login));
  }

  saveHost(instance) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("host", instance);
  }

  Future<String> getIconImage() async {
    var token = sysAccount().getToken();
    final Uri uri = Uri.parse("https://m.tkngh.jp/api/i");
    Map<String, String> headers = {'content-type': 'application/json'};
    final response =
        await http.post(uri, headers: headers, body: json.encode({"i": token}));
    final String res = response.body;
    Map<String, dynamic> map = jsonDecode(res);
    String url = map["avatarUrl"];
    return url;
  }

  Future<String> loginWithToken(String isSelectedItem, String T) async {
    _MyHomePageState().saveHost(isSelectedItem);
    String host = isSelectedItem;
    String TOKEN = T;
    if (TOKEN == "null") {
      return "false";
    }
    final Uri uri = Uri.parse("https://$host/api/i");
    Map<String, String> headers = {'content-type': 'application/json'};
    final response =
        await http.post(uri, headers: headers, body: json.encode({"i": TOKEN}));
    final String res = response.body;
    Map<String, dynamic> map = jsonDecode(res);
    if (map["name"] != null) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var accountPos = (prefs.getInt('counter') ?? 0);
      if (accountPos == 0) {
        prefs.setInt("counter", 1);
        prefs.setInt("selection", 1);
        prefs.setString("1", TOKEN);
      }
      return "true";
    } else {
      return "false";
    }
  }
}

auth(instance) {
  _MyHomePageState().saveHost(instance);
  const uid = Uuid();
  String url =
      'https://$instance/miauth/${uid.v5(uid.v4(), 'tkngh')}?name=TKNGHAPP&permission=read:account,write:account,write:notes,read:notifications,write:notifications,read:blocks,write:blocks,read:drive,write:drive,read:favorites,write:favorites,read:following,write:following,read:messaging,write:messaging,read:mutes,write:mutes,write:reactions,write:votes,read:pages,write:pages,write:page-likes&callback=misskey://tkngh/?mode=auth';
  final popUp = Uri.parse(url);
  launchUrl(popUp);
}

Future<String> loginProcess(sessionKey) async {
  if (kDebugMode) {
    print("LoginProcess");
  }
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final instance = prefs.getString("host");
  final Uri uri = Uri.parse("https://$instance/api/miauth/$sessionKey/check");
  final response = await http.post(uri);
  final String res = response.body;
  Map<String, dynamic> map = jsonDecode(res);
  if (map["ok"] == true) {
    var accountPos = (prefs.getInt('counter') ?? 0);
    if (accountPos == 0) {
      prefs.setInt("counter", 1);
      prefs.setInt("selection", 1);
      prefs.setString("1", map["token"]);
    }
    return "";
  } else {
    //arb: failed_login
    return "ログインに失敗しました";
  }
}

Future<String> loginCheck() async {
  if (kDebugMode) {
    print("request start");
  }
  var token = await sysAccount().getToken();
  var host = await sysAccount().getHost();
  if (kDebugMode) {
    print("token get");
  }
  if (token == "null") {
    return "false";
  }
  final Uri uri = Uri.parse("https://$host/api/i");
  Map<String, String> headers = {'content-type': 'application/json'};
  final response =
      await http.post(uri, headers: headers, body: json.encode({"i": token}));
  final String res = response.body;
  Map<String, dynamic> map = jsonDecode(res);
  if (map["name"] != null) {
    iconImage = map["avatarUrl"];
    return map["name"];
  } else {
    return "false";
  }
}

Future<Map<String, String>> getEmoji() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var json = prefs.getString("emojis").toString();
  if (kDebugMode) {
    print("data$json");
  }
  Map<String, String> res = Map.castFrom(jsonDecode(json));
  if (kDebugMode) {
    print(res);
  }
  return res;
}

logout() async {
  if (kDebugMode) {
    print("logout");
  }
  final prefs = await SharedPreferences.getInstance();
  //ログアウト処理
  //他のアカウントのログアウトをするわけにはいかないので、少し複雑な処理を行う
  //まず、保持アカウント数を確認する
  if (prefs.getInt("counter") != null) {
    if (prefs.getInt("counter") == 1) {
      if (kDebugMode) {
        print("counter is exist");
      }
      //この時点で、ログアウトは確定。counterを0にして、トークンを削除する。
      await prefs.remove(prefs.getInt("selection").toString());
      await prefs.setInt("counter", ((prefs.getInt("counter") ?? 1) - 1));
      await prefs.remove("host");
    } else {
      //違うのであれば、1のトークンを削除後、すべてずらす(くそめんどい)
      if (kDebugMode) {
        print("non");
      }
    }
  } else {
    //counterの値が何らかの理由によって存在しない場合は、データを直接抹消してよい。
    await prefs.remove(prefs.getInt("selection").toString());
    await prefs.remove("counter");
    await prefs.remove("selection");
    await prefs.remove("host");
    if (kDebugMode) {
      print("Counter is not found");
    }
  }
  //main();
  //exit(0);
}
