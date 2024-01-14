
import 'dart:convert';

import 'package:twisskey/main.dart';
import 'package:http/http.dart' as http;


class DoingRenote {
  Future<String> renote(id) async{
    var token = await getToken();
    var host = await getHost();
    final Uri uri = Uri.parse("https://$host/api/notes/create");
    Map<String, String> headers = {'Content-Type': 'application/json',"charset":'UTF-8'};
    final body = {"renoteId": id, "i":token};
    final response = await http.post(uri,headers: headers, body: jsonEncode(body));
    final String res = response.body;
    Map<String, dynamic> map = jsonDecode(res);
    return map["createdNote"]["id"];
  }
}