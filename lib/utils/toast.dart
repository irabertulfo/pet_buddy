import 'package:flutter/material.dart';
import 'package:pet_buddy/constants/texts.dart';

class Toast {
  static void show(BuildContext context, String? message) {
    final snackBar = SnackBar(
      content: Text(message ?? vagueError),
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
