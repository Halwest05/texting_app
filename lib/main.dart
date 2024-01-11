import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:texting_app/l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:texting_app/pages/login_page.dart';
import 'package:texting_app/tools.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(MainApp(sharedPrefs: prefs));
}

class MainApp extends StatelessWidget {
  final SharedPreferences sharedPrefs;
  const MainApp({super.key, required this.sharedPrefs});

  @override
  Widget build(BuildContext context) {
    late Locale locale;

    if (sharedPrefs.containsKey("lang")) {
      locale = Locale(sharedPrefs.getString("lang")!.toString());
    } else {
      sharedPrefs.setString("lang", "en");
      locale = const Locale("en");
    }

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
      locale: locale,
      theme: englishTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );
  }

  static ThemeData kurdishTheme() {
    return ThemeData(
        useMaterial3: false,
        colorScheme: const ColorScheme.light(
            primary: Colors.purple,
            secondary: Color.fromRGBO(206, 128, 203, 1)),
        fontFamily: "GretaTextArabic");
  }

  static ThemeData englishTheme() {
    return ThemeData(
        useMaterial3: false,
        colorScheme: const ColorScheme.light(
            primary: Colors.purple,
            secondary: Color.fromRGBO(206, 128, 203, 1)),
        fontFamily: "Roboto");
  }

  static Future<void> changeToEnglish() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    sharedPreferences.setString("lang", "en");
    Get.updateLocale(const Locale("en"));
  }

  static Future<void> changeToKurdish() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    sharedPreferences.setString("lang", "fa");
    Get.updateLocale(const Locale("fa"));
  }
}
