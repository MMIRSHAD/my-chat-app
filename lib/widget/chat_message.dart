import 'package:chat_app/widget/message_bubble.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (ctx, chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No message Found'),
            );
          }
          if (chatSnapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }
          final lodedMessage = chatSnapshot.data!.docs;
          return ListView.builder(
              reverse: true,
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 30),
              itemCount: lodedMessage.length,
              itemBuilder: (ctx, index) {
                final chatMessage = lodedMessage[index].data();
                final nextChatMessage = index + 1 < lodedMessage.length
                    ? lodedMessage[index + 1]
                    : null;
                final currentMessageUserId = chatMessage['userId'];
                final nextMessageUserId =
                    nextChatMessage != null ? nextChatMessage['userId'] : null;
                final nextUserisSame =
                    nextMessageUserId == currentMessageUserId;
                if (nextUserisSame) {
                  return MessageBubble.next(
                      message: chatMessage['text'],
                      isMe: authenticatedUser.uid == currentMessageUserId);
                } else {
                  return MessageBubble.first(
                      userImage: chatMessage['userImage'],
                      username: chatMessage['userName'],
                      message: chatMessage['text'],
                      isMe: authenticatedUser.uid == currentMessageUserId);
                }
              });
        });
  }
}
