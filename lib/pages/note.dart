import 'dart:convert';
import 'dart:io';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mfm/mfm.dart';
import 'package:twisskey/api/emojis.dart';
import 'package:twisskey/api/myAccount.dart';
import 'package:twisskey/api/notes.dart';
import 'package:twisskey/api/reaction.dart';
import 'package:twisskey/api/renote.dart';
import 'package:twisskey/main.dart';
import 'package:http/http.dart' as http;
import 'package:twisskey/pages/viewImage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:twisskey/pages/reply.dart';

class viewNote extends StatefulWidget {
  final String noteId;
  const viewNote({Key? key, required this.noteId}) : super(key: key);
  @override
  State<viewNote> createState() => _noteViewPage(noteId);
}

class _noteViewPage extends State<viewNote> {
  final String noteId;
  Map<String, String> emojiList = {};

  _noteViewPage(this.noteId);
  @override
  void initState() {
    super.initState();
    loadEmoji();
    if (noteId == "0x0000") {
      Navigator.pop(context);
    }
    _timelineFuture = _fetchNote(noteId);
    if (kDebugMode) {
      print(noteId);
    }
  }

  Future loadEmoji() async {
    emojiList = await getEmoji();
  }

  Future<Map<String, dynamic>> getIcon(String noteId) async {
    /*DoReaction().get(noteId).then((value) => {
      if(value != ""){
        result = const Icon(Icons.favorite)
      }else{
        result = const Icon(Icons.favorite_outline)
      }
    });*/
    Map<String, dynamic> res = await DoReaction().get(noteId);
    return res;
  }

