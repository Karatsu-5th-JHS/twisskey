import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:twisskey/main.dart';
import 'package:http/http.dart' as http;

class newTweet extends StatelessWidget{
  const newTweet({super.key});
  @override
  Widget build(BuildContext context) {
    var sizeWidth = MediaQuery.of(context).size.width;
    var sizeHeight = MediaQuery.of(context).size.height;
    //final TextEditingController control = TextEditingController();
    var tweets = "";
    return Scaffold(
      appBar: AppBar(
        title: const Text("ツイート"),
        actions: [
          OutlinedButton(
              onPressed: ()=>{
                //doTweet(control.text),
                doTweet(tweets),
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
      body: Center(child: SizedBox(
        width: sizeWidth - 20,
        height: sizeHeight,
        child: TextField(
          onChanged: (text)=>{
            tweets = text
          },
          autofocus: true,
          keyboardType: TextInputType.multiline,
          maxLines: 60,
          decoration: const InputDecoration(
            hintText: "なにかありましたか？",
          ),
        )
      )
    ));
  }
  Future doTweet(String tweet) async{
    var token = await getToken();
    var host = await getHost();
    final Uri uri = Uri.parse("https://$host/api/notes/create");
    Map<String, String> headers = {'Content-Type': 'application/json',"charset":'UTF-8'};
    final body = {"text": tweet, "i":token};
    await http.post(uri,headers: headers, body: jsonEncode(body));
  }
}
