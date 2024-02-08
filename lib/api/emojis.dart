import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmojiControl {
  late Map<String, String> emojiList = {};

  void firstAddEmojis() {
    Future(() async {
      final host = {
        "misskey.io",
        "m.tkngh.jp",
        "momo.dosuto.net",
        "mi.taichan.site",
        "misskey.backspace.fm",
        "stg.miria.shiosyakeyakini.info",
        "mkkey.net",
        "fw3rd-bc.jp",
        "koliosky.com",
        "misskey.network",
        "exekey.net",
        "k.lapy.link"
      };
      for (var host in host) {
        final response = await http.get(
            Uri(scheme: "https", host: host, pathSegments: ["api", "emojis"]));
        emojiList.addAll(Map.fromEntries((jsonDecode(response.body)["emojis"]
                as List)
            .map((e) => MapEntry(e["name"] as String, e["url"] as String))));
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("emojis", jsonEncode(emojiList).toString());
      }
      ;
    });
  }
}
