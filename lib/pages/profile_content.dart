// ignore_for_file: use_build_context_synchronously
import 'package:prep_words/models/word.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prep_words/consts.dart';

class ProfileContent extends StatefulWidget {
  final void Function(String)? onNameUpdated; // callback ekle

  const ProfileContent({super.key, this.onNameUpdated});

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isEditing = false;

  int _knownWordCount = 0;
  final int _totalWords = 960;

  Future<void> _calculateProgress() async {
    final prefs = await SharedPreferences.getInstance();

    int count = 0;

    // Tüm prefs keylerini dolaş
    for (var key in prefs.getKeys()) {
      if (key.startsWith("word_status_")) {
        final status = prefs.getString(key);
        if (status == WordStatus.known.toString()) {
          count++;
        }
      }
    }

    setState(() {
      _knownWordCount = count;
    });
  }

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;

    _nameController = TextEditingController(text: user?.displayName ?? "");
    _emailController = TextEditingController(text: user?.email ?? "");

    _calculateProgress();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String getInitials(String name) {
    if (name.trim().isEmpty) return "?";

    final parts = name.trim().split(" ");
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    } else {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? "";

    final creationTime = user?.metadata.creationTime;
    final formattedDate = creationTime != null
        ? "${creationTime.day.toString().padLeft(2, '0')}.${creationTime.month.toString().padLeft(2, '0')}.${creationTime.year}"
        : "-";

    double progress = (_knownWordCount / _totalWords) * 100;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight * 1.2,
        backgroundColor: primary,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textGreyColor),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Text(
          'Profil',
          style: headingLarge.copyWith(fontSize: 30),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(
                right: MediaQuery.of(context).size.width * 0.03),
            child: IconButton(
              icon: Icon(
                Icons.edit,
                color: textGreyColor,
                size: 32.0,
              ),
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                });
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: primary,
                child: Text(
                  getInitials(displayName),
                  style: TextStyle(
                    fontSize: 32,
                    color: textWhiteColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildProfileItem(
                icon: Icons.person,
                title: 'İsim Soyisim',
                subtitle: _isEditing
                    ? _buildEditableField(_nameController)
                    : Text(
                        _nameController.text,
                        style: bodyMedium,
                      ), // Wrap text in a Text widget
              ),
              const SizedBox(height: 16),
              _buildProfileItem(
                icon: Icons.email,
                title: 'E-posta',
                subtitle: Text(
                  _emailController.text, // artık sadece gösterim
                  style: bodyMedium,
                ),
              ),
              const SizedBox(height: 16),
              _buildProfileItem(
                icon: Icons.bar_chart,
                title: 'Toplam İlerleme',
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '%${progress.toStringAsFixed(1)}',
                      style: bodyMedium,
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: progress / 100,
                      backgroundColor: Colors.grey[300],
                      color: primary,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildProfileItem(
                icon: Icons.calendar_today,
                title: 'Katılım Tarihi',
                subtitle: Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 32),
              (_isEditing)
                  ? _buildSaveButton()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        padding: EdgeInsets.all(14.0),
                      ),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushReplacementNamed(context, '/signin');
                      },
                      child: const Text(
                        "Çıkış Yap",
                        style: whiteButtonText,
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required Widget subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: primary),
      title: Text(title, style: bodyLarge),
      subtitle: subtitle,
    );
  }

  Widget _buildEditableField(TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Düzenle',
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.updateDisplayName(_nameController.text.trim());
          await user.reload();

          // Ana ekrana callback ile güncel ismi gönder
          if (widget.onNameUpdated != null) {
            widget.onNameUpdated!(_nameController.text.trim());
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('İsim başarıyla güncellendi.'),
              duration: Duration(seconds: 2),
            ),
          );
        }

        setState(() {
          _isEditing = false;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        padding: const EdgeInsets.all(14.0),
      ),
      child: const Text(
        'Kaydet',
        style: whiteButtonText,
      ),
    );
  }
}
