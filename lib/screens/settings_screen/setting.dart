import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../utils/desicion_tree.dart';
import '../../utils/style.dart';
import '../../widgets/custom_rounded_button.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  static String id = "setting_screen";

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  List<String> settingList = [
    "Edit Charger",
    "Location",
    "Privacy",
    "About",
    "Terms & Conditions"
  ];

  List<IconData> settingIcons = [
    Icons.edit,
    Icons.location_on,
    Icons.lock,
    Icons.info,
    Icons.list,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Settings",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ListView.builder(
                    itemCount: settingList.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              settingList[index],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              settingIcons[index],
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
              CustomRoundedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut().then((value) {
                    Navigator.pushReplacementNamed(
                      context,
                      DesicionTree.id,
                    );
                  });
                },
                title: "Logout",
                backgroundColor: Colors.redAccent,
                textColor: Colors.white,
              )
            ],
          ),
        ),
      ),
    );
  }
}
