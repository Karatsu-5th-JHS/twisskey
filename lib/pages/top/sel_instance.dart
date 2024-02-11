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
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';

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
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                      hintText: L10n.of(context)!.guide_input_instanse_url,
                      label: Text(L10n.of(context)!.guide_label_server_host),
                      prefixText: "https://",
                      suffixText: "/",
                      prefixIcon: Icon(Icons.dns_outlined)),
                )),
            Container(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: t_token,
                  decoration: InputDecoration(
                      hintText: L10n.of(context)!.input_token,
                      label: Text(L10n.of(context)!.token),
                      prefixIcon: const Icon(Icons.key_outlined)),
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
                    child: Text(L10n.of(context)!.login_with_token),
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
          Fluttertoast.showToast(msg: instance + "で認証を開始します");
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

auth(instance) {
  saveHost(instance);
  const uid = Uuid();
  String url =
      'https://$instance/miauth/${uid.v5(uid.v4(), 'tkngh')}?name=TKNGHAPP&permission=read:account,write:account,write:notes,read:notifications,write:notifications,read:blocks,write:blocks,read:drive,write:drive,read:favorites,write:favorites,read:following,write:following,read:messaging,write:messaging,read:mutes,write:mutes,write:reactions,write:votes,read:pages,write:pages,write:page-likes&callback=misskey://tkngh/?mode=auth';
  final popUp = Uri.parse(url);
  launchUrl(popUp);
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
    Fluttertoast.showToast(msg: L10n.of(context)!.msg_login);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const TimelinePage()));
    return "true";
  } else {
    return "false";
  }
}
