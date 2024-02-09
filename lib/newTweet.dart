import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twisskey/api/drive.dart';
import 'package:twisskey/api/myAccount.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class newTweet extends StatefulWidget {
  const newTweet({Key? key}) : super(key: key);
  @override
  // _MyHomePageStateを利用する
  State<newTweet> createState() => _newTweet();
}

class _newTweet extends State<newTweet> {
  late String imageState = "";
  List<String> fileIds = [];
  String? tweets = "";
  late String? body = "";
  TextEditingController t_tweet = TextEditingController();

  void updateImage(id, url) {
    setState(() {
      fileIds.add(id);
      imageState = url;
    });
  }

  void updateTweet(text) {
    setState(() {
      body = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ImagePicker picker = ImagePicker();
    Future<void> selectImage() async {
      final XFile? selectedImage =
          await picker.pickImage(source: ImageSource.gallery);

      if (selectedImage != null) {
        // 画像が選択された場合の処理を書く
        // 例えば、選択した画像のパスを表示する
        if (kDebugMode) {
          print('Selected image path: ${selectedImage.path}');
        }
        var result =
            await DriveControl().create(selectedImage.path, selectedImage.name);
        if (result != "fail") {
          /*setState(() {
              DriveControl().show(id: result).then((value) =>
                imageState = value
              );
            });*/
          updateImage(result, await DriveControl().show(id: result));
        }
      } else {
        // 画像が選択されなかった場合の処理を書く
        // 例えば、エラーメッセージを表示する
        if (kDebugMode) {
          print('No image selected.');
        }
      }
    }

    var sizeWidth = MediaQuery.of(context).size.width;
    var sizeHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: Text(L10n.of(context)!.tweet),
          actions: [
            OutlinedButton(
              onPressed: () => {
                doTweet(t_tweet.text, fileIds, L10n.of(context)),
                Navigator.pop(context),
              },
              style: OutlinedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(64, 139, 219, 1),
                  foregroundColor: const Color.fromRGBO(255, 255, 255, 1),
                  side: const BorderSide(
                      width: 1, color: Color.fromRGBO(150, 191, 235, 1))),
              child: Text(L10n.of(context)!.tweet),
            )
          ],
        ),
        body: Center(
            child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: sizeWidth - 20, maxHeight: sizeHeight),
                child: Column(children: [
                  TextField(
                    controller: t_tweet,
                    autofocus: true,
                    keyboardType: TextInputType.multiline,
                    minLines: 10,
                    maxLines: 10,
                    decoration: InputDecoration(
                      hintText: L10n.of(context)!.guide_new_tweet,
                    ),
                  ),
                  if (imageState != "") Image.network(imageState),
                  Text(body != null ? "" : ""),
                  SizedBox(
                      height: 30,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => {
                              selectImage().then((value) => () {
                                    if (kDebugMode) {
                                      print("select?");
                                    }
                                  })
                            },
                            icon: const Icon(Icons.image),
                            color: Colors.blue,
                          )
                        ],
                      ))
                ]))));
  }

  Future doTweet(String? tweet, List<String> fileIds, l1) async {
    var token = await sysAccount().getToken();
    var host = await sysAccount().getHost();
    final Uri uri = Uri.parse("https://$host/api/notes/create");
    var body;
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      "charset": 'UTF-8'
    };
    if (kDebugMode) {
      print(fileIds.length);
    }
    if (fileIds.length == 0) {
      if (kDebugMode) {
        print("文のみ");
      }
      body = {"text": tweet, "i": token};
    } else {
      if (tweet != "" && tweet != null) {
        if (kDebugMode) {
          print(tweet);
        }
        if (kDebugMode) {
          print("tweet 含む");
        }
        body = {"text": tweet, "i": token, "fileIds": fileIds};
      } else {
        body = {"i": token, "fileIds": fileIds};
      }
    }
    final response =
        await http.post(uri, headers: headers, body: jsonEncode(body));
    final res = response.body;
    Map<String, dynamic> map = jsonDecode(res);
    if (kDebugMode) {
      print(map["createdNote"]);
    }
    if (map["createdNote"] == null) {
      Fluttertoast.showToast(msg: l1!.msg_failed_tweet, fontSize: 18);
      if (kDebugMode) {
        print(map);
      }
    } else {
      Fluttertoast.showToast(msg: l1!.msg_tweet, fontSize: 18);
    }
  }
}
