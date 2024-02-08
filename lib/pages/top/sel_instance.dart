import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:twisskey/authenticate.dart';
import 'package:twisskey/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:twisskey/timelinePage.dart';
import 'package:uni_links/uni_links.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  _LoginScreen createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  TextEditingController t_instance = TextEditingController();
  TextEditingController t_token = TextEditingController();

  StreamSubscription? _sub;
  String? catchLink;
  String? parameter;

  @override
  void initState() {
    init();
    super.initState();
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
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TimelinePage()));
            } else {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Authenticate(session: session)));
            }
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.of(context)!.login),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: t_instance,
                  decoration: const InputDecoration(
                      hintText: "インスタンスのホストを入力",
                      label: Text("サーバーホスト"),
                      prefixText: "https://",
                      suffixText: "/",
                      prefixIcon: Icon(Icons.dns_outlined)),
                )),
            Container(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: t_token,
                  decoration: const InputDecoration(
                      hintText: "トークンを入力してログインする",
                      label: Text("トークン"),
                      prefixIcon: Icon(Icons.key_outlined)),
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  child: loginButton(t_instance.text),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    child: const Text("Login with Token"),
                    onPressed: () =>
                        loginWithToken(t_instance.text, t_token.text, context),
                  ),
                )
              ],
            ),
            ElevatedButton(
                onPressed: () => {logout()},
                child: Text(L10n.of(context)!.repair))
          ],
        ),
      ),
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
}

saveHost(instance) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("host", instance);
}

Future<String> loginWithToken(String isSelectedItem, String T, context) async {
  saveHost(isSelectedItem);
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
    Fluttertoast.showToast(msg: "ログインしました");
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const TimelinePage()));
    return "true";
  } else {
    return "false";
  }
}
