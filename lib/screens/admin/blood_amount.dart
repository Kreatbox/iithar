import 'package:flutter/material.dart';

class BloodAmount extends StatefulWidget {
  const BloodAmount({super.key});

  @override
  State<BloodAmount> createState() => _BloodAmountState();
}

class _BloodAmountState extends State<BloodAmount> {
  // قائمة الزمر الدموية
  final List<String> bloodTypes = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  // قائمة قيم كل زمرة
  final Map<String, int> bloodTypeQuantities = {
    'A+': 0,
    'A-': 0,
    'B+': 0,
    'B-': 0,
    'O+': 0,
    'O-': 0,
    'AB+': 0,
    'AB-': 0,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'فئات الدم في البنك',
            textAlign: TextAlign.right,
            style: TextStyle(fontFamily: 'HSI', fontSize: 30, color: Colors.black),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "تصفير",
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: 'HSI',
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),SizedBox(width: 45,),
                Text(
                  "التعديل",
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: 'HSI',
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),SizedBox(width: 60,),
                Text(
                  "الزمرة",
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: 'HSI',
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width:40,),
                Text(
                  "الكمية الحالية",
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: 'HSI',
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const Divider(color:Color(0xFFAE0E03),
            thickness: 5,),
            Expanded(
              child: ListView.builder(
                itemCount: bloodTypes.length, // عدد العناصر في القائمة
                itemBuilder: (context, index) {
                  String bloodType = bloodTypes[index]; // كل زمرة دموية
                  int currentQuantity = bloodTypeQuantities[bloodType]!; // الكمية الحالية
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Color(0xFFAE0E03),size: 30,),
                          onPressed: () {
                            setState(() {
                              bloodTypeQuantities[bloodType] = 0;
                            });
                          },
                        ),
                        _CustomizableCounter(
                          initialCount: currentQuantity,
                          onChanged: (newQuantity) {
                            setState(() {
                              bloodTypeQuantities[bloodType] = newQuantity; // تحديث الكمية
                            });
                          },
                        ),
                        SizedBox(width: 20,),
                        Text(
                          "$currentQuantity",
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontFamily: 'HSI',
                            fontSize: 25,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 75,),
                        Text(
                          "$bloodType ",
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontFamily: 'HSI',
                            fontSize: 25,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 0,),

                      ],
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(180, 45),
                backgroundColor: const Color(0xFFAE0E03),
                padding: const EdgeInsets.only(
                    right: 25.0,
                    left: 25.0,
                    top: 5.0,
                    bottom: 1.0),
                alignment: Alignment.center,
              ),
              onPressed: () {
              },
              child: const Text(
                'إضافة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 25,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _CustomizableCounter({
    required int initialCount,
    required Function(int) onChanged,
  }) {
    TextEditingController controller = TextEditingController(text: initialCount.toString());

    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFAE0E03),
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(

        children: [
          IconButton(
            icon: Icon(Icons.remove, color: Colors.white),
            onPressed: () {
              int currentCount = int.tryParse(controller.text) ?? initialCount;
              if (currentCount > 0) {
                setState(() {
                  currentCount--;
                  controller.text = currentCount.toString();
                  onChanged(currentCount);
                });
              }
            },
          ),
          SizedBox(
            width: 20,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'HSI',
                fontSize: 25,
                color: Colors.white,
              ),
              onSubmitted: (value) {
                int newValue = int.tryParse(value) ?? initialCount;
                setState(() {
                  controller.text = newValue.toString();
                  onChanged(newValue);
                });
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              int currentCount = int.tryParse(controller.text) ?? initialCount;
              setState(() {
                currentCount++;
                controller.text = currentCount.toString();
                onChanged(currentCount);
              });
            },
          ),
        ],
      ),
    );
  }
}
