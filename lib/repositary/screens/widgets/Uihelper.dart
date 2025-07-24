import 'package:flutter/material.dart';
import '../../../domain/constants/appcolors.dart';

class Uihelper {
  static Widget CustomImage({required String imgurl}) {
    return Image.asset("assets/images/$imgurl");
  }

  static Widget CustomSendButton({
    required BuildContext context,
    required VoidCallback onPressed,
    double height = 50,
    double width = 70,
    String text = "Send",
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: isDark ? AppColors.scaffolddark : AppColors.scaffoldlight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: MaterialButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  static Widget CustomText({
    required String text,
    required double fontsize,
    String? fontfamily,
    FontWeight? fontweight,
    Color? color,
    required BuildContext context,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontsize,
        fontFamily: fontfamily ?? "regular",
        fontWeight: fontweight ?? FontWeight.normal,
        color: color ??
            (Theme.of(context).brightness == Brightness.dark
                ? AppColors.textdarkmode
                : AppColors.textlightmode),
      ),
    );
  }

  static Widget CustomButton({
    required String buttonnname,
    required VoidCallback callback,
    Color? buttoncolor,
  }) {
    return SizedBox(
      height: 45,
      width: 350,
      child: ElevatedButton(
        onPressed: callback,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttoncolor ?? AppColors.buttonlightmode,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          buttonnname,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: "bold",
          ),
        ),
      ),
    );
  }

  static Widget CustomMessageTextField({
    required TextEditingController controller,
    required BuildContext context,
    String hintText = "Type a message...",
    IconData icon = Icons.message,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color:
            isDark ? AppColors.containerdarkmode : AppColors.containerlightmode,
        borderRadius: BorderRadius.circular(0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: isDark ? AppColors.textdarkmode : AppColors.textlightmode,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: isDark ? AppColors.hintdarkmode : AppColors.hintlightmode,
          ),
          border: InputBorder.none,
          icon: Icon(icon,
              color: isDark ? AppColors.iconlight : AppColors.icondarkmode),
        ),
      ),
    );
  }

  static Widget CustomTextField({
    required TextEditingController controller,
    required String text,
    required TextInputType textinputtype,
    required BuildContext context,
    required IconData icondata,
    required Function(String) onChanged,
    IconButton? suffixIcon,
  }) {
    return Container(
      height: 45,
      width: 330,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.containerdarkmode
            : AppColors.containerlightmode,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        keyboardType: textinputtype,
        onChanged: onChanged,
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.textdarkmode
              : AppColors.textlightmode,
        ),
        decoration: InputDecoration(
          hintText: text,
          prefixIcon: Icon(
            icondata,
            color: AppColors.iconlight,
          ),
          hintStyle: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.hintdarkmode
                : AppColors.hintlightmode,
            fontSize: 14,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  static void showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.redAccent,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
