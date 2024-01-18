
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:twisskey/api/myAccount.dart';

class DriveControl{
  Future<String> create(String path, String name) async{
    Fluttertoast.showToast(msg: "アップロードしています", fontSize: 18);
    var token = await sysAccount().getToken();
    var host = await sysAccount().getHost();
    final Uri uri = Uri.parse("https://$host/api/drive/files/create");
    const String method = "post";


    final res = await multipart(
      method: method,
      url: uri,
      files: [
        http.MultipartFile.fromBytes(
          'file',
          File(path).readAsBytesSync(),
        ),
      ],
      token: token
    );
    print("drive response:" + res.body);
    Map<String, dynamic> map = json.decode(res.body);
    if(map["error"]!=null) {
      Fluttertoast.showToast(msg: "アップロードに失敗しました", fontSize: 18);
      return "fail";
    }else{
      var fileId = map["id"];
      Fluttertoast.showToast(msg: "アップロードしました", fontSize: 18);
      return fileId;
    }
  }
  Future<http.Response> multipart({
    required String method,
    required Uri url,
    required String token,
    required List<http.MultipartFile> files,
  }) async {
    final request = http.MultipartRequest(method, url);

    request.files.addAll(files); // 送信するファイルのバイナリデータを追加
    request.headers.addAll({'Authorization': 'Bearer $token'}); // 認証情報などを追加

    final stream = await request.send();

    return http.Response.fromStream(stream).then((response) {
      if (response.statusCode == 200) {
        return response;
      }

      return Future.error(response);
    });
  }
  
  Future<String> show({
    required String id
}) async {
    var token = await sysAccount().getToken();
    var host = await sysAccount().getHost();
    final Uri uri = Uri.parse("https://$host/api/drive/files/show");
    final request = http.post(uri);
    Map<String, String> headers = {'Content-Type': 'application/json',"charset":'UTF-8'};
    final body = {"fileId": id, "i":token};
    final response = await http.post(uri,headers: headers, body: jsonEncode(body));
    final res = response.body;
    print(res);
    if(res == null || res == ""){
      return "fail";
    }
    final Map<String, dynamic>map = jsonDecode(res);
    return map["thumbnailUrl"];
  }
}