import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rablo_chatapp/Screens/complete_profile_screen.dart';
import 'package:rablo_chatapp/Screens/home_screen.dart';
import 'package:rablo_chatapp/Screens/login_screen.dart';
import 'package:rablo_chatapp/Screens/signup_screen.dart';
import 'package:rablo_chatapp/Screens/splash_screen2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Models/userModel.dart';
import 'package:rablo_chatapp/Models/firebase_helper.dart';

import 'Screens/splash_screen.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();


  User? currentUser = FirebaseAuth.instance.currentUser;

  if(currentUser!=null){
    log("data Fetched");
    //Already Logged IN

    UserModel? thisUserModel = await FirebaseHelper.getUserModelById(currentUser.uid);
    if(thisUserModel!=null){
      log("data Fetched....");
      runApp(MyLoggedInApp(userModel: thisUserModel, firebaseUser: currentUser));
    }else{
      log("data Fetched????????");
      runApp(MyApp());
    }

  }else{
    log("data not Fetched");
    //Login Page
    runApp(MyApp());
  }

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class MyLoggedInApp extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  MyLoggedInApp({required this.userModel,required this.firebaseUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen2(firebaseUser: firebaseUser, userModel: userModel),
    );
  }
}

