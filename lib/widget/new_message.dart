import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  var messageController = TextEditingController();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void submitText() async {
    final enteredMessage = messageController.text;
    if (enteredMessage.trim().isEmpty) {
      return;
    }
    messageController.clear();
    FocusScope.of(context).unfocus();
    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection('userFolder')
        .doc(user.uid)
        .get();

    FirebaseFirestore.instance.collection('chat').add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'userImage': userData.data()!['image'],
      'userName': userData.data()!['username']
    });
  
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, bottom: 14, right: 1),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: const InputDecoration(labelText: 'send message'),
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
            ),
          ),
          IconButton(onPressed: submitText, icon: const Icon(Icons.send))
        ],
      ),
    );
  }
}
