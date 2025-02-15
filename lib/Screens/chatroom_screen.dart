import 'dart:developer';
import 'package:uuid/uuid.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Models/chatRoom_model.dart';
import '../Models/messageModel.dart';
import '../Models/userModel.dart';

class ChatroomScreen extends StatefulWidget {

  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;

  const ChatroomScreen({super.key,required this.firebaseUser,required this.userModel,required this.targetUser,required this.chatroom});

  @override
  State<ChatroomScreen> createState() => _ChatroomScreenState();
}

class _ChatroomScreenState extends State<ChatroomScreen> {

  Future<void> deleteMessage(String messageId) async {
    await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(widget.chatroom.chatroomid)
        .collection("messages")
        .doc(messageId)
        .delete();
  }

  // Show confirmation dialog before deleting
  void showDeleteDialog(BuildContext context, String messageId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Message?"),
        content: Text("Are you sure you want to delete this message?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              deleteMessage(messageId); // Delete message
              Navigator.pop(context); // Close dialog
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  final Uuid uuid = Uuid();

  TextEditingController messagingController = TextEditingController();

  void sendMessage() async {
    String msg = messagingController.text.trim();
    messagingController.clear();

    if(msg != ""){
      MessageModel newMessage = MessageModel(
        messageid: uuid.v1(),
        sender: widget.userModel.uid,
        text: msg,
        createdon: Timestamp.fromDate(DateTime.now()),
        seen: false,
      );

      FirebaseFirestore.instance.collection("chatrooms").doc(widget.chatroom.chatroomid).collection("messages").
      doc(newMessage.messageid).set(newMessage.toMap());

      log("message sent!");

      widget.chatroom.lastMessage = msg;
      FirebaseFirestore.instance.collection("chatrooms").doc(widget.chatroom.chatroomid).set(widget.chatroom.toMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage("images/man.png"),
            ),
            SizedBox(
              width: 20,
            ),
            Column(
              children: [
                Text(widget.targetUser.fullName.toString(),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                Text("+91 "+widget.targetUser.mobile.toString(),
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("chatrooms").doc(widget.chatroom.chatroomid).
                  collection("messages").orderBy("createdon", descending: true).snapshots(),
                  builder: (context,snapshot){
                    if(snapshot.connectionState == ConnectionState.active){
                      if(snapshot.hasData){
                        QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;

                        return ListView.builder(
                            reverse: true,
                            itemCount: dataSnapshot.docs.length,
                            itemBuilder: (context,index){
                              MessageModel currentMessage = MessageModel.fromMap(dataSnapshot.docs[index].data() as Map<String,dynamic>);

                              return GestureDetector(
                                onLongPress: () {
                                  print("Long press detected on message: ${currentMessage.messageid}");
                                  showDeleteDialog(context, currentMessage.messageid!);
                                },
                                child: Row(
                                  mainAxisAlignment: (currentMessage.sender == widget.userModel.uid)?
                                  MainAxisAlignment.end : MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.symmetric(vertical: 2),
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: (currentMessage.sender == widget.userModel.uid)?
                                        Colors.grey : Theme.of(context).colorScheme.primary,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        currentMessage.text.toString(),
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                        );
                      }else if(snapshot.hasError){
                        return Center(
                          child: Text("An error occured!, Please check your internet connection"),
                        );
                      }else{
                        return Center(
                          child: Text("Say Hi👋 to your new friend"),
                        );
                      }
                    }
                    else{
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ),
            Container(
              color: Colors.grey[200],
              padding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 5,
              ),
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: messagingController,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter Message",
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: (){
                      sendMessage();
                    },
                    icon: Icon(Icons.send,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
