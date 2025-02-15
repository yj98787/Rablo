import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rablo_chatapp/Screens/home_screen.dart';
import 'package:rablo_chatapp/Screens/signup_screen.dart';

import '../Models/ui_helper.dart';
import '../Models/userModel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void checkValues(){
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if(email==""||password==""){
      UiHelper.showAlertDialog(context, "Incomplete Data", "Please fill all the fields!");
      print("Please fill all the fields!");
    }else{
      logIn(email, password);
    }
  }

  void logIn(String email,String password) async {
    UserCredential? credential;

    UiHelper.showLoadingDialogs(context, "Logging in...");

    try{
      credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    }on FirebaseAuthException catch(ex){
      //close the loading dialog
      Navigator.pop(context);

      //shoeing alert dialog
      UiHelper.showAlertDialog(context, "An error Occured", ex.code.toString());

      print(ex.code.toString());
    }

    if(credential != null){
      String uid = credential.user!.uid;

      DocumentSnapshot userData = await FirebaseFirestore.instance.collection("User").doc(uid).get();

      UserModel newUser1 = UserModel.fromMap(userData.data() as Map<String,dynamic>);

      print("Log In Successful!");
      Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeScreen(userModel: newUser1, firebaseUser: credential!.user!)));
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text("Chat App",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: "Email Address"
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                          hintText: "Password"
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    CupertinoButton(
                      onPressed: (){
                        checkValues();
                      },
                      child: Text("Log In",
                        style: TextStyle(
                          color: Colors.white,
                        ),),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Don't have an account?",
              style: TextStyle(
                fontSize: 16,
              ),
            ),

            CupertinoButton(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Text("Sign Up"), onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>SignupScreen()));
            }),
          ],
        ),
      ),
    );
  }
}
