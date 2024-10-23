import 'package:flutter/material.dart';

class CommonDesignAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title; // Change from String to Widget
  final Color backgroundColor;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showLeading;
  final double appBarHeight; // Customizable height
  final double elevation; // Customizable elevation
  final TextStyle? titleTextStyle; // Optional text style if title is provided as Text widget

  const CommonDesignAppBar({
    Key? key,
    this.title,
    this.backgroundColor = Colors.orange,
    this.leading,
    this.actions,
    this.showLeading = false,
    this.appBarHeight = 80.0, // Default height
    this.elevation = 4.0, // Default elevation
    this.titleTextStyle, // Optional text style
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: WaveClipper(),
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        elevation: elevation,
        leading: showLeading
            ? leading ??
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            )
            : null,
        title: title,
        actions: actions,
        centerTitle: false,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight);
}

// Custom clipper for the wave design AppBar
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height);

    final firstCurve = Offset(0, size.height - 20);
    final firstLastCurve = Offset(30, size.height - 20);
    path.quadraticBezierTo(
        firstCurve.dx, firstCurve.dy, firstLastCurve.dx, firstLastCurve.dy);

    final secondCurve = Offset(0, size.height - 20);
    final secondLastCurve = Offset(size.width - 30, size.height - 20);
    path.quadraticBezierTo(
        secondCurve.dx, secondCurve.dy, secondLastCurve.dx, secondLastCurve.dy);

    final thirdCurve = Offset(size.width, size.height - 20);
    final thirdLastCurve = Offset(size.width, size.height);
    path.quadraticBezierTo(
        thirdCurve.dx, thirdCurve.dy, thirdLastCurve.dx, thirdLastCurve.dy);

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
