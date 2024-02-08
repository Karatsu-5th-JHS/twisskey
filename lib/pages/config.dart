import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:twisskey/pages/config/language.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

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
          title: Text(L10n.of(context)!.configuration),
        ),
        body: Column(
          children: [
            TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Language()));
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        padding: const EdgeInsets.only(right: 10),
                        child: const Icon(Icons.translate_outlined)),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          L10n.of(context)!.config_language,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, color: Colors.black),
                        ),
                        Text(
                          L10n.of(context)!.about_config_language,
                          style: const TextStyle(
                              color: Color.fromRGBO(100, 100, 100, 1)),
                        )
                      ],
                    )
                  ],
                )),
            TextButton(
                onPressed: () {
                  Fluttertoast.showToast(
                      msg: L10n.of(context)!.config_public_health);
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        padding: const EdgeInsets.only(right: 10),
                        child: const Icon(Icons.train)),
                    Flexible(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          L10n.of(context)!.config_public_health,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, color: Colors.black),
                        ),
                        Text(L10n.of(context)!.about_config_public_health,
                            style: const TextStyle(
                                color: Color.fromRGBO(100, 100, 100, 1)))
                      ],
                    ))
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
                    Flexible(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          L10n.of(context)!.config_privacy_and_safety,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, color: Colors.black),
                        ),
                        Text(L10n.of(context)!.about_config_privacy_and_safety,
                            style: const TextStyle(
                                color: Color.fromRGBO(100, 100, 100, 1)))
                      ],
                    ))
                  ],
                )),
            TextButton(
                onPressed: () {
                  launchUrl(Uri.parse(
                      "https://twisskey.tkngh.jp/other/privacy.html"));
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        padding: const EdgeInsets.only(right: 10),
                        child: const Icon(Icons.info_outline)),
                    const Flexible(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Privacy Policy",
                          style: TextStyle(
                              fontWeight: FontWeight.w900, color: Colors.black),
                        ),
                        Text(
                            "Open the Twisskey Privacy Policy page in your in-app browser.",
                            style: TextStyle(
                                color: Color.fromRGBO(100, 100, 100, 1)))
                      ],
                    ))
                  ],
                ))
          ],
        ));
  }
}
