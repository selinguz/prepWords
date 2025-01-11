import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prep_words/consts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: textGreyColor),
              onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
            )
          : null,
      title: Text(
        title,
        style: TextStyle(color: textGreyColor),
      ),
      backgroundColor: primary,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: textGreyColor),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight * 1.2);
}
