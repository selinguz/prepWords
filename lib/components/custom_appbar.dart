import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prep_words/consts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: onBackPressed != null
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: textGreyColor),
              onPressed: onBackPressed,
            )
          : null,
      title: Text(
        title,
        style: headingLarge,
      ),
      backgroundColor: primary,
      elevation: 3,
      shadowColor: Colors.deepOrange.withAlpha(120),
      centerTitle: true,
      iconTheme: IconThemeData(color: textGreyColor),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight * 1.2);
}
