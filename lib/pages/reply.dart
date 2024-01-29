import 'dart:convert';
import 'dart:io';

import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mfm/mfm.dart';
import 'package:twisskey/api/drive.dart';
import 'package:twisskey/api/myAccount.dart';
import 'package:http/http.dart' as http;
import 'package:twisskey/api/notes.dart';
import 'package:twisskey/main.dart';
import 'package:twisskey/pages/viewImage.dart';
import 'package:url_launcher/url_launcher.dart';

class Reply extends StatefulWidget{
  const Reply({Key? key, required this.id}) : super(key: key);
  final String id;
  @override
  // _MyHomePageStateを利用する
  State<Reply> createState() => _Reply();
}

class _Reply extends State<Reply>{
  late String imageState = "";
  List<String> fileIds = [];
  String? tweets = "";
  late String? body = "";
  Map<String,String> emojiList = {};
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
  Future loadEmoji() async{
    emojiList = await getEmoji();
  }
  @override
  void initState(){
    super.initState();
    loadEmoji();
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
          title: const Text("リプライ"),
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
              child: const Text("リプライ"),
            )
          ],
        ),
        body: Center(child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: sizeWidth - 20, maxHeight: sizeHeight),
            child: Column(
                children: [
                  showReply(widget.id),
                  TextField(
                    onChanged: (text)=>{
                      updateTweet(text)
                    },
                    autofocus: true,
                    keyboardType: TextInputType.multiline,
                    minLines: 10,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      hintText: "返信をツイート",
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
    if (kDebugMode) {
      print(fileIds.length);
    }
    if(fileIds.length==0) {
      if (kDebugMode) {
        print("文のみ");
      }
      body = {"text": tweet, "i": token,"replyId":widget.id};
    }else{
      if(tweet != "" && tweet != null) {
        if (kDebugMode) {
          print(tweet);
          print("tweet 含む");
        }

        body = {"text": tweet, "i": token, "fileIds": fileIds};
      }else{
        body = {"i": token, "fileIds": fileIds,"replyId":widget.id};
      }
    }
    final response = await http.post(uri,headers: headers, body: jsonEncode(body));
    final res = response.body;
    Map<String, dynamic> map = jsonDecode(res);
    print(map["createdNote"]);
    if(map["createdNote"]==null){
      Fluttertoast.showToast(msg: "リプライの作成に失敗しました",fontSize: 18);
      print(map);
    }else{
      Fluttertoast.showToast(msg: "リプライしました",fontSize: 18);
    }
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
                  return CachedNetworkImage(imageUrl: emojiData,imageBuilder: (context,imageProvider)=>
                      Image(image: imageProvider,
                        height: (style?.fontSize ?? 1) * 2,
                      ),errorWidget: (context, url, dynamic error) => const Icon(Icons.error));
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
            return CachedNetworkImage(imageUrl: emojiData,imageBuilder: (context,imageProvider)=>
                Image(image: imageProvider,
                  height: (style?.fontSize ?? 1) * 2,
                ),errorWidget: (context, url, dynamic error) => const Icon(Icons.error));
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
      print("isSensitive:"+sensitiveFlug["type"]);
    }
    if(sf == true && !(sensitiveFlug["type"].contains("video"))){
      if (kDebugMode) {
        print("Blur skip");
      }
      return GestureDetector(child:Blur(
        blur: 20,
        child: SizedBox(
          height: 300,
          width: 300,
          child: CachedNetworkImage(imageUrl: image,imageBuilder: (context,imageProvider)=>
              Image(image: imageProvider,
                width: 300,
                height: 300,
              ),errorWidget: (context, url, dynamic error) => const Icon(Icons.error)),
        ),
      ),
        onTap: ()=>{Fluttertoast.showToast(msg: "センシティブ指定されたファイルを見るにはツイートをタップしてください")},
      );
    }else if(!(sensitiveFlug["type"].contains("video"))){
      return GestureDetector(
        child:CachedNetworkImage(imageUrl: image,imageBuilder: (context,imageProvider)=>
            Image(image: imageProvider,
              width: 300,
              height: 300,
            ),
            errorWidget: (context, url, dynamic error) => const Icon(Icons.error)
        ),
        onTap: ()=>{viewImageOnDialog(context: context,uri: image)},
      );
    }else{
      return TextButton(onPressed:(){playMovieOnDialog(context: context, uri: image);} ,child: const Icon(Icons.play_circle_outlined));
    }
  }

  Widget showReply(feed) {
    if(feed==null || feed==""){
      return Container();
    }
    return FutureBuilder<dynamic>(
        future: Note().fetchReply(feed),
        builder: (context,snap){
          if(snap.connectionState != ConnectionState.done){
            return const Text("リプライの取得に失敗しました(接続に失敗しました)");
          }
          if(!snap.hasData){
            return const Text("リプライの取得に失敗しました(データがありません)");
          }
          return ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: snap.data!.length,
              separatorBuilder: (BuildContext context, int index) => Divider(color: Colors.grey.shade400,),
              itemBuilder: (context, index){
                var feed = snap.data![index];
                if(feed == null){
                  exit(0);
                }
                final text = feed["text"];
                final author = feed["user"];
                final String avatar = feed["user"]["avatarUrl"];
                var instance = "";
                if(feed["user"]["host"] != null){
                  instance = '@${feed["user"]["host"]}';
                }
                if(author["name"]==null){
                  author["name"] = "";
                }
                return Column(children: [
                  InkWell(
                    child: Container(
                        padding: const EdgeInsets.only(left: 8.0,bottom: 8.0,right:8.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CachedNetworkImage(imageUrl: avatar,imageBuilder: (context, imageProvider)=>CircleAvatar(
                                    backgroundImage: imageProvider,
                                    radius: 24,
                                  ),errorWidget: (context, url, dynamic error) => const Icon(Icons.error)),
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
                                                        return CachedNetworkImage(imageUrl: emojiData,imageBuilder: (context,imageProvider)=>
                                                            Image(image: imageProvider,
                                                              height: (style?.fontSize ?? 1) * 2,
                                                            ),errorWidget: (context, url, dynamic error) => const Icon(Icons.error));
                                                      }
                                                    })
                                            ),
                                            Flexible(
                                              child: Text(
                                                '@${author['username']}$instance',
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const Text(
                                              "返信先",
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
              }
          );
        }
    );
  }
}
