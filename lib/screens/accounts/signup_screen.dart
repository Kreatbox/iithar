// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  var _isButtonDisabled = false;
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _ssidController = TextEditingController();
  final _birthDateController = TextEditingController();

  bool _isPasswordVisible = false;

  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];
  final List<String> _genderTypes = ['ذكر', 'انثى'];

  String _selectedBloodType = 'A+';
  String _selectedGenderType = 'ذكر,';

  @override
  void initState() {
    super.initState();
    if (!_bloodTypes.contains(_selectedBloodType)) {
      _selectedBloodType = _bloodTypes.first;
    }
    if (!_genderTypes.contains(_selectedGenderType)) {
      _selectedGenderType = _genderTypes.first;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    _ssidController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _showGenderDialog() async {
    final selectedGender = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'اختر الجنس',
            textAlign: TextAlign.center,
            style:
                TextStyle(fontFamily: 'HSI', fontSize: 25, color: Colors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _genderTypes.map((gender) {
              return ListTile(
                title: Text(
                  gender,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontFamily: 'HSI', fontSize: 18, color: Colors.black),
                ),
                onTap: () {
                  Navigator.of(context).pop(gender);
                },
              );
            }).toList(),
          ),
        );
      },
    );

    if (selectedGender != null) {
      setState(() {
        _selectedGenderType = selectedGender;
      });
    }
  }

  void _showBloodTypeDialog() async {
    final selectedBloodType = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'اختر فصيلة الدم',
            textAlign: TextAlign.center,
            style:
                TextStyle(fontFamily: 'HSI', fontSize: 25, color: Colors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _bloodTypes.map((bloodType) {
              return ListTile(
                title: Text(bloodType,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 18, color: Colors.black)),
                onTap: () {
                  Navigator.of(context).pop(bloodType);
                },
              );
            }).toList(),
          ),
        );
      },
    );

    if (selectedBloodType != null) {
      setState(() {
        _selectedBloodType = selectedBloodType;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'إنشاء حساب ',
            textAlign: TextAlign.right,
            style:
                TextStyle(fontFamily: 'HSI', fontSize: 40, color: Colors.black),
          ),
        ),
      ),
      body: Stack(children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _buildInfoSection('المعلومات الشخصية', [
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          _firstNameController,
                          'الاسم الأول',
                          'يرجى إدخال اسمك الأول',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يرجى إدخال اسمك الأول';
                            }
                            if (value.length > 25) {
                              return 'الاسم يجب أن يكون أقل من 25 حرفًا';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(
                          _lastNameController,
                          'اسم العائلة',
                          'يرجى إدخال اسم عائلتك',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يرجى إدخال اسم عائلتك';
                            }
                            if (value.length > 25) {
                              return 'الاسم يجب أن يكون أقل من 25 حرفًا';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    _ssidController,
                    'الرقم الوطني',
                    'يرجى إدخال رقمك القومي',
                    isNumber: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال رقمك القومي';
                      }
                      if (value.length != 11) {
                        return 'الرقم الوطني غير صحيح';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    _phoneNumberController,
                    'رقم الهاتف',
                    'يرجى إدخال رقم هاتفك',
                    isPhone: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال رقم هاتفك';
                      }
                      if (value.length < 10 || value.length > 15) {
                        return 'رقم الهاتف غير صحيح';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildDatePickerField(
                    _birthDateController,
                    'تاريخ الميلاد',
                    'يرجى إدخال تاريخ ميلادك',
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDialogField('فصيلة الدم',
                            _selectedBloodType, _showBloodTypeDialog),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDialogField(
                            'الجنس', _selectedGenderType, _showGenderDialog),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    _emailController,
                    'البريد الإلكتروني',
                    'يرجى إدخال بريدك الإلكتروني',
                    isEmail: true,
                    validator: (value) {
                      String pattern =
                          r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-]{2,}$";
                      RegExp regex = RegExp(pattern);
                      if (!regex.hasMatch(value)) {
                        return 'يرجى إدخال بريد إلكتروني صحيح';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildPasswordTextField(),
                  const SizedBox(height: 10),
                ]),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(175, 45),
                    backgroundColor: const Color(0xFFAE0E03),
                    padding: const EdgeInsets.only(
                        right: 25.0, left: 25.0, top: 5.0, bottom: 1.0),
                    alignment: Alignment.center,
                  ),
                  onPressed: _isButtonDisabled
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isButtonDisabled = true;
                            });
                            try {
                              UserCredential userCredential =
                                  await _auth.createUserWithEmailAndPassword(
                                email: _emailController.text,
                                password: _passwordController.text,
                              );

                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userCredential.user!.uid)
                                  .set({
                                'firstName': _firstNameController.text,
                                'lastName': _lastNameController.text,
                                'email': _emailController.text,
                                'phoneNumber': _phoneNumberController.text,
                                'ssid': _ssidController.text,
                                'birthDate': _birthDateController.text,
                                'bloodType': _selectedBloodType,
                                'genderType': _selectedGenderType,
                              });

                              Navigator.pushReplacementNamed(context, '/form');
                            } catch (e) {
                              if (kDebugMode) {
                                print('فشل إنشاء الحساب: ${e.toString()}');
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('فشل إنشاء الحساب')),
                              );
                              setState(() {
                                _isButtonDisabled = false;
                              });
                            }
                          }
                        },
                  child: const Text(
                    'إنشاء حساب',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'HSI', fontSize: 25, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildDatePickerField(
      TextEditingController controller, String labelText, String errorText) {
    return InkWell(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime(1990),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFFAE0E03),
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFAE0E03),
                  ),
                ),
                dialogTheme:
                    const DialogThemeData(backgroundColor: Colors.white),
              ),
              child: child!,
            );
          },
        );

        if (pickedDate != null) {
          String formattedDate =
              "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
          controller.text = formattedDate;
        }
      },
      child: AbsorbPointer(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelStyle: const TextStyle(
                fontFamily: 'HSI',
                fontSize: 15,
                color: Colors.black,
              ),
              labelText: labelText,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              alignLabelWithHint: true,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return errorText;
              }
              try {
                DateTime birthDate = DateTime.parse(value);
                DateTime today = DateTime.now();
                int age = today.year - birthDate.year;
                if (today.month < birthDate.month ||
                    (today.month == birthDate.month &&
                        today.day < birthDate.day)) {
                  age--;
                }
                if (age < 18) {
                  return 'يجب أن تكون أكبر من 18 عامًا';
                }
              } catch (e) {
                return 'يرجى إدخال تاريخ ميلاد صحيح';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordTextField() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextFormField(
        textAlign: TextAlign.right,
        controller: _passwordController,
        obscureText: !_isPasswordVisible,
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
          labelText: 'كلمة المرور',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          alignLabelWithHint: true,
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'يرجى إدخال كلمة المرور';
          }
          if (value.length < 8) {
            return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
          }
          bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
          bool hasLowercase = value.contains(RegExp(r'[a-z]'));
          bool hasDigits = value.contains(RegExp(r'[0-9]'));
          if (!(hasUppercase && hasLowercase && hasDigits)) {
            return 'كلمة المرور يجب أن تحتوي على أحرف كبيرة وصغيرة، وأرقام';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String labelText,
    String errorText, {
    bool isEmail = false,
    bool isPhone = false,
    bool isNumber = false,
    bool isDate = false,
    required String? Function(dynamic value) validator,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextFormField(
        textAlign: TextAlign.right,
        controller: controller,
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
        keyboardType: isEmail
            ? TextInputType.emailAddress
            : isPhone
                ? TextInputType.phone
                : isNumber
                    ? TextInputType.number
                    : isDate
                        ? TextInputType.datetime
                        : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return errorText;
          }
          return validator(value);
        },
      ),
    );
  }

  Widget _buildDialogField(String labelText, String value, Function onTap) {
    return InkWell(
      onTap: () => onTap(),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          alignLabelWithHint: true,
        ),
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontFamily: 'HSI',
            fontSize: 15,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(112, 112, 112, 100),
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 25,
                ),
              ),
              const Divider(
                height: 22,
                thickness: 1.5,
              ),
              ...children,
            ],
          ),
        ));
  }
}
