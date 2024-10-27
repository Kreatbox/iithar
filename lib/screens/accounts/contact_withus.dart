// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContactWithus extends StatefulWidget {
  const ContactWithus({super.key});

  @override
  State<ContactWithus> createState() => _ContactWithusState();
}

class _ContactWithusState extends State<ContactWithus> {
  final _titleController = TextEditingController();
  final _msgController = TextEditingController();

  // Method to send message to Firestore
  Future<void> _sendMessage() async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle case where user is not logged in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to send a message')),
      );
      return;
    }

    // Prepare the message data
    final String userId = user.uid;
    final String title = _titleController.text.trim();
    final String message = _msgController.text.trim();

    // Send data to Firestore
    try {
      await FirebaseFirestore.instance.collection('messages').add({
        'userId': userId,
        'title': title,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(), // for sorting messages
      });

      _titleController.clear();
      _msgController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  'تم إرسال الرسالة بنجاح',
                  style: TextStyle(
                    fontFamily: 'HSI',
                    fontSize: 20,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFAE0E03),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.pushNamed(context, '/nav');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFAE0E03),
      appBar: AppBar(
        backgroundColor: const Color(0xFFAE0E03),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 25),
              child: Text(
                ' تواصل معنا في حال وجود مشاكل او مقترحات ',
                style: TextStyle(
                    fontSize: 25, fontFamily: 'HSI', color: Colors.white),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(height: 28),
            Container(
              width: 420,
              height: 670,
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                  bottomLeft: Radius.zero,
                  bottomRight: Radius.zero,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(right: 20, left: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      ' تواصل معنا  ',
                      style: TextStyle(
                          fontSize: 30, fontFamily: 'HSI', color: Colors.black),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 28),
                    _buildTextFieldtiitle(_titleController, 'العنوان',
                        'يرجى ادخال عنوان الرسالة'),
                    const SizedBox(height: 28),
                    _buildTextFieldmsg(
                        _msgController, 'الرسالة', 'يرجى ادخال الرسالة '),
                    const SizedBox(height: 60),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(160, 45),
                            backgroundColor: const Color(0xFFAE0E03),
                            padding: const EdgeInsets.only(
                                right: 25.0, left: 25.0, top: 5.0, bottom: 1.0),
                            alignment: Alignment.center,
                          ),
                          onPressed: _sendMessage,
                          child: const Text(
                            'أرسل',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'HSI',
                                fontSize: 25,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldtiitle(
      TextEditingController controller, String labelText, String errorText) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextFormField(
        controller: controller,
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontFamily: 'HSI',
          fontSize: 15,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          labelStyle: const TextStyle(
            fontFamily: 'HSI',
            fontSize: 15,
            color: Colors.black,
          ),
          labelText: labelText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          alignLabelWithHint: true,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'يرجى إدخال عنوان الرسالة';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTextFieldmsg(
      TextEditingController controller, String labelText, String errorText) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextFormField(
        controller: controller,
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontFamily: 'HSI',
          fontSize: 15,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return errorText;
          }
          return null;
        },
        maxLines: 7,
        keyboardType: TextInputType.multiline,
      ),
    );
  }
}
