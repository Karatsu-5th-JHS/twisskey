
import 'dart:convert';

import 'package:blur/blur.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mfm/mfm.dart';
import 'package:twisskey/api/myAccount.dart';
import 'package:twisskey/api/reaction.dart';
import 'package:twisskey/api/renote.dart';
import 'package:twisskey/main.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;

class viewNote extends StatefulWidget{
  final String noteId;
  const viewNote({Key? key, required this.noteId}) : super(key:key);
  @override
  State<viewNote> createState() => _noteViewPage(noteId);
}

class _noteViewPage extends State<viewNote>{
  final String noteId;
  Map<String,String> emojiList = {};

  _noteViewPage(this.noteId);
  @override
  void initState() {
    super.initState();
    loadEmoji();
    if(noteId=="0x0000"){
      Navigator.pop(context);
    }
    _timelineFuture = _fetchNote(noteId);
    if (kDebugMode) {
      print(noteId);
    }
  }
  Future loadEmoji() async{
    emojiList = await getEmoji();
  }

  Future<dynamic> getIcon(String noteId) async {
    var result = "";
    /*DoReaction().get(noteId).then((value) => {
      if(value != ""){
        result = const Icon(Icons.favorite)
      }else{
        result = const Icon(Icons.favorite_outline)
      }
    });*/
    String res = await DoReaction().get(noteId);
    if(res != ""){
      result = "yes";
    }else{
      result = "no";
    }
    return result;
  }

