import 'package:flutter/material.dart';
import 'package:iithar/screens/notification_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blood Donation App',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: DonationForm(),
    );
  }
}

class DonationForm extends StatefulWidget {
  @override
  _DonationFormState createState() => _DonationFormState();
}

class _DonationFormState extends State<DonationForm> {
  final _formKey = GlobalKey<FormState>();
  bool? weightUnder50;
  bool? heartOrLungProblems;
  bool? hadColdInLast28Days;
  bool? hadCancer;
  bool? hasDiabetes;
  bool? hadSurgeryInLast3Months;
  bool? hadVaccineInLast3Months;
  bool? hadBloodTransfusionInLast12Months;
  bool? agreedToBloodTests;
  bool acceptedTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: Row(
          children: [
            Text('استبيان التبرع بالدم'),
            Spacer(),
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const NotificationsScreen();
                }));
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // Question 1
              buildQuestion(
                'هل وزنك أقل من 50 كغ؟',
                (value) {
                  setState(() {
                    weightUnder50 = value;
                  });
                },
              ),
              SizedBox(height: 10),

              // Question 2
              buildQuestion(
                'هل تتناول أي أدوية بانتظام؟',
                (value) {
                  setState(() {
                    heartOrLungProblems = value;
                  });
                },
              ),
              SizedBox(height: 10),

              // Question 3
              buildQuestion(
                'هل تعاني من أي حالات طبية مزمنة (مثل السكري، ارتفاع ضغط الدم، أمراض القلب)؟',
                (value) {
                  setState(() {
                    hadColdInLast28Days = value;
                  });
                },
              ),
              SizedBox(height: 10),

              // Question 4
              buildQuestion(
                'هل تم تشخيصك بأي من الأمراض المعدية (مثل التهاب الكبد، فيروس نقص المناعة البشرية/الإيدز)؟',
                (value) {
                  setState(() {
                    hadCancer = value;
                  });
                },
              ),
              SizedBox(height: 10),

              // Question 5
              buildQuestion(
                'هل حصلت على وشم أو ثقب جسد خلال الأشهر الـ12 الماضية؟',
                (value) {
                  setState(() {
                    hasDiabetes = value;
                  });
                },
              ),
              SizedBox(height: 10),

              // Question 6
              buildQuestion(
                'هل أجريت أي عمليات جراحية خلال الأشهر الـ12 الماضية؟',
                (value) {
                  setState(() {
                    hadSurgeryInLast3Months = value;
                  });
                },
              ),
              SizedBox(height: 10),

              // Question 7
              buildQuestion(
                'هل تلقيت أي لقاحات خلال الأسابيع الأربعة الماضية؟',
                (value) {
                  setState(() {
                    hadVaccineInLast3Months = value;
                  });
                },
              ),
              SizedBox(height: 10),

              // Question 8
              buildQuestion(
                'هل تم نقل دم لك أو تلقيت مشتقات دم خلال الأشهر الـ12 الماضية؟',
                (value) {
                  setState(() {
                    hadBloodTransfusionInLast12Months = value;
                  });
                },
              ),
              SizedBox(height: 10),

              // Question 9
              buildQuestion(
                'هل توافق على إجراء اختبارات الدم اللازمة لضمان سلامة الدم المتبرع به؟',
                (value) {
                  setState(() {
                    agreedToBloodTests = value;
                  });
                },
              ),
              SizedBox(height: 10),

              // Terms and Conditions
              CheckboxListTile(
                title: Text('أنت موافق على الأحكام والشروط'),
                value: acceptedTerms,
                onChanged: (newValue) {
                  setState(() {
                   acceptedTerms = newValue?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFAE0E03),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate() && acceptedTerms) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('الاستبيان مكتمل!')),
                    );
                  } else if (!acceptedTerms) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('يجب الموافقة على الأحكام والشروط')),
                    );
                  }
                },
                child: Text('كن متبرعاً'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildQuestion(String question, Function(bool?) onChanged) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            question,
            style: TextStyle(fontSize: 18),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: RadioListTile<bool>(
                  title: Text('نعم'),
                  value: true,
                  groupValue: null,
                  onChanged: onChanged,
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  title: Text('لا'),
                  value: false,
                  groupValue: null,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}