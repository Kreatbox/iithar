import 'package:flutter/material.dart';

class ContactWithus extends StatefulWidget {
  const ContactWithus({super.key});

  @override
  State<ContactWithus> createState() => _ContactWithusState();
}

class _ContactWithusState extends State<ContactWithus> {


  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _msgController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFAE0E03),
      appBar: AppBar(
        backgroundColor: Color(0xFFAE0E03),
      ),
      body: Container(
          child: Column(
              //mainAxisAlignment: MainAxisAlignment.end,
              children: [
            Padding(
              padding: const EdgeInsets.only(right: 25),
              child: Text(
                ' تواصل معنا في حال وجود مشاكل او مقترحات ',
                style: TextStyle(
                    fontSize: 25, fontFamily: 'HSI', color: Colors.white),
                textAlign: TextAlign.right,
              ),
            ),
            SizedBox(height: 28),
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
                      bottomRight: Radius.zero),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(right: 20,left: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 40,
                      ),
                      Text(
                        ' تواصل معنا  ',
                        style: TextStyle(
                            fontSize: 30,
                            fontFamily: 'HSI',
                            color: Colors.black),
                        textAlign: TextAlign.right,
                      ),
                  SizedBox(height: 28,),
                  _buildText(_nameController,'الاسم','يرجى ادخال الاسم'),
                  SizedBox(height: 28,),
                  _buildTextFieldemail(_emailController,'البريد الالكتروني','يرجى ادخال الايميل الالكتروني'),
                    SizedBox(height: 28,),
                  _buildTextFieldmsg(_msgController,'الرسالة','يرجى ادخال الرسالة '),
                      SizedBox(height: 60,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                fixedSize: const Size(160, 45),
                                backgroundColor: const Color(0xFFAE0E03),
                                padding: const EdgeInsets.only(
                                    right: 25.0, left: 25.0, top: 5.0, bottom: 1.0),
                                alignment: Alignment.center),
                            onPressed: () {
                              Navigator.pushNamed(context, '/nav');
                            },
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
                ))
          ])),
    );
  }
  Widget _buildText(
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
              return 'يرجى إدخال الاسم';
            }
            return null;
          },
        ));
  }




  Widget _buildTextFieldemail(
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
              return 'يرجى إدخال بريدك الإلكتروني';
            }
            return null;
          },
        ));
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
