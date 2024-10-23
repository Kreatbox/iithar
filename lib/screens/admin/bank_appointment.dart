import 'package:flutter/material.dart';

class BankAppintment extends StatefulWidget {
  const BankAppintment({super.key});

  @override
  State<BankAppintment> createState() => _BankAppintmentState();
}

class _BankAppintmentState extends State<BankAppintment> {
  bool isMonthSelecte = false;
  bool isDayliSelect = false;
  bool isWeekSelect = false;

  List<DonationRequest> donationRequests = [
    DonationRequest(
      firstName: 'أحمد ',
      lastName: '',
      bloodType: 'O+',
      ssid: '123456789',
      dateTime: DateTime.now(),
      status: 'قيد الانتظار', 
    ),
    DonationRequest(
      firstName: 'سارة ',
      lastName: '',
      bloodType: 'A-',
      ssid: '987654321',
      dateTime: DateTime.now(),
      status: 'قيد الانتظار', 
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'مواعيد التبرع',
            style: TextStyle(
              fontFamily: 'HSI',
              fontSize: 30,
              color: Colors.black,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _filterChip(
                    context,
                    label: 'مواعيد الشهر',
                    isSelected: isMonthSelecte,
                    onSelected: (value) {
                      setState(() {
                        isMonthSelecte = value; // تحديث حالة الزر الأول
                      });
                    },
                  ),
                  const SizedBox(width: 15),
                  _filterChip(
                    context,
                    label: 'مواعيد اليوم',
                    isSelected: isDayliSelect,
                    onSelected: (value) {
                      setState(() {
                        isDayliSelect = value; // تحديث حالة الزر الثاني
                      });
                    },
                  ),
                  const SizedBox(width: 15),
                  _filterChip(
                    context,
                    label: 'مواعيد الاسبوع',
                    isSelected: isWeekSelect,
                    onSelected: (value) {
                      setState(() {
                        isWeekSelect = value; // تحديث حالة الزر الثالث
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20), 
          Expanded(
            child: ListView.builder(
              itemCount: donationRequests.length,
              itemBuilder: (context, index) {
                DonationRequest request = donationRequests[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(width: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Row(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shadowColor: const Color.fromRGBO(112, 112, 112, 0.4),
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            _confirmDonation(request); 
                          },
                          child: const Text(
                            'تأكيد التبرع',
                            style: TextStyle(
                              fontFamily: 'BAHIJ',
                              fontSize: 18,
                              color: Color(0xFFAE0E03),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'اسم المتبرع: ${request.firstName+request.firstName}',
                                style: const TextStyle(
                                  fontFamily: 'HSI',
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                              Text('زمرة الدم: ${request.bloodType}', style: const TextStyle(
                                fontFamily: 'HSI',
                                fontSize: 18,
                                color: Colors.black,
                              )),
                              Text('الرقم الوطني: ${request.ssid}', style: const TextStyle(
                                fontFamily: 'HSI',
                                fontSize: 18,
                                color: Colors.black,
                              )),
                              Text('تاريخ ووقت التبرع: ${request.dateTime.toLocal()}', style: const TextStyle(
                                fontFamily: 'HSI',
                                fontSize: 18,
                                color: Colors.black,
                              )),
                              Text('حالة التبرع: ${request.status}', style: const TextStyle(
                                fontFamily: 'HSI',
                                fontSize: 18,
                                color: Colors.black,
                              )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDonation(DonationRequest request) {
  setState(() {
    request.status = 'تم التبرع'; 
  });

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'تأكيد التبرع',
              style: TextStyle(
                fontFamily: 'HSI',
                fontSize: 25,
                color: Colors.black,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(height: 16), 
            Text(
              'تم تأكيد التبرع بنجاح',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'HSI',
                fontSize: 25,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFAE0E03),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text(
              'موافق',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'HSI',
                fontSize: 25,
                color: Colors.white,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFAE0E03),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text(
              'إلغاء',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'HSI',
                fontSize: 25,
                color: Colors.white,
              ),
            ),
            onPressed: () {
              setState(() {
                request.status = 'قيد الانتظار';
              });
              Navigator.of(context).pop(); 
            },
          ),
        ],
      );
    },
  );
}


  Widget _filterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
  }) {
    return FilterChip(
      labelPadding: const EdgeInsets.all(0),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40),
      ),
      label: SizedBox(
        width: 100,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'HSI',
            fontSize: 18,
          ),
        ),
      ),
      selected: isSelected,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      checkmarkColor: Colors.white,
      selectedColor: const Color(0xFFAE0E03),
      onSelected: onSelected,
    );
  }
}

class DonationRequest {
  final String firstName;
  final String lastName;
  final String bloodType;
  final String ssid;
  final DateTime dateTime;
  String status; 

  DonationRequest({
    required this.firstName,
    required this.lastName,
    required this.bloodType,
    required this.ssid,
    required this.dateTime,
    this.status = 'قيد الانتظار', 
  });
}
