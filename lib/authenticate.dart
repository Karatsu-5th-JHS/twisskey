import 'package:flutter/material.dart';
import 'package:twisskey/main.dart';

class authenticate extends StatelessWidget {
  const authenticate({Key? key, required this.session}) : super(key: key);
  final String session;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
          child: FutureBuilder<String?>(
              future: loginProcess(session),
              builder: (context,ss) {
                if (ss.hasData) {
                  String result = ss.data!;
                  return Text(result);
                } else {
                  return  const Text("取得に失敗しました。", style: TextStyle(fontSize: 30,),);
                }
              }
          )
      ),
    );
  }
}