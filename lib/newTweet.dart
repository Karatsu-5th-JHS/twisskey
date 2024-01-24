import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twisskey/api/drive.dart';
import 'package:twisskey/api/myAccount.dart';
import 'package:http/http.dart' as http;

class newTweet extends StatefulWidget{
  const newTweet({Key? key}) : super(key: key);
  @override
  // _MyHomePageStateを利用する
  State<newTweet> createState() => _newTweet();
}

class _newTweet extends State<newTweet>{
  late String imageState = "";
  List<String> fileIds = [];
  String? tweets = "";
  late String? body = "";
  void updateImage(id,url){
    setState(() {
      fileIds.add(id);
      imageState = url;
    });
  }
  void updateTweet(text){
    setState(() {
      body = text;
    });
  }
  @override
  Widget build(BuildContext context) {
    final ImagePicker picker = ImagePicker();
    Future<void> selectImage() async {
      final XFile? selectedImage = await picker.pickImage(source: ImageSource.gallery);

      if (selectedImage != null) {
        // 画像が選択された場合の処理を書く
        // 例えば、選択した画像のパスを表示する
        if (kDebugMode) {
          print('Selected image path: ${selectedImage.path}');
        }
          var result = await DriveControl().create(selectedImage.path, selectedImage.name);
          if(result != "fail"){
            /*setState(() {
              DriveControl().show(id: result).then((value) =>
                imageState = value
              );
            });*/
            updateImage(result,await DriveControl().show(id: result));
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
        title: const Text("ツイート"),
        actions: [
          OutlinedButton(
              onPressed: ()=>{
                doTweet(body,fileIds),
                Navigator.pop(context),
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(64, 139, 219, 1),
                foregroundColor: const Color.fromRGBO(255, 255, 255, 1),
                side: const BorderSide(
                  width: 1,
                  color: Color.fromRGBO(150, 191, 235, 1)
                )
              ),
              child: const Text("ツイート"),
          )
        ],
      ),
      body: Center(child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: sizeWidth - 20, maxHeight: sizeHeight),
        child: Column(
          children: [
            TextField(
              onChanged: (text)=>{
                updateTweet(text)
              },
              autofocus: true,
              keyboardType: TextInputType.multiline,
              minLines: 10,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: "いまどうしてる？",
              ),
            ),
            if(imageState != "")
              Image.network(imageState)
            ,
            Text(body != null?"" : ""),
            SizedBox(
              height: 30,
              child: Row(
                children: [
                  IconButton(onPressed: ()=>{
                    selectImage().then((value) => (){
                      print("select?");
                    })
                  }, icon: const Icon(Icons.image),color: Colors.blue,)
                ],
              )
            )
          ]
        )
      )
    ));
  }
  Future doTweet(String? tweet, List<String> fileIds) async{
    var token = await sysAccount().getToken();
    var host = await sysAccount().getHost();
    final Uri uri = Uri.parse("https://$host/api/notes/create");
    var body;
    Map<String, String> headers = {'Content-Type': 'application/json',"charset":'UTF-8'};
    print(fileIds.length);
    if(fileIds.length==0) {
      print("文のみ");
      body = {"text": tweet, "i": token};
    }else{
      if(tweet != "" && tweet != null) {
        print(tweet);
        print("tweet 含む");
        body = {"text": tweet, "i": token, "fileIds": fileIds};
      }else{
        body = {"i": token, "fileIds": fileIds};
      }
    }
    final response = await http.post(uri,headers: headers, body: jsonEncode(body));
    final res = response.body;
    Map<String, dynamic> map = jsonDecode(res);
    print(map["createdNote"]);
    if(map["createdNote"]==null){
      Fluttertoast.showToast(msg: "ツイートの作成に失敗しました",fontSize: 18);
      print(map);
    }else{
      Fluttertoast.showToast(msg: "ツイートしました",fontSize: 18);
    }
  }
}
