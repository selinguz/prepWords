import 'package:flutter/material.dart';
import 'package:prep_words/components/custom_appbar.dart';
import 'package:prep_words/consts.dart';

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Profil'),
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
            Text(
              'Selin Güzel',
              style: headingLarge,
            ),
            const SizedBox(height: 32),
            _buildProfileItem(
              icon: Icons.email,
              title: 'E-posta',
              subtitle: 'selin@example.com',
            ),
            _buildProfileItem(
              icon: Icons.bar_chart,
              title: 'Toplam İlerleme',
              subtitle: '%45',
            ),
            _buildProfileItem(
              icon: Icons.calendar_today,
              title: 'Katılım Tarihi',
              subtitle: '01.01.2024',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: primary),
      title: Text(title, style: bodyLarge),
      subtitle: Text(subtitle, style: bodyMedium),
    );
  }
}
