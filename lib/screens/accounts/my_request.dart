import 'package:flutter/material.dart';

class MyRequestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(      backgroundColor: Colors.white,

        title: Align(
          alignment: Alignment.centerRight,
          child: Text(
            'تفاصيل طلب التبرع',
            style: TextStyle(
              fontFamily: 'HSI',
              fontSize: 30,
              color: Colors.black,
            ),
          ),
        ),
        elevation: 0, 
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          BloodDonationRequestCard(
            patientName: '  ',
            bloodType: '  ',
            city: '',
            donationLocation: ' ',
            medicalCondition: ' ',
            phoneNumber: ' ',
            donationDateTime: '   ',
            note: '',
          ),
        ],
      ),
    );
  }
}

class BloodDonationRequestCard extends StatelessWidget {
  final String patientName;
  final String bloodType;
  final String city;
  final String donationLocation;
  final String medicalCondition;
  final String phoneNumber;
  final String donationDateTime;
  final String note;

  const BloodDonationRequestCard({
    Key? key,
    required this.patientName,
    required this.bloodType,
    required this.city,
    required this.donationLocation,
    required this.medicalCondition,
    required this.phoneNumber,
    required this.donationDateTime,
    required this.note,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15), 
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(112, 112, 112, 0.2), 
            blurRadius: 5,   
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildInfoSection(Icons.person, 'اسم المريض', patientName),
            _buildInfoSection(Icons.bloodtype, 'زمرة الدم', bloodType),
            _buildInfoSection(Icons.location_city, 'المدينة', city),
            _buildInfoSection(Icons.location_on, 'موقع التبرع', donationLocation),
            _buildInfoSection(Icons.local_hospital, 'الحالة الطبية', medicalCondition),
            _buildInfoSection(Icons.phone, 'رقم الهاتف', phoneNumber),
            _buildInfoSection(Icons.calendar_today, 'تاريخ ووقت التبرع', donationDateTime),
            _buildInfoSection(Icons.note, 'ملاحظة', note),
            ButtonBar(
              children: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAE0E03),
                  ),
                  child: const Text(
                    'تعديل',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'HSI',
                      fontSize: 25,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAE0E03),
                  ),
                  child: const Text(
                    'حذف',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'HSI',
                      fontSize: 25,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


Widget _buildInfoSection(IconData icon, String label, String value) {
  return ListTile(
    
    leading: Icon(icon, size: 20.0, color: const Color(0xFFAE0E03)),
    title: Text(
      '$label: $value',
      style: TextStyle(
        fontFamily: 'HSI',
      ),
    ),
  );
}}
