import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

showProgressLoader(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Lottie.asset("lib/images/loader.json"),
        );
      });
}
