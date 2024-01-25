import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:video_player/video_player.dart';

void viewImageOnDialog({
    required BuildContext context,
    required String uri,
}){
  showDialog(
    barrierDismissible: true,
    barrierLabel: '閉じる',
    context: context,
    builder: (context) {
      return Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: InteractiveViewer(
                  minScale: 0.1,
                  maxScale: 5,
                  child: CachedNetworkImage(imageUrl: uri,imageBuilder: (context,imageProvider)=>Image(image: imageProvider,),)
                ),
              ),
            ],
          ),
          Row(
            children: [
              Material(
                color: Colors.transparent,
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.close,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}

void playMovieOnDialog({
  required BuildContext context,
  required String uri,
}){
  late VideoPlayerController VC;
  bool ScreenMode = false;
  VC = VideoPlayerController.networkUrl(Uri.parse(uri));
  VC.initialize().then((_) {
    showDialog(
      barrierDismissible: true,
      barrierLabel: '閉じる',
      context: context,
      builder: (context) {
        return SingleChildScrollView(
            child:Container(padding: const EdgeInsets.only(left: 20, right: 20),child:Stack(
            //alignment: Alignment.topCenter,
              children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width, maxHeight: MediaQuery.of(context).size.height),
                      child: AspectRatio(aspectRatio: VC.value.aspectRatio,child:GestureDetector(child: VideoPlayer(VC),onTap: (){VC.play();},)),
                  ),
                    Container(
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(onPressed: (){VC.seekTo(Duration.zero);}, icon: const Icon(Icons.skip_previous)),
                          IconButton(onPressed: (){VC.play();}, icon: const Icon(Icons.play_arrow)),
                          IconButton(onPressed: (){VC.pause();}, icon: const Icon(Icons.pause)),
                          IconButton(onPressed: (){}, icon: const Icon(Icons.skip_next)),
                          IconButton(onPressed: (){
                            if(!ScreenMode){
                              Fluttertoast.showToast(msg: "フルスクリーンモードを解除するには、下にスクロールしてボタンを押すか、閉じるを押して再生を終了します");
                              SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
                              SystemChrome.setPreferredOrientations([
                                DeviceOrientation.landscapeLeft,
                                DeviceOrientation.landscapeRight
                              ]);
                              ScreenMode = true;
                            }else{
                              SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                              SystemChrome.setPreferredOrientations([
                                DeviceOrientation.portraitDown,
                                DeviceOrientation.portraitUp
                              ]);
                              ScreenMode = false;
                            }
                            }, icon: const Icon(Icons.fullscreen)
                         )
                       ],
                     ),
                   )
                ])
                /*Expanded(
                  child: InteractiveViewer(
                      minScale: 0.1,
                      maxScale: 5,
                      child:
                  ),
                ),*/
                ,Row(
            children: [
              Material(
                color: Colors.transparent,
                child: IconButton(
                  onPressed: () {
                    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.portraitDown,
                      DeviceOrientation.portraitUp
                    ]);
                    VC.dispose();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.close,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
              ),
            ]),
              ],
            ),
        ));
      },
    );
  });
}