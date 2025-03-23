
import 'package:flutter/material.dart';
// fonts import
import 'package:google_fonts/google_fonts.dart';
// colour import

class FontSizes {
  static const small = 12.0;
  static const standard = 14.0;
  static const standardUp = 16.0;
  static const medium = 20.0;
  static const large = 28.0;
}

class DefaultColors {
  static const Color greyText = Color.fromARGB(255, 154, 160, 232);
  static const Color whiteText = Color(0xFFFFFFFF);
  static const Color senderMessage = Color(0xFF7A8194);
  static const Color receiverMessage = Color(0xFF51574C);
  static const Color sentMessageInput = Color(0xFF51574d);
  static const Color messageListPage = Color(0xFF51574C);
  static const Color buttonColor = Color(0xFF708759);
    static const Color dailyQuestionColor = Colors.blueGrey;

}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: Colors.white,
      scaffoldBackgroundColor:Color(0xFF31372d), 
      textTheme: TextTheme(
        titleMedium: GoogleFonts.poppins(
          fontSize: 18.0, 
          color: Colors.white,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 22.0, 
          color: Colors.white,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 14.0, 
          color: Colors.white,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 16.0,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: FontSizes.standardUp,
          color: Colors.white,
        ),
      ),
    );
  }
}
