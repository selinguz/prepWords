import 'package:flutter/material.dart';
import 'package:prep_words/components/custom_appbar.dart';
import 'package:prep_words/components/custom_textField.dart';
import 'package:prep_words/consts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'exaMate'),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              opacity: const AlwaysStoppedAnimation<double>(0.7),
              fit: BoxFit.cover,
            ),
          ),
          Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      controller: _nameController,
                      hintText: 'İsim',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen isminizi girin';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Email Adresi',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen email adresinizi girin';
                        }
                        // Basic email validation
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Lütfen geçerli bir email adresi girin';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'Şifre',
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen şifrenizi girin';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.7, // Make the button full-width
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        try {
                          // Kullanıcıyı kaydet
                          UserCredential userCredential = await FirebaseAuth
                              .instance
                              .createUserWithEmailAndPassword(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                          );

                          // Kullanıcının ismini güncelle
                          await userCredential.user
                              ?.updateDisplayName(_nameController.text.trim());

                          // Başarılı kayıt sonrası ana sayfaya yönlendir
                          Navigator.pushReplacementNamed(context, '/home');
                        } on FirebaseAuthException catch (e) {
                          // Hata durumunda mesaj göster
                          String errorMessage;
                          if (e.code == 'email-already-in-use') {
                            errorMessage = 'Bu email zaten kullanılıyor.';
                          } else if (e.code == 'weak-password') {
                            errorMessage =
                                'Şifre çok zayıf. Lütfen daha güçlü bir şifre deneyin.';
                          } else {
                            errorMessage = 'Bir hata oluştu: ${e.message}';
                          }
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(errorMessage),
                          ));

                          print(errorMessage);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary, // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      elevation: 8,
                    ),
                    child: Text(
                      'Kayıt Ol',
                      style: whiteButtonText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
