import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:iithar/screens/notification_screen.dart';

class DonationForm extends StatefulWidget {
  const DonationForm({super.key});

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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: Row(
          children: [
            const Text('استبيان التبرع بالدم'),
            const Spacer(),
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
              buildQuestion(
                'هل وزنك أقل من 50 كغ؟',
                (value) {
                  setState(() {
                    weightUnder50 = value;
                  });
                },
                weightUnder50,
              ),
              const SizedBox(height: 10),
              buildQuestion(
                'هل تتناول أي أدوية بانتظام؟',
                (value) {
                  setState(() {
                    heartOrLungProblems = value;
                  });
                },
                heartOrLungProblems,
              ),
              const SizedBox(height: 10),
              buildQuestion(
                'هل تعاني من أي حالات طبية مزمنة (مثل السكري، ارتفاع ضغط الدم، أمراض القلب)؟',
                (value) {
                  setState(() {
                    hadColdInLast28Days = value;
                  });
                },
                hadColdInLast28Days,
              ),
              const SizedBox(height: 10),
              buildQuestion(
                'هل تم تشخيصك بأي من الأمراض المعدية (مثل التهاب الكبد، فيروس نقص المناعة البشرية/الإيدز)؟',
                (value) {
                  setState(() {
                    hadCancer = value;
                  });
                },
                hadCancer,
              ),
              const SizedBox(height: 10),
              buildQuestion(
                'هل حصلت على وشم أو ثقب جسد خلال الأشهر الـ12 الماضية؟',
                (value) {
                  setState(() {
                    hasDiabetes = value;
                  });
                },
                hasDiabetes,
              ),
              const SizedBox(height: 10),
              buildQuestion(
                'هل أجريت أي عمليات جراحية خلال الأشهر الـ12 الماضية؟',
                (value) {
                  setState(() {
                    hadSurgeryInLast3Months = value;
                  });
                },
                hadSurgeryInLast3Months,
              ),
              const SizedBox(height: 10),
              buildQuestion(
                'هل تلقيت أي لقاحات خلال الأسابيع الأربعة الماضية؟',
                (value) {
                  setState(() {
                    hadVaccineInLast3Months = value;
                  });
                },
                hadVaccineInLast3Months,
              ),
              const SizedBox(height: 10),
              buildQuestion(
                'هل تم نقل دم لك أو تلقيت مشتقات دم خلال الأشهر الـ12 الماضية؟',
                (value) {
                  setState(() {
                    hadBloodTransfusionInLast12Months = value;
                  });
                },
                hadBloodTransfusionInLast12Months,
              ),
              const SizedBox(height: 10),
              buildQuestion(
                'هل توافق على إجراء اختبارات الدم اللازمة لضمان سلامة الدم المتبرع به؟',
                (value) {
                  setState(() {
                    agreedToBloodTests = value;
                  });
                },
                agreedToBloodTests,
              ),
              const SizedBox(height: 10),
              CheckboxListTile(
                title: const Text('أنت موافق على الأحكام والشروط'),
                value: acceptedTerms,
                onChanged: (newValue) {
                  setState(() {
                    acceptedTerms = newValue ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFAE0E03),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate() && acceptedTerms) {
                    // Create form answers string
                    String formAnswers = _getFormAnswersString();
                    try {
                      // Save form answers to Firestore
                      await _saveFormAnswers(formAnswers);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('الاستبيان مكتمل!')),
                      );
                      Navigator.pushReplacementNamed(context, '/nav');
                    } catch (e) {
                      if (kDebugMode) {
                        print('فشل حفظ الإجابات: ${e.toString()}');
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('فشل حفظ الإجابات')),
                      );
                    }
                  } else if (!acceptedTerms) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('يجب الموافقة على الأحكام والشروط')),
                    );
                  }
                },
                child: const Text('كن متبرعاً'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildQuestion(
      String question, Function(bool?) onChanged, bool? groupValue) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            question,
            style: const TextStyle(fontSize: 18),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('نعم'),
                  value: true,
                  groupValue: groupValue,
                  onChanged: onChanged,
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('لا'),
                  value: false,
                  groupValue: groupValue,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getFormAnswersString() {
    List<bool?> answers = [
      weightUnder50,
      heartOrLungProblems,
      hadColdInLast28Days,
      hadCancer,
      hasDiabetes,
      hadSurgeryInLast3Months,
      hadVaccineInLast3Months,
      hadBloodTransfusionInLast12Months,
      agreedToBloodTests,
    ];

    return answers.map((answer) => answer == true ? '1' : '0').join('');
  }

  Future<void> _saveFormAnswers(String formAnswers) async {
    User? user = _auth.currentUser;

    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'formAnswer': formAnswers,
      });
    } else {
      throw Exception('لم يتم العثور على المستخدم الحالي');
    }
  }
}
