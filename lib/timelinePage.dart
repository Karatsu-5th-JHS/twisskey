import 'dart:convert';
import 'dart:io';

import 'package:blur/blur.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mfm/mfm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twisskey/api/myAccount.dart';
import 'package:twisskey/api/reaction.dart';

import 'package:twisskey/api/renote.dart';
import 'package:twisskey/main.dart';
import 'package:twisskey/newTweet.dart';

import 'package:http/http.dart' as http;
import 'package:twisskey/pages/about_system.dart';
import 'package:twisskey/pages/note.dart';
import 'package:twisskey/pages/notion.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;

class TimelinePage extends StatefulWidget {
  const TimelinePage({Key? key}) : super(key: key);

  @override
  State<TimelinePage> createState() => _TimeLinePage();
}

class _TimeLinePage extends State<TimelinePage> {
  var firstLoaded = false;
  Map<String,String> emojiList = {};
  final focusNode = FocusNode();
  newTweet nt = const newTweet();

  @override
  void initState() {
    super.initState();
    loadEmoji();
    _timelineFuture = _fetchTimeline();
  }

  late Future<dynamic> _timelineFuture;

  Future loadEmoji() async{
    emojiList = await getEmoji();
  }

  Future<dynamic> _fetchTimeline() async {
    var token = await sysAccount().getToken();
    var host = await sysAccount().getHost();
    final Uri uri = Uri.parse("https://$host/api/notes/timeline");
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

  //絵文字の更新 Update emojis
  void updateEmojisFromServer() {
    //super.didChangeDependencies();
    Future(() async {
      String? host;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("絵文字DL元のサーバーURLを入力"),
          content: TextFormField(
            onFieldSubmitted: (data) {
              host = data;
              Navigator.of(context).pop();
            },
            decoration: const InputDecoration(
                hintText:
                "Please input misskey server host (such as misskey.io) to fetch emojis."),
          ),
        ),
      );
      if (host == null) return;

      final response = await http.get(
          Uri(scheme: "https", host: host, pathSegments: ["api", "emojis"]));
      setState(() {
        emojiList.addAll(Map.fromEntries(
            (jsonDecode(response.body)["emojis"] as List)
                .map((e) => MapEntry(e["name"] as String, e["url"] as String))));
        focusNode.requestFocus();
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("emojis", jsonEncode(emojiList).toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Row(children: [
            Image(
                image: AssetImage('asset/tkngh.png'), width: 20, height: 20),
            Text("TKNGH")
          ],),
          actions: [IconButton(
            icon: const Icon(Icons.download_for_offline_outlined),
            tooltip: 'Cache emojis from instances.',
            onPressed: () {
              updateEmojisFromServer();
            },
          )],
        ),

        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text('Drawer Header'),
              ),
              ListTile(
                title: const Text('About'),
                onTap: () {
                  // Do something
                  Navigator.push(context,MaterialPageRoute(builder: (context)=>const SystemAbout()));
                },
              ),
              ListTile(
                title: const Text('Logout'),
                onTap: () {
                  // Do something
                  logout();
                },
              ),
            ],
          ),
        ),
        floatingActionButton: Transform.scale(
          scale: 1.2,
            child: FloatingActionButton(
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context)=>const newTweet())
                );
                setState(() {
                  _timelineFuture = _fetchTimeline();
                });
              },
              shape: const StadiumBorder(),
              backgroundColor: const Color.fromRGBO(150, 191, 235, 1),
              foregroundColor: const Color.fromRGBO(255, 255, 255, 1),
              child: const Icon(Icons.add),
            )
        ),
        bottomNavigationBar: BottomAppBar(child: Center(child: Padding( padding: const EdgeInsets.symmetric(horizontal: 1.0),
        child:Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(onPressed: (){Fluttertoast.showToast(msg: "PushHome",fontSize: 18);}, icon: const Icon(Icons.home)),
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
              setState(() {
                loadEmoji();
                _timelineFuture = _fetchTimeline();
              });
            },
            child: FutureBuilder<dynamic>(
                future: _timelineFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      firstLoaded = true;
                      return ListView.separated(
                          itemCount: snapshot.data!.length,
                          separatorBuilder: (BuildContext context, int index) => Divider(color: Colors.grey.shade400,),
                          itemBuilder: (context, index){
                            late Future<dynamic> react;
                            var feed = snapshot.data![index];
                            if(feed == null){
                              exit(0);
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
                            final createdAt = DateTime.parse(feed["createdAt"]).toLocal();
                            final id = feed["id"].toString();
                            /*final int isRenote = await DoingRenote().check(id);
                            if (kDebugMode) {
                              print(isRenote);
                            }
                            */
                            var instance = "";
                            if(feed["user"]["host"] != null){
                              instance = '@${feed["user"]["host"]}';
                            }
                            if(author["name"]==null){
                              author["name"] = "";
                            }

                            react = getIcon(feed["id"]);

                            return Column(children: [
                              InkWell(
                                onTap: () => {
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>viewNote(noteId: id)))
                                },
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
                                                                mfmText: "**${author["name"]}**",
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
                                                              /*Text(
                                                              author['name'],
                                                              overflow: TextOverflow.ellipsis,
                                                              style:
                                                              const TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                                                            ),*/
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
                                                      /*Text(text,
                                                                                                style: const TextStyle(fontSize: 15.0)),*/
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
                                                          TextButton(onPressed: () async {DoReaction().check(feed["id"], "❤");setState(() {
                                                            react = getIcon(feed["id"]);
                                                          });},
                                                              child: FutureBuilder<dynamic>(
                                                                  future: react,
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
                                                                return Icon(
                                                                    Icons
                                                                        .favorite);
                                                              }else{
                                                                return Icon(Icons.favorite_outline);
                                                              }
                                                            } else {
                                                              return Icon(Icons
                                                                  .favorite_outline);
                                                            }
                                                          })),
                                                          TextButton(onPressed: ()=>{Fluttertoast.showToast(msg: "その他メニュー",fontSize: 18)},child: const Icon(Icons.more_horiz))
                                                        ]
                                                      ),
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
                    }else {
                      //print(getHost());
                      return const Center(child: Text('タイムラインの取得に失敗しました'));
                    }
                  } else {
                    if(firstLoaded != true) {
                      return const Center(child: Text("読み込み中です"));
                    }else{
                      return const Center(child: CircularProgressIndicator());
                    }
                  }
                }
            )
        )
    );
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
      return GestureDetector(child:Blur(
        child: SizedBox(
          height: 300,
          width: 300,
          child: Image.network(image,width: 300,height: 300),
        ),
      ));
    }else{
      return Image.network(image,width: 300,height: 300);
    }
  }

}