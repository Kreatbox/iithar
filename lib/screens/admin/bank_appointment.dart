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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
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
                  const SizedBox(
                    width: 15,
                  ),
                  _filterChip(
                    context,
                    label: 'مواعيد اليوم',
                    isSelected: isDayliSelect,
                    onSelected: (value) {
                      setState(() {
                        isDayliSelect = value; // تحديث حالة الزر الأول
                      });
                    },
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  _filterChip(
                    context,
                    label: 'مواعيد الاسبوع',
                    isSelected: isWeekSelect,
                    onSelected: (value) {
                      setState(() {
                        isWeekSelect = value; // تحديث حالة الزر الأول
                      });
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
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
          borderRadius: BorderRadius.circular(
            40,
          ),
        ),
        label: SizedBox(
          width: 100,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'HSI',
              fontSize: 18,
              //color: Colors.black,
            ),
          ),
        ),
        selected: isSelected,
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
        checkmarkColor: Colors.white,
        selectedColor: const Color(0xFFAE0E03),
        onSelected: onSelected);
  }
}
