import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prep_words/consts.dart';

class ProfileContent extends StatefulWidget {
  const ProfileContent({super.key});

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  final TextEditingController _nameController =
      TextEditingController(text: 'Selin Güzel');
  final TextEditingController _emailController =
      TextEditingController(text: 'selin@example.com');
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: primary,
              child: Text(
                'SG',
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
              subtitle: _isEditing
                  ? _buildEditableField(_emailController)
                  : Text(
                      _emailController.text,
                      style: bodyMedium,
                    ),
            ),
            const SizedBox(height: 16),
            _buildProfileItem(
              icon: Icons.bar_chart,
              title: 'Toplam İlerleme',
              subtitle: Text(
                '%45',
                style: bodyMedium,
              ),
            ),
            const SizedBox(height: 16),
            _buildProfileItem(
              icon: Icons.calendar_today,
              title: 'Katılım Tarihi',
              subtitle: Text(
                '01.01.2024',
                style: bodyMedium,
              ),
            ),
            const SizedBox(height: 32),
            if (_isEditing) _buildSaveButton(),
          ],
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
      onPressed: () {
        setState(() {
          _isEditing = false;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        padding: EdgeInsets.all(14.0),
      ),
      child: const Text(
        'Kaydet',
        style: whiteButtonText,
      ),
    );
  }
}
