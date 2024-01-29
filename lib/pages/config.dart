import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Configuration extends StatefulWidget {
  const Configuration({Key? key}) : super(key: key);
  @override
  State<Configuration> createState() => _pageConfiguration();
}

class _pageConfiguration extends State<Configuration> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("設定"),
        ),
        body: Column(
          children: [
            TextButton(
                onPressed: () {
                  Fluttertoast.showToast(msg: "言語設定を開く");
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        padding: const EdgeInsets.only(right: 10),
                        child: const Icon(Icons.translate_outlined)),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "言語設定",
                          style: TextStyle(
                              fontWeight: FontWeight.w900, color: Colors.black),
                        ),
                        Text(
                          "Twisskeyで利用する言語の設定をします",
                          style: TextStyle(
                              color: Color.fromRGBO(100, 100, 100, 1)),
                        )
                      ],
                    )
                  ],
                )),
            TextButton(
                onPressed: () {
                  Fluttertoast.showToast(msg: "公共");
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        padding: const EdgeInsets.only(right: 10),
                        child: const Icon(Icons.train)),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "公共設定",
                          style: TextStyle(
                              fontWeight: FontWeight.w900, color: Colors.black),
                        ),
                        Text("公共に関する設定をします",
                            style: TextStyle(
                                color: Color.fromRGBO(100, 100, 100, 1)))
                      ],
                    )
                  ],
                )),
            TextButton(
                onPressed: () {
                  Fluttertoast.showToast(msg: "言語設定を開く");
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        padding: const EdgeInsets.only(right: 10),
                        child: const Icon(Icons.privacy_tip_outlined)),
                    const Flexible(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "プライバシーと安全",
                          style: TextStyle(
                              fontWeight: FontWeight.w900, color: Colors.black),
                        ),
                        Text("アカウントに関するコミュニティでの安全性を設定します。",
                            style: TextStyle(
                                color: Color.fromRGBO(100, 100, 100, 1)))
                      ],
                    ))
                  ],
                )),
          ],
        ));
  }
}
