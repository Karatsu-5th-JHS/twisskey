
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:twisskey/api/myAccount.dart';
import 'package:http/http.dart' as http;

class Note{
  Future<dynamic> fetchReply(id) async {
    var token = await sysAccount().getToken();
    var host = await sysAccount().getHost();
    final Uri uri = Uri.parse("https://$host/api/notes/show");
    Map<String, String> headers = {'content-type': 'application/json'};
    final response = await http.post(
        uri, headers: headers, body: json.encode({"i": token, "noteId": id}));
    final String res = "[${response.body}]";
    if (kDebugMode) {
      print("Request showNotes: [$res]");
    }
    dynamic dj = jsonDecode(res);
    /*if((dj["error"]?.isEmpty ?? true) == false){
        print("logout");
        logout();
      }*/
    return dj;
  }

  Future<dynamic> fetchReplies(id) async {
    var token = await sysAccount().getToken();
    var host = await sysAccount().getHost();
    final Uri uri = Uri.parse("https://$host/api/notes/replies");
    Map<String, String> headers = {'content-type': 'application/json'};
    final response = await http.post(
        uri, headers: headers, body: json.encode({"i": token, "noteId": id}));
    final String res = response.body;
    dynamic dj = jsonDecode(res);
    /*if((dj["error"]?.isEmpty ?? true) == false){
        print("logout");
        logout();
      }*/
    return dj;
  }
}