  late Future<dynamic> _timelineFuture;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(L10n.of(context)!.tweet)),
        body: FutureBuilder<dynamic>(
            future: _timelineFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return ListView.separated(
                      itemCount: snapshot.data!.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          Divider(
                            color: Colors.grey.shade400,
                          ),
                      itemBuilder: (context, index) {
                        var feed = snapshot.data![index];
                        late Future<dynamic> _react;

                        if (feed == null) {
                          //exit(0);
                          return const Text("null");
                        }
                        if (feed["text"] == null) {
                          if ((!(feed["renoteId"]?.isEmpty ?? true)) &&
                              (feed["fileids"]?.isEmpty ?? true)) {
                            feed = feed["renote"];
                            if (feed["text"] == null) {
                              feed["text"] = null;
                            }
                          } else {
                            feed["text"] = null;
                          }
                        }
                        final text = feed["text"];
                        final author = feed["user"];
                        //final String avatar = feed["user"]["avatarUrl"];
                        final createdAt =
                            DateTime.parse(feed["createdAt"]).toLocal();
                        final id = feed["id"].toString();
                        var instance = "";
                        if (feed["user"]["host"] != null) {
                          instance = '@${feed["user"]["host"]}';
                          EmojiControl().saveHosts(feed["user"]["host"]);
                        }
                        if (author["name"] == null) {
                          author["name"] = "";
                        }
                        _react = getIcon(feed["id"]);
                        return Column(children: [
                          InkWell(
                            child: Container(
                                padding: const EdgeInsets.only(
                                    left: 8.0, bottom: 8.0, right: 8.0),
                                child: Column(children: [
                                  showReply(feed["reply"]),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(author['avatarUrl']),
                                        radius: 24,
                                      ),
                                      const SizedBox(width: 8.0),
                                      Flexible(
                                        child: Container(
                                            child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Flexible(
                                                    child: Mfm(
                                                        mfmText:
                                                            "${"**" + author["name"]}**",
                                                        emojiBuilder: (context,
                                                            emoji, style) {
                                                          final emojiData =
                                                              emojiList[emoji];
                                                          if (emojiData ==
                                                              null) {
                                                            return Text.rich(
                                                                TextSpan(
                                                                    text: emoji,
                                                                    style:
                                                                        style));
                                                          } else {
                                                            // show emojis if emoji data found
                                                            return Image
                                                                .network(
                                                              emojiData,
                                                              height:
                                                                  (style?.fontSize ??
                                                                          1) *
                                                                      2,
                                                            );
                                                          }
                                                        })),
                                                Flexible(
                                                  child: Text(
                                                    '@${author['username']}$instance',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Text(
                                                  timeago.format(createdAt,
                                                      locale: "ja"),
                                                  style: const TextStyle(
                                                      fontSize: 12.0),
                                                  overflow: TextOverflow.clip,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10.0),
                                            checkImageOrText(
                                                text, feed["files"]),
                                          ],
                                        )),
                                      ),
                                    ],
                                  ),
                                  Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceEvenly,
                                      children: [
                                        TextButton(
                                            onPressed: () => {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder:
                                                          (context) {
                                                        return Reply(
                                                          id: feed["id"],
                                                        );
                                                      }))
                                            },
                                            child: const Icon(
                                                Icons.reply)),
                                        TextButton(
                                          onPressed: () {
                                            DoingRenote()
                                                .check(id)
                                                .then((value) => {
                                              if (value == 1)
                                                {
                                                  showDialog<
                                                      void>(
                                                      builder:
                                                          (context) {
                                                        return AlertDialog(
                                                          title:
                                                          Text(L10n.of(context)!.dialog_alertReReTweet_title),
                                                          content:
                                                          Text(L10n.of(context)!.dialog_alertReReTweet_body),
                                                          actions: <Widget>[
                                                            GestureDetector(
                                                              child: Container(
                                                                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                                                                child: Text(L10n.of(context)!.no),
                                                              ),
                                                              onTap: () {
                                                                Navigator.pop(context);
                                                              },
                                                            ),
                                                            GestureDetector(
                                                              child: Container(
                                                                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                                                                child: Text(L10n.of(context)!.yes),
                                                              ),
                                                              onTap: () {
                                                                DoingRenote().renote(feed["id"]);
                                                                Fluttertoast.showToast(msg: L10n.of(context)!.msg_retweeted, fontSize: 18);
                                                                Navigator.pop(context);
                                                              },
                                                            )
                                                          ],
                                                        );
                                                      },
                                                      context:
                                                      context)
                                                }
                                              else
                                                {
                                                  DoingRenote()
                                                      .renote(
                                                      feed["id"]),
                                                  Fluttertoast.showToast(
                                                      msg: L10n.of(context)!
                                                          .msg_retweeted,
                                                      fontSize:
                                                      18)
                                                }
                                            });
                                          },
                                          child: Row(
                                            children: [
                                              const Icon(
                                                  Icons.repeat),
                                              Text(feed["renoteCount"]
                                                  .toString())
                                            ],
                                          ),
                                        ),
                                        TextButton(
                                            onPressed: () {
                                              DoReaction()
                                                  .check(
                                                  feed["id"], "❤")
                                                  .then(
                                                      (value) =>
                                                      setState(
                                                              () {
                                                            _react =
                                                                getIcon(
                                                                    feed["id"]);
                                                          }));
                                            },
                                            child: FutureBuilder<
                                                dynamic>(
                                                future: _react,
                                                builder: (BuildContext
                                                context,
                                                    AsyncSnapshot<
                                                        dynamic>
                                                    snapshottt) {
                                                  if (snapshottt
                                                      .connectionState !=
                                                      ConnectionState
                                                          .done) {
                                                    return Icon(Icons
                                                        .favorite_outline);
                                                  }
                                                  if (snapshottt
                                                      .hasData) {
                                                    if (snapshottt
                                                        .data[
                                                    "status"] ==
                                                        "yes") {
                                                      return Row(
                                                          children: [
                                                            const Icon(
                                                                Icons
                                                                    .favorite),
                                                            Text(snapshottt
                                                                .data[
                                                            "reactions"])
                                                          ]);
                                                    } else {
                                                      return Row(
                                                          children: [
                                                            const Icon(
                                                                Icons
                                                                    .favorite_outline),
                                                            Text(snapshottt
                                                                .data[
                                                            "reactions"])
                                                          ]);
                                                    }
                                                  } else {
                                                    return Row(
                                                        children: [
                                                          const Icon(Icons
                                                              .favorite_outline),
                                                          Text(snapshottt
                                                              .data[
                                                          "reactions"])
                                                        ]);
                                                  }
                                                })),
                                        TextButton(
                                            onPressed: () => {
                                              Fluttertoast
                                                  .showToast(
                                                  msg:
                                                  "その他メニュー",
                                                  fontSize:
                                                  18)
                                            },
                                            child: const Icon(
                                                Icons.more_horiz)),
                                        TextButton(onPressed: () {
                                          DoReaction()
                                              .getReactionsList(
                                              id, emojiList)
                                              .then((value) {
                                            showDialog<void>(
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: Text(
                                                        "リアクション一覧"),
                                                    content: ListView(
                                                        children:
                                                        value),
                                                    actions: <Widget>[
                                                      GestureDetector(
                                                        child:
                                                        Container(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                              vertical:
                                                              2,
                                                              horizontal:
                                                              2),
                                                          child: Text(
                                                              L10n.of(context)!
                                                                  .close),
                                                        ),
                                                        onTap: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                                context: context);
                                          });
                                        }, child: const Icon(
                                            Icons.equalizer))

                                      ]),
                                ])),
                          ),
                          const Divider(
                              height: 1, thickness: 1, color: Colors.white12),
                          Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.only(top: 10, bottom: 10),
                              child: Text(L10n.of(context)!.reply_list)),
                          showReplies(feed["id"])
                        ]);
                      });
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }));
  }

  Future<dynamic> _fetchNote(id) async {
    var token = await sysAccount().getToken();
    var host = await sysAccount().getHost();
    Uri uri = Uri.parse("https://$host/api/notes/show");
    Map<String, String> headers = {'content-type': 'application/json'};
    var response = await http.post(uri,
        headers: headers, body: json.encode({"i": token, "noteId": id}));
    String res = "[${response.body}]";
    if (kDebugMode) {
      print("Request showNotes: [$res]");
    }
    dynamic dj = jsonDecode(res);
    return dj;
  }

  Widget checkImageOrText(text, image) {
    if (kDebugMode) {
      print(image);
    }
    if (text != null) {
      if (!image.isEmpty) {
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
              searchTap: (content) {
                content = content.replaceAll(" ", "+");
                if (kDebugMode) {
                  print("Search tapped! content=>search?q=$content");
                }
                launchUrl(
                    Uri.parse("https://www.google.com/search?q=$content"));
              },
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [for (var file in image) isNeedBlur(file)],
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
        searchTap: (content) {
          content = content.replaceAll(" ", "+");
          if (kDebugMode) {
            print("Search tapped! content=>search?q=$content");
          }
          launchUrl(Uri.parse("https://www.google.com/search?q=$content"));
        },
      );
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [for (var file in image) isNeedBlur(file)],
        ),
      );
    }
  }

  Widget isNeedBlur(sensitiveFlug) {
    var image = sensitiveFlug["url"];
    var sf = sensitiveFlug["isSensitive"];
    sf = false;
    if (sf == true && !(sensitiveFlug["type"].contains("video"))) {
      if (kDebugMode) {
        print("Blur skip");
      }
      return GestureDetector(
        child: Blur(
          blur: 20,
          child: SizedBox(
            height: 300,
            width: 300,
            child: CachedNetworkImage(
              imageUrl: image,
              imageBuilder: (context, imageProvider) => Image(
                image: imageProvider,
                width: 300,
                height: 300,
              ),
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  CircularProgressIndicator(value: downloadProgress.progress),
            ),
          ),
        ),
        onTap: () => {
          Fluttertoast.showToast(
              msg: L10n.of(context)!.msg_sensitive_open_error)
        },
      );
    } else if (!(sensitiveFlug["type"].contains("video"))) {
      return GestureDetector(
        child: CachedNetworkImage(
          imageUrl: image,
          imageBuilder: (context, imageProvider) => Image(
            image: imageProvider,
            width: 300,
            height: 300,
          ),
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              CircularProgressIndicator(value: downloadProgress.progress),
        ),
        onTap: () => {viewImageOnDialog(context: context, uri: image)},
      );
    } else {
      return TextButton(
          onPressed: () {}, child: const Icon(Icons.play_circle_outlined));
    }
  }

  Widget showReply(feed) {
    if (feed == null || feed == "") {
      return Container();
    }
    return FutureBuilder<dynamic>(
        future: Note().fetchReply(feed["id"]),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Text("リプライの取得中です");
          }
          if (!snap.hasData) {
            return const Text("リプライの取得に失敗しました(データがありません)");
          }
          return ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: snap.data!.length,
              separatorBuilder: (BuildContext context, int index) => Divider(
                    color: Colors.grey.shade400,
                  ),
              itemBuilder: (context, index) {
                var feed = snap.data![index];
                if (feed == null) {
                  exit(0);
                }
                final text = feed["text"];
                final author = feed["user"];
                final String avatar = feed["user"]["avatarUrl"];
                final id = feed["id"].toString();
                var instance = "";
                if (feed["user"]["host"] != null) {
                  instance = '@${feed["user"]["host"]}';
                }
                if (author["name"] == null) {
                  author["name"] = "";
                }
                return Column(children: [
                  InkWell(
                    onTap: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => viewNote(noteId: id)))
                    },
                    child: Container(
                        padding: const EdgeInsets.only(
                            left: 8.0, bottom: 8.0, right: 8.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CachedNetworkImage(
                                      imageUrl: avatar,
                                      imageBuilder: (context, imageProvider) =>
                                          CircleAvatar(
                                            backgroundImage: imageProvider,
                                            radius: 24,
                                          ),
                                      errorWidget:
                                          (context, url, dynamic error) =>
                                              const Icon(Icons.error)),
                                  const SizedBox(width: 8.0),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Flexible(
                                                child: Mfm(
                                                    mfmText:
                                                        "**${author["name"]}**",
                                                    emojiBuilder: (context,
                                                        emoji, style) {
                                                      final emojiData =
                                                          emojiList[emoji];
                                                      if (emojiData == null) {
                                                        return Text.rich(
                                                            TextSpan(
                                                                text: emoji,
                                                                style: style));
                                                      } else {
                                                        return CachedNetworkImage(
                                                            imageUrl: emojiData,
                                                            imageBuilder: (context,
                                                                    imageProvider) =>
                                                                Image(
                                                                  image:
                                                                      imageProvider,
                                                                  height:
                                                                      (style?.fontSize ??
                                                                              1) *
                                                                          2,
                                                                ),
                                                            errorWidget: (context,
                                                                    url,
                                                                    dynamic
                                                                        error) =>
                                                                const Icon(Icons
                                                                    .error));
                                                      }
                                                    })),
                                            Flexible(
                                              child: Text(
                                                '@${author['username']}$instance',
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              L10n.of(context)!.reply_to,
                                              style: TextStyle(fontSize: 12.0),
                                              overflow: TextOverflow.clip,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10.0),
                                        checkImageOrText(text, feed["files"]),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ])),
                  ),
                  const Divider(height: 1, thickness: 1, color: Colors.white12)
                ]);
              });
        });
  }

  Widget showReplies(noteId) {
    return FutureBuilder<dynamic>(
        future: Note().fetchReplies(noteId),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Text("リプライの取得中です");
          }
          if (!snap.hasData) {
            return const Text("リプライの取得に失敗しました(データがありません)");
          }
          return ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: snap.data!.length,
              separatorBuilder: (BuildContext context, int index) => Divider(
                    color: Colors.grey.shade400,
                  ),
              itemBuilder: (context, index) {
                var feed = snap.data![index];
                if (feed == null) {
                  exit(0);
                }
                final text = feed["text"];
                final author = feed["user"];
                final String avatar = feed["user"]["avatarUrl"];
                final createdAt = DateTime.parse(feed["createdAt"]).toLocal();
                final id = feed["id"].toString();
                var instance = "";
                if (feed["user"]["host"] != null) {
                  instance = '@${feed["user"]["host"]}';
                }
                if (author["name"] == null) {
                  author["name"] = "";
                }
                return Column(children: [
                  InkWell(
                    onTap: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => viewNote(noteId: id)))
                    },
                    child: Container(
                        padding: const EdgeInsets.only(
                            left: 8.0, bottom: 8.0, right: 8.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CachedNetworkImage(
                                      imageUrl: avatar,
                                      imageBuilder: (context, imageProvider) =>
                                          CircleAvatar(
                                            backgroundImage: imageProvider,
                                            radius: 24,
                                          ),
                                      errorWidget:
                                          (context, url, dynamic error) =>
                                              const Icon(Icons.error)),
                                  const SizedBox(width: 8.0),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Flexible(
                                                child: Mfm(
                                                    mfmText:
                                                        "**${author["name"]}**",
                                                    emojiBuilder: (context,
                                                        emoji, style) {
                                                      final emojiData =
                                                          emojiList[emoji];
                                                      if (emojiData == null) {
                                                        return Text.rich(
                                                            TextSpan(
                                                                text: emoji,
                                                                style: style));
                                                      } else {
                                                        return CachedNetworkImage(
                                                            imageUrl: emojiData,
                                                            imageBuilder: (context,
                                                                    imageProvider) =>
                                                                Image(
                                                                  image:
                                                                      imageProvider,
                                                                  height:
                                                                      (style?.fontSize ??
                                                                              1) *
                                                                          2,
                                                                ),
                                                            errorWidget: (context,
                                                                    url,
                                                                    dynamic
                                                                        error) =>
                                                                const Icon(Icons
                                                                    .error));
                                                      }
                                                    })),
                                            Flexible(
                                              child: Text(
                                                '@${author['username']}$instance',
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              timeago.format(createdAt,
                                                  locale: "ja"),
                                              style: TextStyle(fontSize: 12.0),
                                              overflow: TextOverflow.clip,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10.0),
                                        checkImageOrText(text, feed["files"]),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ])),
                  ),
                  const Divider(height: 1, thickness: 1, color: Colors.white12)
                ]);
              });
        });
  }
}
