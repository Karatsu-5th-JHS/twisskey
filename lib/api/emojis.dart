import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:twisskey/api/notify/service.dart';

class EmojiControl {
  late Map<String, String> emojiList = {};
  /*double currentProgress(int index) {
    //fetch the current progress,
    //its in a list because we might want to download
    // multiple files at the same time,
    // so this makes sure the correct download progress
    // is updated.
    try {
      return _progressList[index];
    } catch (e) {
      _progressList.add(0.0);
      return 0;
    }
  }*/

  void firstAddEmojis() {
    NotificationService notificationService = NotificationService();
    int count = 0;
    Future(() async {
      SharedPreferences instance = await SharedPreferences.getInstance();
      String? tmp = instance.getString("hosts").toString();
      List<String> hosts = json.decode(tmp).cast<String>().toList();
      int total = hosts.length;
      for (var host in hosts) {
        count = count + 1;
        notificationService.createNotification(
            100, ((count / total) * 100).toInt(), 0, host,true,"processing...");
        final response = await http.get(
            Uri(scheme: "https", host: host, pathSegments: ["api", "emojis"]));
        if(response.statusCode == 404){
          continue;
        }else if(response.statusCode == 405){
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
      notificationService.cancel(0);
      notificationService.createNotification(100, 100, 1, "絵文字のダウンロードが完了",false,"処理は正常に完了しました");
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
