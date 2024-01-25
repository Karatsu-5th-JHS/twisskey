import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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