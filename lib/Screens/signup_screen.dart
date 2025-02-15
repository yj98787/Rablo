import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rablo_chatapp/Screens/complete_profile_screen.dart';

import '../Models/ui_helper.dart';
import '../Models/userModel.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();

  void checkValues(){
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cPassword = cPasswordController.text.trim();

    if(email==""||password==""||cPassword==""){
      UiHelper.showAlertDialog(context, "Incomplete Data", "Please fill all the fields!");
      print("Please fill all the fields!");
    }
    else if(password != cPassword){
      UiHelper.showAlertDialog(context, "Password Mismatched", "The password you have entered do not match!");
      print("Password does not match!");
    }
    else{
      print("Sign Up successful!");
      signUp(email, password);
    }
  }

  void signUp(String email,String password) async {
    UserCredential? credential;

    UiHelper.showLoadingDialogs(context, "Creating new Account...");

    try{
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch(ex){
      Navigator.pop(context);
      UiHelper.showAlertDialog(context, "An error occured", ex.code.toString());
      print(ex.code.toString());
    }

    if(credential!= null){
      String uid = credential.user!.uid;
      UserModel newUser = UserModel(
        uid: uid,
        email: email,
        fullName: "",
        mobile: "",
        profilepic: "",
      );

      await FirebaseFirestore.instance.collection("User").doc(uid).set(newUser.toMap());
      print("New user Created!");
      Navigator.popUntil(context, (route)=>route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>CompleteProfileScreen(userModel: newUser, firebaseUser: credential!.user!)));
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
                  TextField(
                    controller: cPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                        hintText: "Confirm Password"
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CupertinoButton(
                    onPressed: (){
                      checkValues();
                    },
                    child: Text("Sign Up",
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
            Text("already have an account?",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.symmetric(horizontal: 5),
                child: Text("Login"), onPressed: (){
                Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }
}
