import 'package:flutter/material.dart';
import 'package:prep_words/components/custom_appbar.dart';
import 'package:prep_words/components/custom_textField.dart';
import 'package:prep_words/consts.dart';

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
                      hintText: 'İsminiz',
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
                    onPressed: () {
                      //if (_formKey.currentState?.validate() ?? false) {
                      Navigator.pushReplacementNamed(context, '/home');
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
