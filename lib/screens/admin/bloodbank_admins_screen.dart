import 'package:flutter/material.dart';
import '../../models/blood_bank.dart';
import '../../services/data_service.dart';

class BloodbankAdminScreen extends StatelessWidget {
  const BloodbankAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String role = ModalRoute.of(context)!.settings.arguments as String;
    final DataService dataService = DataService();
    Future<List<BloodBank>> bloodBanksFuture = dataService.loadBankData();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FutureBuilder<List<BloodBank>>(
          future: bloodBanksFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('Error loading data');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No blood banks found');
            } else {
              final bloodBanks = snapshot.data!;
              final BloodBank bloodBank = bloodBanks.firstWhere(
                (bank) => bank.bankId == role,
              );

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'انت المشرف على البنك رقم $role',
                    style: const TextStyle(
                      fontFamily: 'HSI',
                      fontSize: 30,
                      color: Color(0xFFAE0E03),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'انت المشرف على ${bloodBank.name}',
                    style: const TextStyle(
                      fontFamily: 'HSI',
                      fontSize: 30,
                      color: Color(0xFFAE0E03),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'مرحباً بك في لوحة التحكم الخاصة بإدارة بنك الدم\n حافظ على تنظيم وتدفق التبرعات لضمان حياة أفضل للجميع',
                    style: TextStyle(
                      fontFamily: 'HSI',
                      fontSize: 20,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/adminscreen', (routr) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFAE0E03),
                    ),
                    child: const Text(
                      'الانتقال إلى الصفحة الرئيسية',
                      style: TextStyle(
                        fontFamily: 'HSI',
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
