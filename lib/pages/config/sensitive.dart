import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:twisskey/config/sensitive.dart';

class Sensitive extends StatefulWidget{
  const Sensitive({Key? key}) : super(key:key);
  @override
  _Sensitive createState() => _Sensitive();
}

class _Sensitive extends State<Sensitive>{

  bool value = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.of(context)!.config_public_health),
      ),
      body: FutureBuilder(
        future: config_timeline_sensitive().get(),
        builder: (BuildContext context, ss){
          if(ss.connectionState == ConnectionState.done) {
            if(ss.hasData) {
              value = ss.data!;
              return Container(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Checkbox(value: value, onChanged: (e) {
                          setState(() {
                            config_timeline_sensitive().save(e!);
                            value = e;
                          });
                        }, activeColor: Colors.blue,),
                        Flexible(child: Text(
                            L10n.of(context)!
                                .config_sensivive_show_on_timeline))
                      ],
                    )
                  ],
                ),
              );
            }else{
              return Container(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Checkbox(value: value, onChanged: (e) {
                          setState(() {
                            value = e!;
                          });
                        }, activeColor: Colors.blue,),
                        Flexible(child: Text(
                            L10n.of(context)!
                                .config_sensivive_show_on_timeline))
                      ],
                    )
                  ],
                ),
              );
            }
          }else{
            return Container(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Checkbox(value: value, onChanged: (e) {
                        setState(() {
                          value = e!;
                        });
                      }, activeColor: Colors.blue,),
                      Flexible(child: Text(
                          L10n.of(context)!.config_sensivive_show_on_timeline))
                    ],
                  )
                ],
              ),
            );
          }
        }
      )
    );
  }

}