import 'package:flutter/material.dart';
import 'package:prep_words/components/custom_appbar.dart';
import 'package:prep_words/components/custom_textField.dart';
import 'package:prep_words/consts.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Email gerekli';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Şifre',
                  obscureText: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Şifre gerekli';
                    }
                    if (value!.length < 6) {
                      return 'Şifre en az 6 karakter olmalı';
                    }
                    return null;
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              elevation: 1,
                              child: Container(
                                height: MediaQuery.of(context).size.height / 4,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Şifre sıfırlama linki için email adresinizi giriniz:",
                                      style: bodyLarge,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(
                                      height: 3.5,
                                    ),
                                    CustomTextField(
                                      controller: _emailController,
                                      hintText: 'Email Adresi',
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Lütfen email adresinizi girin';
                                        }
                                        final emailRegex =
                                            RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                                        if (!emailRegex.hasMatch(value)) {
                                          return 'Lütfen geçerli bir email adresi girin';
                                        }
                                        return null;
                                      },
                                    ),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: secondaryOrange,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          'Gönder',
                                          style: greyButtonText,
                                        ),
                                        onPressed: () {
                                          Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            '/signin',
                                            ModalRoute.withName(" signin"),
                                          );
                                        })
                                  ],
                                ),
                              ),
                            );
                          });
                    },
                    child: Text(
                      'Şifremi Unuttum',
                      style: greyButtonText.copyWith(
                        color: warnOrange,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.15,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/signup');
                  },
                  child: Text(
                    'Hesabınız yok mu? Kaydolun',
                    style: headingMedium.copyWith(
                      color: warnOrange,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: warnOrange,
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
