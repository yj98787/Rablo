import 'dart:developer';
import 'package:rablo_chatapp/Screens/chatroom_screen.dart';
import 'package:uuid/uuid.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rablo_chatapp/Models/userModel.dart';
import 'package:rablo_chatapp/Screens/login_screen.dart';

import '../Models/chatRoom_model.dart';

class HomeScreen extends StatefulWidget {
  final User firebaseUser;
  final UserModel userModel;
  const HomeScreen({super.key,required this.userModel,required this.firebaseUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final Uuid uuid = Uuid();

  Future<ChatRoomModel?> getChatroomModel(UserModel targetUser) async{
    ChatRoomModel? chatroom;
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("chatrooms").where("participants.${widget.userModel.uid}",isEqualTo: true).
    where("participants.${targetUser.uid}",isEqualTo: true).get();

    if(snapshot.docs.length>0){
      //Chatroom already exist
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom = ChatRoomModel.fromMap(docData as Map<String,dynamic>);
      chatroom = existingChatroom;
      log("Chatroom already exist");
    }else{
      //create new one
      ChatRoomModel newChatroom = ChatRoomModel(
          chatroomid: uuid.v1(),
          lastMessage: "",
          createdon: Timestamp.fromDate(DateTime.now()),
          participants: {
            widget.userModel.uid.toString():true,
            targetUser.uid.toString():true,
          }
      );
      await FirebaseFirestore.instance.collection("chatrooms").doc(newChatroom.chatroomid).set(newChatroom.toMap());
      log("chatroom created");
      chatroom = newChatroom;
    }
    return chatroom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: ()async{
              await FirebaseAuth.instance.signOut();
              Navigator.popUntil(context, (route)=>route.isFirst);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
            },
            icon: Icon(Icons.exit_to_app),
            color: Colors.white,
          ),
        ],
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text("Chat App",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SafeArea(
          child: Container(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection("User").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot homeSnapshot = snapshot.data as QuerySnapshot;

                    // Filter out the current user
                    List<QueryDocumentSnapshot> userDocs = homeSnapshot.docs
                        .where((doc) => doc.id != widget.userModel.uid) // Exclude current user
                        .toList();

                    return ListView.builder(
                      itemCount: userDocs.length,
                      itemBuilder: (context, index) {
                        UserModel homeModel = UserModel.fromMap(
                          userDocs[index].data() as Map<String, dynamic>,
                        );

                        return ListTile(
                          onTap: () async {
                            ChatRoomModel? chatroomModel = await getChatroomModel(homeModel);
                            if (chatroomModel != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatroomScreen(
                                    targetUser: homeModel,
                                    chatroom: chatroomModel,
                                    userModel: widget.userModel,
                                    firebaseUser: widget.firebaseUser,
                                  ),
                                ),
                              );
                            }
                          },
                          leading: CircleAvatar(
                            backgroundImage: AssetImage("images/man.png"),
                          ),
                          title: Text(homeModel.fullName.toString()),
                          subtitle: Text("Say hi to your new friend!"),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(snapshot.error.toString()),
                    );
                  } else {
                    return Center(
                      child: Text("No Data Found!"),
                    );
                  }
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            )
          )
      ),
    );
  }
}
