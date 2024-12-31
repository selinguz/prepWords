import 'package:flutter/material.dart';
import 'package:prep_words/components/custom_appbar.dart';
import 'package:prep_words/components/custom_textField.dart';
import 'package:prep_words/consts.dart';
import 'package:prep_words/pages/sign_up_page.dart';
import 'package:prep_words/pages/words_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  SignInPageState createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Şifremi Unuttum',
                      style: TextStyle(
                        color: warnOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.7, // Make the button full-width
                  child: ElevatedButton(
                    onPressed: () {
                      //if (_formKey.currentState?.validate() ?? false) {
                      Navigator.pushReplacementNamed(context, '/words');
                      //}
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary, // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      elevation: 8,
                    ),
                    child: const Text(
                      'Giriş Yap',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: textWhiteColor,
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
                  child: const Text(
                    'Hesabınız yok mu? Kaydolun',
                    style: TextStyle(
                        color: warnOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
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
