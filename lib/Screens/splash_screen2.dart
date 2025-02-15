import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:rablo_chatapp/Models/userModel.dart';
import 'package:rablo_chatapp/Screens/home_screen.dart';
import 'package:rablo_chatapp/Screens/login_screen.dart';

class SplashScreen2 extends StatefulWidget {
  final User firebaseUser;
  final UserModel userModel;
  const SplashScreen2({super.key,required this.firebaseUser,required this.userModel});

  @override
  State<SplashScreen2> createState() => _SplashScreen2State();
}

class _SplashScreen2State extends State<SplashScreen2> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 3),(){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen(userModel: widget.userModel, firebaseUser: widget.firebaseUser)));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset("images/chatapp-removebg-preview.png"),
      ),
    );
  }
}
