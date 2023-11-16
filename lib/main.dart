import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:texting_app/l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:texting_app/pages/login_page.dart';
import 'package:texting_app/tools.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return Theme(
            data: MyTools.isKurdish ? kurdishTheme() : englishTheme(),
            child: child!,
          );
        },
        home: const LoginPage(),
        supportedLocales: L10n.all,
        locale: const Locale("en"),
        theme: englishTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates);
  }

  static ThemeData kurdishTheme() {
    return ThemeData(
        colorScheme: const ColorScheme.light(
            primary: Colors.purple,
            secondary: Color.fromRGBO(206, 128, 203, 1)),
        fontFamily: "GretaTextArabic");
  }

  static ThemeData englishTheme() {
    return ThemeData(
        colorScheme: const ColorScheme.light(
            primary: Colors.purple,
            secondary: Color.fromRGBO(206, 128, 203, 1)),
        fontFamily: "Roboto");
  }
}
