import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/widget/user_image_picker.dart';

final firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var islogin = true;
  var submittedEmail = '';
  var submittedPaword = '';
  var enteredUserName = '';
  File? selectedImage;
  final formkey = GlobalKey<FormState>();

  bool isAuthentication = false;
  // final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void submit() async {
    final isvalid = formkey.currentState!.validate();

    // if (!isvalid || selectedImage == null) {
    //  return;
    //}

    formkey.currentState!.save();
    try {
      setState(() {
        isAuthentication = true;
      });
      if (islogin) {
        final userKrudential = await firebase.signInWithEmailAndPassword(
            email: submittedEmail, password: submittedPaword);
      } else {
        final userCredential = await firebase.createUserWithEmailAndPassword(
            email: submittedEmail, password: submittedPaword);
        final storegRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredential.user!.uid}.jpeg');

        await storegRef.putFile(selectedImage!);
        final imageUrl = await storegRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('userFolder')
            .doc(userCredential.user!.uid)
            .set({
          'username': enteredUserName,
          'email': submittedEmail,
          'image': imageUrl,
          'password': submittedPaword
        });
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        //
      }
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Authentcation faild')));
    }
    setState(() {
      isAuthentication = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              const SizedBox(
                height: 20,
              ),
              Card(
                margin: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: formkey,
                    child: Column(
                      children: [
                        if (!islogin)
                          UserImage(
                            onpickedImage: (pickImage) {
                              selectedImage = pickImage;
                            },
                          ),
                        TextFormField(
                          decoration: const InputDecoration(
                              labelText: 'Enter Your Gmail'),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains('@')) {
                              return 'Enter Valid Email';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            submittedEmail = value!;
                          },
                        ),
                        if (!islogin)
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'enter username'),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.trim().length < 5) {
                                return 'enterd atlest 5 cherector';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              enteredUserName = value!;
                            },
                          ),
                        TextFormField(
                          decoration:
                              const InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                value.length < 6) {
                              return 'Enter Password 6 digit';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            submittedPaword = value!;
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        if (isAuthentication) const CircularProgressIndicator(),
                        if (!isAuthentication)
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer),
                              onPressed: submit,
                              child: Text(islogin ? 'login' : 'signup')),
                        if (!isAuthentication)
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  islogin = !islogin;
                                });
                              },
                              child: Text(islogin
                                  ? 'creat an account'
                                  : 'i already have an account'))
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
