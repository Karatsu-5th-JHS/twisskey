import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmojiControl {
  late Map<String, String> emojiList = {};

  void firstAddEmojis() {
    Future(() async {
      Fluttertoast.showToast(msg: "絵文字の取得を開始しました");
      SharedPreferences instance = await SharedPreferences.getInstance();
      String? tmp = instance.getString("hosts").toString();
      List<String> hosts = json.decode(tmp).cast<String>().toList();
      for (var host in hosts) {
        final response = await http.get(
            Uri(scheme: "https", host: host, pathSegments: ["api", "emojis"]));
        if(response.statusCode == 404){
          continue;
        }
        emojiList.addAll(Map.fromEntries((jsonDecode(response.body)["emojis"]
                as List)
            .map((e) => MapEntry(e["name"] as String, e["url"] as String))));
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("emojis", jsonEncode(emojiList).toString());
      }
      String? host = instance.getString("host");
      final response = await http.get(
          Uri(scheme: "https", host: host, pathSegments: ["api", "emojis"]));
      emojiList.addAll(Map.fromEntries((jsonDecode(response.body)["emojis"]
      as List)
          .map((e) => MapEntry(e["name"] as String, e["url"] as String))));
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("emojis", jsonEncode(emojiList).toString());
      Fluttertoast.showToast(msg: "絵文字の取得が完了しました");
    });
  }

  void saveHosts(hostname){
    Future(() async{
      SharedPreferences instance = await SharedPreferences.getInstance();
      String? tmp = instance.getString("hosts").toString();
      String tmp2 = "";
      print("converting tmp to tmp2");
      tmp2 = tmp;
      if(tmp2 == "null"){
        tmp2 = "[]";
      }
      List<String>hostList = json.decode(tmp2).cast<String>().toList();
      bool flag = false;
      List<String> hosts = [];
      for (var element in hostList) {
        if(element == hostname){
          flag = true;
        }
        hosts.add(json.encode(element));
      }
      if(flag == false){
        print("saving hosts...");
        hosts.add(json.encode(hostname));
        instance.setString("hosts",hosts.toString());
      }
    });
  }
}
