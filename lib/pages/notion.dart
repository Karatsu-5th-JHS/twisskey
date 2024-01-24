import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mfm/mfm.dart';
import 'package:twisskey/api/myAccount.dart';
import 'package:twisskey/main.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:http/http.dart' as http;
import 'package:twisskey/pages/note.dart';
import 'package:twisskey/timelinePage.dart';

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
    var token = await sysAccount().getToken();
    var host = await sysAccount().getHost();
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
      bottomNavigationBar: BottomAppBar(child: Center(child: Padding( padding: const EdgeInsets.symmetric(horizontal: 1.0),
          child:Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(onPressed: (){Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>const TimelinePage()));}, icon: const Icon(Icons.home)),
              IconButton(onPressed: (){Fluttertoast.showToast(msg: "PushSearch",fontSize: 18);}, icon: const Icon(Icons.search)),
              IconButton(onPressed: (){
                Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>const notion()));
              }, icon: const Icon(Icons.notifications)),
              IconButton(onPressed: (){Fluttertoast.showToast(msg: "PushMes",fontSize: 18);}, icon: const Icon(Icons.mail)),
              IconButton(onPressed: (){Fluttertoast.showToast(msg: "PushMenu",fontSize: 18);}, icon: const Icon(Icons.menu))
            ],
          ))),),
      body: RefreshIndicator(
        onRefresh: () async {
          setState((){
            _notificationFuture = _notificationLoading();
          });
        },
      child: FutureBuilder<dynamic> (
          future: _notificationFuture,
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
                      var user = "";
                      var noteText = "";
                      if(feed['type']=="app") {
                        matsubi = feed["body"];
                        user = feed["header"];
                      }

                      if(feed["user"]==null && user == ""){
                        user = "NAME FETCH IS FAILED";
                      }else if(feed["user"]!=null && user==""){
                        if(feed["user"]["name"] == null){
                          user = feed["user"]["username"];
                        }else {
                          user = feed["user"]["name"];
                        }
                      }
                      var id = "0x0000";
                      if(feed['type']=="reaction") {
                        if(feed['note']["text"] != null){
                          noteText = feed['note']["text"];
                        }else{
                          noteText = "画像のみの投稿です。";
                        }
                        matsubi = "このノートが$userにリアクションされました。\n$noteText";
                        icons = const Icon(Icons.add);
                        id = feed["note"]["id"];
                      }else if(feed['type']=="renote"){
                        if(feed['note']["text"] != null){
                          noteText = feed['note']["text"];
                        }else{
                          noteText = "画像のみの投稿です。";
                        }
                        matsubi = "このノートが$userにリノートされました\n$noteText";
                        icons = const Icon(Icons.repeat);
                        id = feed["note"]["id"];
                      }else if(feed['type']=="note") {
                        matsubi = "$userの新しいノート";
                        icons = const Icon(Icons.comment_outlined);
                        id = feed["note"]["id"];
                      }else{
                        matsubi = "通知を認識できませんでした";
                        icons = const Icon(Icons.question_mark);
                      }
                      final text = matsubi;
                      final createdAt = DateTime.parse(feed["createdAt"]).toLocal();
                      if (kDebugMode) {
                        print("$user:$text");
                      }
                      return Column(children: [
                        InkWell(
                          onTap: () => {
                            Navigator.push(context,MaterialPageRoute(builder: (context)=>viewNote(noteId: id)))
                          },
                          child: Container(
                              padding: const EdgeInsets.only(left: 8.0,bottom: 8.0,right:8.0),
                              child: Column(
                                  children:[
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          child: icons,
                                        ),
                                        const SizedBox(width: 8.0),
                                        Flexible(
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
                                                          mfmText: "**$user**",
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
                                              Text(matsubi,overflow: TextOverflow.ellipsis,),
                                            ],
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