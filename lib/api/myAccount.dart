import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class sysAccount {
  Future<String> getToken() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var token = sp.getString(sp.getInt("selection").toString()) ?? 'null';
    if (kDebugMode) {
      print(sp.getInt("selection"));
    }
    if (kDebugMode) {
      print("token: $token");
    }
    return token;
  }

  Future<String> getHost() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var token = sp.getString("host") ?? 'null';
    if (kDebugMode) {
      print("host: $token");
    }
    return token;
  }
  Future<Map<String, dynamic>> getUserInfo() async{
    var host = await getHost();
    var token = await getToken();
    final Uri uri = Uri.parse("https://$host/api/i");
    Map<String, String> headers = {'content-type': 'application/json'};
    final response = await http.post(uri,headers: headers, body: json.encode({"i": token}));
    final String res = response.body;
    Map<String, dynamic> map = await jsonDecode(res);
    return map;
  }
}

