import 'package:flutter/material.dart';

class BankRecords extends StatefulWidget {
  const BankRecords({super.key});

  @override
  State<BankRecords> createState() => _BankRecordsState();

}

class _BankRecordsState extends State<BankRecords> {
  final List<String> bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-'
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:AppBar(
        backgroundColor: Colors.white,
        title: const Align(
        alignment: Alignment.centerRight,
        child: Text(
        'سجلات البنك',
        textAlign: TextAlign.right,
        style:
        TextStyle(fontFamily: 'HSI', fontSize: 30, color: Colors.black),
    ),
    )),
      body:    Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "التاريخ",
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 22,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 25),
              Text(
                "الكمية الحالية",
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 22,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                width: 25,
              ),
              Text(
                "الزمرة",
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 22,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const Divider(
            color: Color(0xFFAE0E03),
            thickness: 5,
          ),
          Expanded(
            child: GridView.builder(
              itemCount: bloodTypes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 8.0, // Adjust to fit items properly in a row
              ),
              itemBuilder: (context, index) {
                String bloodType = bloodTypes[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                       Text("2024"),
                  SizedBox(
                      width: 30,
                      child: Text(
                        '100',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'HSI',
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),

                      ),
                      SizedBox(
                        width: 50,
                        child: Text(
                          bloodType,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'HSI',
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),



               ]) );
              },
            ),
          ),
        ],
      ),



    );
  }}
