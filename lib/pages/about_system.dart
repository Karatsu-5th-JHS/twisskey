import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mfm/mfm.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SystemAbout extends StatelessWidget{
  const SystemAbout({super.key});
  @override
  Widget build(BuildContext context) {
    String? data = "";
    return Scaffold(
      appBar: AppBar(
        title: const Text("About this app"),
      ),
      body: FutureBuilder<String>(
        future: getVersionInfo(),
        builder: (context, ss){
        if (ss.connectionState == ConnectionState.done) {
          if (ss.hasData) {
            data = ss.data;
          }else {
            data = "取得できません";
          }
          return Container(
            padding: const EdgeInsets.only(
                top: 10, left: 20, right: 20, bottom: 5),
            child: Column(
              children: [
                Mfm(
                  mfmText: data,
                )
              ],
            ),
          );
        }else{
          return Text("failed to fetch");
        }
      }),
    );
  }

  Future<String> getVersionInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var base = '<center>\$[x3 **about Twisskey**]</center>\n\$[x2 TwisskeyはFlutterで作成されたTwitter風Misskeyクライアントアプリです。\n\n\n現在のバージョン: ';
    var text = '${packageInfo.version}(${packageInfo.buildNumber})';
    if(kDebugMode){
      text = "${text} | bata";
    }
    text = base + text + "\n\nこのアプリは、**Miria**で使われている[Mfm_parser](https://pub.dev/packages/mfm_parser)を利用しています。]\n\nApplication created by: 德永皓斗\n対応OS: Android 5.2以上 / iOS 12以上"
        "\n"
        "\n"
        "Language: Flutter\n"
        "Dev. env: Android Studio 2023.1.1 on Windows 11\n"
        "Github: [唐津第五中学校/Twisskey](https://github.com/Karatsu-5th-JHS/twisskey)";
    return text;
  }
}