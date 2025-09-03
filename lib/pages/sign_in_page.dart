// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prep_words/components/custom_appbar.dart';
import 'package:prep_words/components/custom_text_field.dart';
import 'package:prep_words/consts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  SignInPageState createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  // SharedPreferences'den rememberMe bilgisini yükle
  void _loadRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? remember = prefs.getBool('rememberMe');
    String? savedEmail = prefs.getString('savedEmail');
    if (remember == true) {
      setState(() {
        _rememberMe = true;
        _emailController.text = savedEmail!;
      });
    }
  }

  // SharedPreferences'e kaydet
  void _saveRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool('rememberMe', true);
      await prefs.setString('savedEmail', _emailController.text.trim());
    } else {
      await prefs.remove('rememberMe');
      await prefs.remove('savedEmail');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'exaMate'),
      resizeToAvoidBottomInset: true, // klavyeye göre yer aç
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              opacity: const AlwaysStoppedAnimation<double>(0.7),
              fit: BoxFit.cover,
            ),
          ),

          // ÖN PLAN
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bottomInset = MediaQuery.of(context)
                    .viewInsets
                    .bottom; // klavye yüksekliği
                final keyboardOpen = bottomInset > 0;

                return AnimatedPadding(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.only(
                      bottom: bottomInset), // klavye kadar yukarı kaldır
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: Center(
                        // klavye kapalıyken ortada durur
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize:
                                MainAxisSize.min, // önemli: aşırı yer kaplama
                            children: [
                              // --- Email
                              CustomTextField(
                                controller: _emailController,
                                hintText: 'E-mail',
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'E-mail is required';
                                  }
                                  return null;
                                },
                              ),

                              // --- Şifre
                              CustomTextField(
                                controller: _passwordController,
                                hintText: 'Password',
                                obscureText: !_isPasswordVisible,
                                suffixIcon: IconButton(
                                  icon: Icon(_isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Password is required';
                                  }
                                  if (value!.length < 6) {
                                    return 'The password must be at least 6 characters long.';
                                  }
                                  return null;
                                },
                              ),

                              // --- Beni hatırla & Şifremi unuttum
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          activeColor: const Color(0xFFF5A623),
                                          value: _rememberMe,
                                          onChanged: (value) {
                                            setState(() {
                                              _rememberMe = value ?? false;
                                            });
                                          },
                                        ),
                                        Text("Remember me",
                                            style: greyButtonText),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // şifre sıfırlama dialog'un
                                      // ...
                                    },
                                    child: Text('Forgot your password?',
                                        style: greyButtonText.copyWith(
                                            color: warnOrange)),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // --- Giriş butonu
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      try {
                                        await FirebaseAuth.instance
                                            .signInWithEmailAndPassword(
                                          email: _emailController.text.trim(),
                                          password:
                                              _passwordController.text.trim(),
                                        );
                                        _saveRememberMe();
                                        Navigator.pushReplacementNamed(
                                            context, '/home');
                                      } on FirebaseAuthException catch (e) {
                                        String errorMessage;
                                        if (e.code == 'user-not-found') {
                                          errorMessage =
                                              'No such user was found.';
                                        } else if (e.code == 'wrong-password') {
                                          errorMessage =
                                              'The password is incorrect. Please try again.';
                                        } else {
                                          errorMessage =
                                              'An error occured: ${e.message}';
                                        }
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(errorMessage)));
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14.0),
                                    elevation: 8,
                                  ),
                                  child:
                                      Text('Sign In', style: whiteButtonText),
                                ),
                              ),

                              // --- Alt boşluk: klavye kapalıyken büyük, açıksa küçük
                              SizedBox(height: keyboardOpen ? 12 : 40),

                              // --- Kayıt bağlantısı
                              TextButton(
                                onPressed: () => Navigator.pushReplacementNamed(
                                    context, '/signup'),
                                child: Text(
                                  'Don\'t have an account? Sign up',
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
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
