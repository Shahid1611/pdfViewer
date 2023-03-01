import 'dart:async';

import'package:flutter/material.dart';
import 'package:get/get.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer ;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _timer = new Timer(const Duration(microseconds: 3), () {
      Get.toNamed('/home');
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,

      ),
    );
  }
}
