import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
FirebaseUser loggedInUser;
final _firestore = Firestore.instance;
class ChatScreen extends StatefulWidget {
  static const String id = 'chat_Screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  String messageText;
  void getCurrentUser() async{
    try {
      final User = await _auth.currentUser();
      if (User != null) {
        loggedInUser = User;
      }
    }
    catch(e) {
      print(e);
    }
  }
  /* void getMessage () async{
   final messages =  await _firestore.collection('messages').getDocuments();
   for(var message in messages.documents){
     print(message.data);
   }
  }*/
  void messageStream() async{
    await for( var snapshot in _firestore.collection('messages').snapshots())
    {
      for(var message in snapshot.documents){
      }
    }
  }

  @override
  void initState(){
    super.initState();
    getCurrentUser();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('messages').snapshots(),
              builder:(context,snap){
                if(!snap.hasData){
                  return Center(
                    child:CircularProgressIndicator(),
                  );
                }

                final messages = snap.data.documents.reversed;
                List<MessageBubble> messageWidgets = [];
                for(var message in messages){
                  final messageText = message.data['text'];
                  final messageSender= message.data['sender'];
                  final currentUser = loggedInUser.email;

                  final messageWidget = MessageBubble(sender:messageSender,text:messageText,isme: currentUser == messageSender,);
                  messageWidgets.add(messageWidget);
                }
                return Expanded(
                  child: ListView(
                    reverse:true,
                    padding:EdgeInsets.symmetric(horizontal:10.0,vertical:20.0),
                    children:messageWidgets,
                  ),
                );

              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      //Implement send functionality.
                      _firestore.collection('messages').add(
                          {
                            'text':messageText,
                            'sender': loggedInUser.email,

                          });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
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

class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender,this.text,this.isme});
  final String sender;
  final String text;
  bool isme;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:EdgeInsets.all(10.0),
      child: Column(
          crossAxisAlignment: isme?CrossAxisAlignment.end:CrossAxisAlignment.start,
          children:<Widget>[
            Text(
                '$sender',
                style:TextStyle(
                  color:isme?Colors.white:Colors.black,
                )
            ),
            Material(
              borderRadius: isme?BorderRadius.only(topLeft:Radius.circular(30.00),bottomLeft: Radius.circular(30.0),bottomRight: Radius.circular(30.0)):BorderRadius.only(topRight:Radius.circular(30.00),bottomLeft: Radius.circular(30.0),bottomRight: Radius.circular(30.0)),
              elevation:5.0,
              color:isme?Colors.lightBlueAccent:Colors.white,
              child: Padding(
                padding:EdgeInsets.symmetric(vertical:10,horizontal:20),
                child: Text('$text ',
                    style:TextStyle(
                      fontSize: 15.0,
                    )

                ),
              ),
            ),]
      ),
    );
  }
}
