import 'package:get/get.dart';

class MyTools {
  static bool get isKurdish => Get.locale!.languageCode == "fa" ? true : false;

  static String testPropic1 = "assets/images/test/1.jpg";
  static String testPropic2 = "assets/images/test/2.jpg";
  static String testPropic3 = "assets/images/test/3.jpg";
  static String testPropic4 = "assets/images/test/4.jpg";
}

class MiniProfile {
  final String name;
  final String message;
  final String imgPath;

  const MiniProfile(
      {required this.name, required this.imgPath, required this.message});
}
