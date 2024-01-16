
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:twisskey/api/convert.dart';
import 'package:http/http.dart' as http;
import 'package:twisskey/api/myAccount.dart';

class DoingRenote {
  Future<String> renote(id) async{
    var token = await sysAccount().getToken();
    var host = await sysAccount().getHost();
    final Uri uri = Uri.parse("https://$host/api/notes/create");
    Map<String, String> headers = {'Content-Type': 'application/json',"charset":'UTF-8'};
    final body = {"renoteId": id, "i":token};
    final response = await http.post(uri,headers: headers, body: jsonEncode(body));
    final String res = response.body;
    Map<String, dynamic> map = jsonDecode(res);
    return map["createdNote"]["id"];
  }

  Future<int> check(noteId) async {
    var token = await sysAccount().getToken();
    var host = await sysAccount().getHost();
    var data = await sysAccount().getUserInfo();
    var id = ConvertUserInformation.fromJson(data).id;

    final Uri uri = Uri.parse("https://$host/api/notes/renotes");
    Map<String, String> headers = {'Content-Type': 'application/json'};
    final response = await http.post(uri,headers: headers, body: json.encode({"noteId": noteId,"i": token}));

    final String res = response.body;
    var resData = json.decode(res);
    if (kDebugMode) {
      print("res:$res");
    }
    if(res == "" || res == "[]"){
      if (kDebugMode) {
        print("canceled");
      }
      return 0;
    }else {
      for(var row in resData){
        if(row["userId"] == id){
          return 1;
        }
      }
    }
    if (kDebugMode) {
      print(id);
    }
    return 0;
  }
}