  late Future<dynamic> _timelineFuture;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("ツイート")
        ),
        body: FutureBuilder<dynamic>(
        future: _timelineFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return ListView.separated(
                itemCount: snapshot.data!.length,
                separatorBuilder: (BuildContext context, int index) => Divider(color: Colors.grey.shade400,),
                itemBuilder: (context, index){
                  var feed = snapshot.data![index];
                  late Future<dynamic> _react;

                  if(feed == null){
                    //exit(0);
                    return const Text("null");
                  }
                  var Renote = "";
                  if(feed["text"] == null){
                    if((!(feed["renoteId"]?.isEmpty ?? true)) && (feed["fileids"]?.isEmpty ?? true)) {
                      Renote = feed["user"]["name"] + "さんがRenoteしました";
                      feed = feed["renote"];
                      if(feed["text"] == null){
                        feed["text"] = null;
                      }
                    }else{
                      feed["text"] = null;
                    }
                  }
                  final text = feed["text"];
                  final author = feed["user"];
                  final String avatar = feed["user"]["avatarUrl"];
                  final createdAt = DateTime.parse(feed["createdAt"]).toLocal();
                  final id = feed["id"].toString();
                  var instance = "";
                  if(feed["user"]["host"] != null){
                    instance = '@${feed["user"]["host"]}';
                  }
                  if(author["name"]==null){
                    author["name"] = "";
                  }
                  _react = getIcon(feed["id"]);
                  return Column(children: [
                    InkWell(
                      child: Container(
                        padding: const EdgeInsets.only(left: 8.0,bottom: 8.0,right:8.0),
                        child: Column(
                          children:[
                            Text(Renote, style: const TextStyle(color: Colors.green)),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(author['avatarUrl']),
                                  radius: 24,
                                ),
                              const SizedBox(width: 8.0),
                              Flexible(
                                child: Container(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children:[
                                            Row(
                                                mainAxisAlignment: MainAxisAlignment. spaceAround,
                                                children: [
                                                  Flexible(
                                                      child: Mfm(
                                                        mfmText: "${"**" + author["name"]}**",
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
                                                  Flexible(
                                                    child: Text(
                                                        '@${author['username']}$instance',
                                                        overflow: TextOverflow.ellipsis,
                                                  ),
                                                  ),
                                                  Text(
                                                    timeago.format(createdAt, locale: "ja"),
                                                    style: const TextStyle(fontSize: 12.0),
                                                    overflow: TextOverflow.clip,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10.0),
                                              checkImageOrText(text, feed["files"]),
                                          Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                TextButton(onPressed: ()=>{Fluttertoast.showToast(msg: "リプライ",fontSize: 18)}, child: const Icon(Icons.reply)),
                                                TextButton(onPressed: () {
                                                  DoingRenote().check(id).then((value) => {
                                                    if(value == 1){
                                                      showDialog<void>(
                                                          builder: (context) {
                                                            return AlertDialog(
                                                              title: const Text("再リツイート警告"),
                                                              content: const Text("このツイートはすでにリツイート済みです。再リツイートしますか？(この警告は将来的に設定で無効化できます)"),
                                                              actions: <Widget>[
                                                                GestureDetector(
                                                                  child: Container(
                                                                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                                                                    child: const Text("いいえ"),
                                                                  ),
                                                                  onTap: () {
                                                                    Navigator.pop(context);
                                                                  },
                                                                ),
                                                                GestureDetector(
                                                                  child: Container(
                                                                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                                                                    child: const Text("はい"),
                                                                  ),
                                                                  onTap: () {
                                                                    DoingRenote().renote(feed["id"]);
                                                                    Fluttertoast.showToast(msg: "リツイートしました",fontSize: 18);
                                                                    Navigator.pop(context);
                                                                  },
                                                                )
                                                              ],
                                                            );
                                                          }, context: context)
                                                    }else{
                                                      DoingRenote().renote(feed["id"]),
                                                      Fluttertoast.showToast(msg: "リツイートしました",fontSize: 18)
                                                    }
                                                  });
                                                }
                                                  ,child: Row(
                                                    children: [
                                                      const Icon(Icons.repeat),
                                                      Text(feed["renoteCount"].toString())
                                                    ],
                                                  ),
                                                ),
                                                TextButton(onPressed: () {DoReaction().check(feed["id"], "❤").then((value) => setState(() {
                                                  _react = getIcon(feed["id"]);
                                                }));},
                                                    child: FutureBuilder<dynamic>(
                                                        future: _react,
                                                        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshottt) {
                                                          if (snapshottt
                                                              .connectionState !=
                                                              ConnectionState
                                                                  .done) {
                                                            return Icon(Icons.favorite_outline);
                                                          }
                                                          if (snapshottt
                                                              .hasData) {
                                                            print(snapshottt.data);
                                                            if(snapshottt.data=="yes") {
                                                              return const Icon(
                                                                  Icons
                                                                      .favorite);
                                                            }else{
                                                              return Icon(Icons.favorite_outline);
                                                            }
                                                          } else {
                                                            return const Icon(Icons
                                                                .favorite_outline);
                                                          }
                                                        })),
                                                TextButton(onPressed: ()=>{Fluttertoast.showToast(msg: "その他メニュー",fontSize: 18)},child: const Icon(Icons.more_horiz))
                                              ]
                                          ),
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
        return const Center(child: CircularProgressIndicator());
      }
    }else{
        return const Center(child: CircularProgressIndicator());
    }
    }
    ));
  }

  Future<dynamic> _fetchNote(id) async {
    var token = await sysAccount().getToken();
    var host = await sysAccount().getHost();
    final Uri uri = Uri.parse("https://$host/api/notes/show");
    Map<String, String> headers = {'content-type': 'application/json'};
    final response = await http.post(
        uri, headers: headers, body: json.encode({"i": token, "noteId":id}));
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
  Widget checkImageOrText(text, image){
    if (kDebugMode) {
      print(image);
    }
    if(text != null){
      if(!image.isEmpty){
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Mfm(
              mfmText: text,
              linkTap: (url) {
                launchUrl(Uri.parse(url));
              },
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
              },
              searchTap: (content){
                content = content.replaceAll(" ", "+");
                if (kDebugMode) {
                  print("Search tapped! content=>search?q=$content");
                }
                launchUrl(Uri.parse("https://www.google.com/search?q=$content"));
              },
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for(var file in image)
                    isNeedBlur(file)
                ],
              ),
            )
          ],
        );
      }
      return Mfm(
        mfmText: text,
        linkTap: (url) {
          launchUrl(Uri.parse(url));
        },
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
        },
        searchTap: (content){
          content = content.replaceAll(" ", "+");
          if (kDebugMode) {
            print("Search tapped! content=>search?q=$content");
          }
          launchUrl(Uri.parse("https://www.google.com/search?q=$content"));
        },
      );
    }else{
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for(var file in image)
              isNeedBlur(file)
          ],
        ),
      );
    }
  }
  Widget isNeedBlur(sensitiveFlug){
    var image = sensitiveFlug["url"];
    var sf = sensitiveFlug["isSensitive"];
    if (kDebugMode) {
      print("isSensitive:$sf");
    }
    if(sf == true){
      if (kDebugMode) {
        print("Blur skip");
      }
      return Blur(
        child: SizedBox(
          height: 300,
          width: 300,
          child: Image.network(image,width: 300,height: 300),
        ),
      );
    }else{
      return Image.network(image,width: 300,height: 300);
    }
  }
}