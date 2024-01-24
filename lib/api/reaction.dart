import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:twisskey/api/myAccount.dart';

class DoReaction{
  void action(String noteId, String emojiCode) async{
    var token = await sysAccount().getToken();
    var host = await sysAccount().getHost();
    final Uri uri = Uri.parse("https://$host/api/notes/reactions/create");
    Map<String, String> headers = {'Content-Type': 'application/json',"charset":'UTF-8'};
    final body = {"noteId": noteId, "reaction":emojiCode,"i":token};
    final response = await http.post(uri,headers: headers, body: jsonEncode(body));
    final res = response.body;
    if (kDebugMode) {
      print(res);
    }
  }
  Future<bool> check(String noteId, String emojiCode) async {
    var token = await sysAccount().getToken();
    var host = await sysAccount().getHost();
    var info = await sysAccount().getUserInfo();
    var id = info["id"];
    final Uri uri = Uri.parse("https://$host/api/notes/reactions");
    Map<String, String> headers = {'Content-Type': 'application/json',"charset":'UTF-8'};
    final body = {"noteId": noteId,"i":token};
    final response = await http.post(uri,headers: headers, body: jsonEncode(body));
    final String res = response.body;
    List<dynamic> list = jsonDecode(res);
    bool flug = false;
    if(list!=[] && list != "") {
      Map<String, dynamic> map = {};
      list.forEach((element) =>
      {
        map["users"] = element["user"]["id"],
        map["type"] = element["type"],
        if(map["users"] == id){
          if (emojiCode == map["type"]) {
            flug = true,
            Fluttertoast.showToast(msg: "同一のリアクションがあります")
          }
      }});
      if(flug == false){action(noteId, emojiCode);Fluttertoast.showToast(msg: "Reactioned");}
    }else{
      action(noteId, emojiCode);
      Fluttertoast.showToast(msg: "Reactioned");
    }
    return flug;
  }

  Future<Map<String,dynamic>> get(String noteId) async {
    var token = await sysAccount().getToken();
    var host = await sysAccount().getHost();
    var info = await sysAccount().getUserInfo();
    var id = info["id"];
    final Uri uri = Uri.parse("https://$host/api/notes/reactions");
    Map<String, String> headers = {'Content-Type': 'application/json',"charset":'UTF-8'};
    final body = {"noteId": noteId,"i":token};
    final response = await http.post(uri,headers: headers, body: jsonEncode(body));
    final String res = response.body;
    List<dynamic> list = jsonDecode(res);
    Map<String,dynamic> a = {"status":"no","reactions":list.length.toString()};
    if(list!=[] && list != "") {
      Map<String, dynamic> map = {};
      list.forEach((element) =>
      {
        map["users"] = element["user"]["id"],
        map["type"] = element["type"],
        if (map["users"] == id) {
          a = {"status":"yes","reactions":list.length.toString()},
        }
      });
      return a;
    }else{
      return a;
    }
  }

  Future<String> getReactions(String noteId) async {
    var token = await sysAccount().getToken();
    var host = await sysAccount().getHost();
    final Uri uri = Uri.parse("https://$host/api/notes/reactions");
    Map<String, String> headers = {'Content-Type': 'application/json',"charset":'UTF-8'};
    final body = {"noteId": noteId,"i":token};
    final response = await http.post(uri,headers: headers, body: jsonEncode(body));
    final String res = response.body;
    List<dynamic> list = jsonDecode(res);
    return list.length.toString();
  }
}