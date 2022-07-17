import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void toast({
  required String message,
  Color? toastBg = Colors.white,
  Color? textColor = Colors.black,
}) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: toastBg,
      textColor: textColor,
      fontSize: 16.0);
}
