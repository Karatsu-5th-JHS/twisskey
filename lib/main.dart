//ライブラリ読み込み
import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twisskey/api/myAccount.dart';
import 'package:twisskey/authenticate.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:twisskey/timelinePage.dart';
import 'color_schemes.g.dart';
//アイコンの初期化
String iconImage = "";

//メイン呼び出し
void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TKNGH for Android',
      theme: ThemeData(
          useMaterial3: true, colorScheme: lightColorScheme
      ),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      home: const MyHomePage(title: 'TKNGH'),
      supportedLocales: const [Locale('ja','JP')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate
      ],
    );
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
  String isSelectedItem = "m.tkngh.jp";
  String TOKEN = "";

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
            if(session == null){
              pushPage(const TimelinePage());
            }else{
              pushPage(Authenticate(session: session));
            }
            break;
        }
      }
    });
  }

  Future<void> pushPage(Widget page) async{
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
      appBar: AppBar(
        title: const Row(children: [
          Image(image: AssetImage('asset/tkngh.png'), width: 20, height: 20),
          Text("TKNGH")
        ],)
      ),
      body: Center(
        child: FutureBuilder<String?>(
            future: loginCheck(),
            builder: (context,ss) {
              if (ss.hasData) {
                String result = ss.data!;
                if(result != "false"){
                  //ログインされていれば、タイムラインページに推移を行います。
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TimelinePage()
                        )
                    );
                  });
                  return Column(
                    children: [
                      Image.network(iconImage),
                      Text("$resultさんようこそ")
                    ],
                  );
                }else{
                  return Column(
                    children: [
                      DropdownButton(
                        //4
                        items: const [
                          //5
                          DropdownMenuItem(
                            value: 'm.tkngh.jp',
                            child: Text('m.tkngh.jp'),
                          ),
                          DropdownMenuItem(
                            value: 'koliosky.com',
                            child: Text('koliosky.com'),
                          ),
                          DropdownMenuItem(
                            value: 'exekey.net',
                            child: Text('exekey.net'),
                          ),
                          DropdownMenuItem(
                            value: 'love.xn--vusz0j.life',
                            child: Text('love.幼女.life'),
                          ),
                          DropdownMenuItem(
                            value: 'misskey.network',
                            child: Text('misskey.network'),
                          ),
                          DropdownMenuItem(
                            value: 'mi.okin-jp.net',
                            child: Text('mi.okin-jp.net'),
                          ),
                        ],
                        //6
                        onChanged: (String? value) {
                          setState(() {
                            isSelectedItem = value??"m.tkngh.jp";
                          });
                        },
                        //7
                        value: isSelectedItem,
                      ),
                      loginButton(isSelectedItem),
                      TextField(
                        onChanged: (text)=>{
                          TOKEN = text
                        },
                        decoration: const InputDecoration(
                          hintText: "トークンを入力"
                        ),
                      ),
                      ElevatedButton(onPressed: () async {
                        var check = await loginWithToken(isSelectedItem, TOKEN);
                        if(check!="true"){
                          await Fluttertoast.showToast(msg: "ログインできませんでした",fontSize: 18);
                        }else{
                          await Fluttertoast.showToast(msg: "ログインしました。再起動してください。",fontSize: 18);
                        }
                        }, child: const Text("トークンでログイン")
                      ),
                      ElevatedButton(onPressed: (){logout();}, child: const Text("修復"))
                    ]
                  );
                }
              } else {
                return loginButton(isSelectedItem);
              }
            }
        )
      )
    );
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
    return ElevatedButton(onPressed: () {auth(instance);}, child: const Text("ログイン"));
  }
  saveHost(instance) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("host", instance);
  }
  Future<String> getIconImage() async{
    var token = sysAccount().getToken();
    final Uri uri = Uri.parse("https://m.tkngh.jp/api/i");
    Map<String, String> headers = {'content-type': 'application/json'};
    final response = await http.post(uri,headers: headers, body: json.encode({"i": token}));
    final String res = response.body;
    Map<String, dynamic> map = jsonDecode(res);
    String url = map["avatarUrl"];
    return url;
  }

  Future<String> loginWithToken(String isSelectedItem, String T) async {
    _MyHomePageState().saveHost(isSelectedItem);
    String host = isSelectedItem;
    String TOKEN = T;
    if(TOKEN=="null"){
      return "false";
    }
    final Uri uri = Uri.parse("https://$host/api/i");
    Map<String, String> headers = {'content-type': 'application/json'};
    final response = await http.post(uri,headers: headers, body: json.encode({"i": TOKEN}));
    final String res = response.body;
    Map<String, dynamic> map = jsonDecode(res);
    if(map["name"] != null){
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var accountPos = (prefs.getInt('counter') ?? 0);
      if(accountPos == 0) {
        prefs.setInt("counter", 1);
        prefs.setInt("selection", 1);
        prefs.setString("1", TOKEN);
      }
      return "true";
    }else{
      return "false";
    }
  }
}

auth(instance){
  _MyHomePageState().saveHost(instance);
  const uid = Uuid();
  String url = 'https://$instance/miauth/${uid.v5(uid.v4(), 'tkngh')}?name=TKNGHAPP&permission=read:account,write:account,write:notes,read:notifications,write:notifications,read:blocks,write:blocks,read:drive,write:drive,read:favorites,write:favorites,read:following,write:following,read:messaging,write:messaging,read:mutes,write:mutes,write:reactions,write:votes,read:pages,write:pages,write:page-likes&callback=misskey://tkngh/?mode=auth';
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
  if(map["ok"]==true){
    var accountPos = (prefs.getInt('counter') ?? 0);
    if(accountPos == 0){
      prefs.setInt("counter",1);
      prefs.setInt("selection",1);
      prefs.setString("1", map["token"]);
    }
    return "ログインしました。アプリを再起動してください。";
  }else{
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
  if(token=="null"){
    return "false";
  }
  final Uri uri = Uri.parse("https://$host/api/i");
  Map<String, String> headers = {'content-type': 'application/json'};
  final response = await http.post(uri,headers: headers, body: json.encode({"i": token}));
  final String res = response.body;
  Map<String, dynamic> map = jsonDecode(res);
  if(map["name"] != null){
    iconImage = map["avatarUrl"];
    return map["name"];
  }else{
    return "false";
  }
}

Future<Map<String,String>> getEmoji() async{
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
  if(prefs.getInt("counter") != null){
    if(prefs.getInt("counter") == 1){
      if (kDebugMode) {
        print("counter is exist");
      }
      //この時点で、ログアウトは確定。counterを0にして、トークンを削除する。
      await prefs.remove(prefs.getInt("selection").toString());
      await prefs.setInt("counter",((prefs.getInt("counter")??1) - 1));
      await prefs.remove("host");
    }else{
      //違うのであれば、1のトークンを削除後、すべてずらす(くそめんどい)
      if (kDebugMode) {
        print("non");
      }
    }
  }else{
    //counterの値が何らかの理由によって存在しない場合は、データを直接抹消してよい。
    await prefs.remove(prefs.getInt("selection").toString());
    await prefs.remove("counter");
    await prefs.remove("selection");
    await prefs.remove("host");
    if (kDebugMode) {
      print("Counter is not found");
    }
  }
  MyApp;
  //main();
  //exit(0);
}