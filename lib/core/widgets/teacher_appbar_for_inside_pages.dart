import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class TeacherAppbarForInsidePages extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final bool backHome;
  final bool hideBackButton;

  const TeacherAppbarForInsidePages(
      {super.key,
      required this.title,
      this.onBackPressed,
      this.actions,
      this.hideBackButton = false,
      this.backHome = false});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      forceMaterialTransparency: true,
      leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              size: 20, color: Color(0xFF353535)),
          onPressed: () {
            backHome ? context.go("/patient-home") : context.pop();
          }),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: GoogleFonts.urbanist().fontFamily,
          color: Color(0xFF353535),
        ),
      ),
      centerTitle: false,
      backgroundColor: Colors.white,
      shadowColor: Colors.grey,
      foregroundColor: const Color(0xFF2D2D2D),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      elevation: 1,
      iconTheme: const IconThemeData(color: Colors.black),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          height: 1.0,
          color: const Color(0xFFE2E8F0),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
