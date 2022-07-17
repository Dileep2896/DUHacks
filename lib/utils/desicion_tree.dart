import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/bottom_navbar.dart';
import '../screens/welcome_screen.dart';

class DesicionTree extends StatefulWidget {
  const DesicionTree({Key? key}) : super(key: key);

  static String id = "desicion_tree";

  @override
  State<DesicionTree> createState() => _DesicionTreeState();
}

class _DesicionTreeState extends State<DesicionTree> {
  User? user;

  @override
  void initState() {
    super.initState();
    onRefresh(FirebaseAuth.instance.currentUser);
  }

  onRefresh(userCred) {
    setState(() {
      user = userCred;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const WelcomeScreen();
    }
    return const BottomNavBar();
  }
}
