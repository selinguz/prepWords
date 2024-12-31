import 'package:flutter/material.dart';
import 'package:prep_words/consts.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  const CustomAppBar({super.key, required this.title});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight * 1.2);
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        widget.title,
        style: TextStyle(
            color: textWhiteColor, fontSize: 24, fontWeight: FontWeight.bold),
      ),
      backgroundColor: primary,
      iconTheme: IconThemeData(color: textWhiteColor, size: 30.0),
    );
  }
}
