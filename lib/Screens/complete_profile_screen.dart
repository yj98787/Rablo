import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rablo_chatapp/Screens/home_screen.dart';

import '../Models/ui_helper.dart';
import '../Models/userModel.dart';

class CompleteProfileScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const CompleteProfileScreen({super.key,required this.firebaseUser,required this.userModel});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {

  File? imageFile;
  TextEditingController fullNameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);

    if(pickedFile!=null){
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 25,
    );

    if(croppedImage!=null){
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  void showPhotoOption(){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("Upload Profile Picture"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: (){
                Navigator.pop(context);
                selectImage(ImageSource.gallery);
              },
              leading: Icon(Icons.photo_album),
              title: Text("Select from Gallery"),
            ),

            ListTile(
              onTap: (){
                Navigator.pop(context);
                selectImage(ImageSource.camera);
              },
              leading: Icon(Icons.camera_alt),
              title: Text("Capture Image"),
            )
          ],
        ),
      );
    });
  }

  void checkValues(){
    String fullName = fullNameController.text.trim();
    String mobile = mobileController.text.trim();

    if(fullName == ""||mobile == ""){
      UiHelper.showAlertDialog(context, "Incomplete Data", "Please fill all the fields!");
      print("Please fill all the fields");
    }
    else{
      log("uploading data...");
      uploadData();
    }
  }

  void uploadData() async{

    //UiHelper.showLoadingDialogs(context, "Uploading Image...");
    //UploadTask uploadTask = FirebaseStorage.instance.ref("ProfilePictures").child(widget.userModel.uid.toString()).putFile(imageFile!);

    //TaskSnapshot snapshot = await uploadTask;

    String fullName = fullNameController.text.trim();
    //String imageUrl = await snapshot.ref.getDownloadURL();
    String mobile = mobileController.text.trim();

    widget.userModel.fullName = fullName;
    widget.userModel.mobile = mobile;
    //widget.userModel.profilepic = imageUrl;

    await FirebaseFirestore.instance.collection("User").doc(widget.userModel.uid).set(widget.userModel.toMap()).then((value){
      log("Data uploaded");
      print("Data Uploaded");
      Navigator.popUntil(context, (route)=>route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen(userModel: widget.userModel, firebaseUser: widget.firebaseUser)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text("Complete Profile",
        style: TextStyle(
          color: Colors.white,
        ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SafeArea(
          child: Padding(padding: EdgeInsets.symmetric(horizontal: 40),
          child: ListView(
            children: [
              SizedBox(
                height: 40,
              ),
              GestureDetector(
                onTap: (){
                  //showPhotoOption();
                },
                child: CircleAvatar(
                  radius: 80,
                  child: Icon(Icons.person,
                  size: 80,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: fullNameController,
                decoration: InputDecoration(
                  hintText: "Full Name"
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                maxLength: 10,
                keyboardType: TextInputType.number,
                controller: mobileController,
                decoration: InputDecoration(
                    hintText: "Mobile Number"
                ),
              ),
              SizedBox(
                height: 20,
              ),
              CupertinoButton(
                  color: Theme.of(context).colorScheme.primary,
                child: Text("submit",
                style: TextStyle(
                  color: Colors.white,
                ),
                ),
                  onPressed: (){
                    checkValues();
                  },
              ),
            ],
          ),
          ),
      ),
    );
  }
}
