import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mfm/mfm.dart';
import 'package:twisskey/main.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:http/http.dart' as http;

class notion extends StatefulWidget {
  const notion({Key? key}) : super(key: key);

  @override
  State<notion> createState() => _notion();
}
class _notion extends State<notion> {
  Map<String,String> emojiList = {};
  final focusNode = FocusNode();
  late Widget icons;
  late ImageProvider notionImage;
  late Future<dynamic> _notificationFuture;
  @override
  void initState(){
    super.initState();
    loadEmoji();
    _notificationFuture = _notificationLoading();
  }

  Future loadEmoji() async{
    emojiList = await getEmoji();
  }

  Future<dynamic> _notificationLoading() async {
    var token = await getToken();
    var host = await getHost();
    final Uri uri = Uri.parse("https://$host/api/i/notifications");
    Map<String, String> headers = {'content-type': 'application/json'};
    final response = await http.post(
        uri, headers: headers, body: json.encode({"i": token, "limit": 100}));
    final String res = response.body;
    if (kDebugMode) {
      print("Request Timeline: $res");
    }
    dynamic dj = jsonDecode(res);
    /*if((dj["error"]?.isEmpty ?? true) == false){
      print("logout");
      logout();
    }*/
    return dj;
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("通知")
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState((){
            _notificationFuture = _notificationLoading();
          });
        },
      child: FutureBuilder<dynamic> (
          future: _notificationLoading(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                return ListView.separated(
                    itemCount: snapshot.data!.length,
                    separatorBuilder: (BuildContext context, int index) => Divider(color: Colors.grey.shade400,),
                    itemBuilder: (context, index){
                      var feed = snapshot.data![index];
                      if(feed == null){
                        exit(0);
                      }
                      //タイプ判別
                      var matsubi = "";
                      if(feed['type']=="reaction") {
                        matsubi = "このノートが"+feed["user"]["name"]+"にリアクションされました";
                        icons = Icon(Icons.add);
                      }else if(feed['type']=="renote"){
                        matsubi = "このノートが"+feed["user"]["name"]+"にリノートされました";
                        icons = Icon(Icons.repeat);
                      }else if(feed['type']=="note") {
                        matsubi = feed["user"]["name"]+"の新しいノート";
                        icons = Icon(Icons.comment_outlined);
                      }
                      final text = matsubi;
                      final createdAt = DateTime.parse(feed["createdAt"]).toLocal();
                      return Column(children: [
                        InkWell(
                          onTap: () => print('Tapped!'),
                          child: Container(
                              padding: const EdgeInsets.only(left: 8.0,bottom: 8.0,right:8.0),
                              child: Column(
                                  children:[
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          child: icons,
                                          radius: 24,
                                        ),
                                        const SizedBox(width: 8.0),
                                        Flexible(
                                          child: Container(
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children:[
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment. spaceAround,
                                                    children: [
                                                      Flexible(
                                                          child: Mfm(
                                                              mfmText: "${"**" + feed["user"]["name"]}**",
                                                              emojiBuilder: (context, emoji, style) {
                                                                final emojiData = emojiList[emoji];
                                                                if (emojiData == null) {
                                                                  return Text.rich(TextSpan(text: emoji, style: style));
                                                                } else {
                                                                  // show emojis if emoji data found
                                                                  return Image.network(
                                                                    emojiData,
                                                                    height: (style?.fontSize ?? 1) * 2,
                                                                  );
                                                                }
                                                              })
                                                      ),

                                                      Text(
                                                        timeago.format(createdAt, locale: "ja"),
                                                        style: const TextStyle(fontSize: 12.0),
                                                        overflow: TextOverflow.clip,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10.0),
                                                  /*Text(text,
                                                style: const TextStyle(fontSize: 15.0)),*/
                                                  Text(text),
                                                ],
                                              )
                                          ),
                                        ),
                                      ],
                                    ),
                                  ])),
                        ),
                        const Divider(height: 1, thickness: 1, color: Colors.white12)
                      ]);
                    }
                );
              }else{
                return const Text("error has occred");
              }
          }else{
              return const Center(child: CircularProgressIndicator());
            }
        })
      ),
    );
  }
}