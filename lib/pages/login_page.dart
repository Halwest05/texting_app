import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:texting_app/main.dart';
import 'package:texting_app/pages/home_page/home.dart';
import 'package:texting_app/tools.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool passIsVis = false;

  SharedPreferences? sharedPreferences;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Row(
                textDirection: TextDirection.ltr,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: MainApp.changeToEnglish,
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      elevation: 3,
                      child:
                          Image.asset("assets/images/us_flag.png", height: 32),
                    ),
                  ),
                  GestureDetector(
                    onTap: MainApp.changeToKurdish,
                    child: Card(
                      elevation: 3,
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset("assets/images/kurdistan_flag.png",
                          height: 32),
                    ),
                  )
                ]),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(60)),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      "assets/images/stay_connected.jpg",
                      height: 250,
                    ),
                  ),
                ),
                Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  color: const Color.fromRGBO(227, 180, 226, 1),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(children: [
                      const SizedBox(height: 12),
                      Row(children: [
                        const Expanded(
                            child:
                                Divider(color: Colors.black45, endIndent: 3)),
                        Text(
                          AppLocalizations.of(context)!.login_or_sign_up,
                          style: const TextStyle(color: Colors.black45),
                        ),
                        const Expanded(
                            child: Divider(color: Colors.black45, indent: 3))
                      ]),
                      const SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50)),
                            labelText: AppLocalizations.of(context)!.username,
                            prefixIcon: const Icon(Icons.person)),
                      ),
                      const SizedBox(height: 7),
                      TextField(
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: !passIsVis,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50)),
                            labelText: AppLocalizations.of(context)!.password,
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    passIsVis = !passIsVis;
                                  });
                                },
                                icon: passIsVis
                                    ? const Icon(Icons.visibility)
                                    : const Icon(Icons.visibility_off))),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {},
                            child: Text(
                              AppLocalizations.of(context)!.forgot_password,
                              style: const TextStyle(color: Colors.purple),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder(),
                            backgroundColor:
                                const Color.fromRGBO(206, 128, 203, 1)),
                        onPressed: () => Get.off(() => const Home()),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 64),
                          child:
                              Text(AppLocalizations.of(context)!.enter_account),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(children: [
                        const Expanded(
                          child: Divider(color: Colors.black45, endIndent: 3),
                        ),
                        Text(
                          AppLocalizations.of(context)!.dont_have_acc,
                          style: const TextStyle(color: Colors.black45),
                        ),
                        const Expanded(
                          child: Divider(color: Colors.black45, indent: 3),
                        )
                      ]),
                      TextButton(
                          onPressed: () => Get.to(
                              () => const CreateAccountPage(),
                              transition: Transition.downToUp),
                          style: ElevatedButton.styleFrom(
                              foregroundColor:
                                  const Color.fromRGBO(206, 128, 203, 1)),
                          child: Text(
                              AppLocalizations.of(context)!.create_account))
                    ]),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  late final PageController _pageController;
  String? gender;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.create_account_title),
          centerTitle: true,
          leading: currentPage == 0
              ? null
              : BackButton(
                  onPressed: () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut))),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _pageController,
            onPageChanged: (value) {
              setState(() {
                currentPage = value;
              });
            },
            children: [firstPage(), secondPage(), thirdPage()],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  dotPageIndicator(index: 0),
                  dotPageIndicator(index: 1),
                  dotPageIndicator(index: 2)
                ]),
          )
        ],
      ),
    );
  }

  Widget dotPageIndicator({required index}) {
    if (index == currentPage) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.5),
        child: Container(
          height: 12,
          width: 12,
          decoration: const BoxDecoration(
              color: Color.fromRGBO(206, 128, 203, 1), shape: BoxShape.circle),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.5),
      child: Container(
        height: 10,
        width: 10,
        decoration:
            const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
      ),
    );
  }

  bool passIsVis = false;

  Widget firstPage() => Center(
        child: SizedBox(
          height: 350,
          child: Card(
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.zero,
            color: const Color.fromRGBO(227, 180, 226, 1),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Expanded(
                        child: Divider(color: Colors.black45, endIndent: 3)),
                    Text(
                      AppLocalizations.of(context)!.please_fill_the_following,
                      style: const TextStyle(color: Colors.black45),
                    ),
                    const Expanded(
                        child: Divider(color: Colors.black45, indent: 3))
                  ],
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: MyTools.isKurdish
                      ? const EdgeInsets.only(right: 6, left: 56 + 6)
                      : const EdgeInsets.only(right: 56 + 6, left: 6),
                  child: TextField(
                    maxLength: 20,
                    inputFormatters: [LowerCaseTextFormatter()],
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.username,
                      counterText: "",
                      prefixIcon: const Icon(Icons.person_2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                ),
                const Divider(color: Colors.black54, height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: TextField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.email_address,
                      prefixIcon: const Icon(Icons.email_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: TextField(
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: !passIsVis,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.password,
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              passIsVis = !passIsVis;
                            });
                          },
                          icon: passIsVis
                              ? const Icon(Icons.visibility)
                              : const Icon(Icons.visibility_off)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(color: Colors.black54),
                ElevatedButton(
                  onPressed: () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(206, 128, 203, 1),
                      shape: const StadiumBorder()),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 72),
                    child: Text(AppLocalizations.of(context)!.continue_),
                  ),
                )
              ],
            ),
          ),
        ),
      );

  Widget secondPage() => Center(
        child: SizedBox(
          height: 470,
          child: Card(
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.zero,
            color: const Color.fromRGBO(227, 180, 226, 1),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Expanded(
                        child: Divider(color: Colors.black45, endIndent: 3)),
                    Text(
                      AppLocalizations.of(context)!.please_fill_the_following,
                      style: const TextStyle(color: Colors.black45),
                    ),
                    const Expanded(
                        child: Divider(color: Colors.black45, indent: 3))
                  ],
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: MyTools.isKurdish
                      ? const EdgeInsets.only(right: 16, left: 6 + 72)
                      : const EdgeInsets.only(right: 72 + 6, left: 16),
                  child: TextField(
                    maxLength: 20,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.firstname,
                      prefixIcon: const Icon(Icons.person_rounded),
                      counterText: "",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: MyTools.isKurdish
                      ? const EdgeInsets.only(right: 16, left: 6 + 72)
                      : const EdgeInsets.only(right: 72 + 6, left: 16),
                  child: TextField(
                    maxLength: 20,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.lastname,
                      prefixIcon: const Icon(Icons.person_4_rounded),
                      counterText: "",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                ),
                DropdownButton(
                  value: gender,
                  items: [
                    DropdownMenuItem(
                        child: Text(AppLocalizations.of(context)!.gender)),
                    DropdownMenuItem(
                        value: "male",
                        child: Text(AppLocalizations.of(context)!.male)),
                    DropdownMenuItem(
                        value: "female",
                        child: Text(AppLocalizations.of(context)!.female))
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        gender = value;
                      });
                    }
                  },
                ),
                Row(children: [
                  const Expanded(
                      child: Divider(
                          endIndent: 3, color: Colors.black45, height: 4)),
                  Text(AppLocalizations.of(context)!.please_choose_ur_birthdate,
                      style: const TextStyle(color: Colors.black45)),
                  const Expanded(
                      child:
                          Divider(color: Colors.black45, height: 4, indent: 3))
                ]),
                DatePickerWidget(
                  pickerTheme: const DateTimePickerTheme(
                    backgroundColor: Colors.transparent,
                    dividerColor: Color.fromRGBO(206, 128, 203, 1),
                  ),
                  looping: true,
                  firstDate: DateTime(DateTime.now().year - 120),
                  lastDate: DateTime(DateTime.now().year - 18, 12, 31),
                ),
                const Divider(color: Colors.black45),
                ElevatedButton(
                  onPressed: () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(206, 128, 203, 1),
                      shape: const StadiumBorder()),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 72),
                    child: Text(AppLocalizations.of(context)!.continue_),
                  ),
                )
              ],
            ),
          ),
        ),
      );

  String? selectedImgPath;

  Widget thirdPage() => Center(
        child: SizedBox(
          height: 425,
          child: Card(
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.zero,
            color: const Color.fromRGBO(227, 180, 226, 1),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Expanded(
                        child: Divider(color: Colors.black45, endIndent: 3)),
                    Text(
                      AppLocalizations.of(context)!.choose_ur_propic,
                      style: const TextStyle(color: Colors.black45),
                    ),
                    const Expanded(
                        child: Divider(color: Colors.black45, indent: 3))
                  ],
                ),
                const SizedBox(height: 10),
                Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: selectedImgPath == null
                      ? Image.asset(
                          "assets/images/unknown_person.jpg",
                          height: 230,
                        )
                      : GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                      title: Text(AppLocalizations.of(context)!
                                          .are_u_sure),
                                      content: Text(
                                          AppLocalizations.of(context)!
                                              .do_u_wanna_clear_pic),
                                      actions: [
                                        TextButton(
                                            style: TextButton.styleFrom(
                                                foregroundColor:
                                                    const Color.fromRGBO(
                                                        206, 128, 203, 1)),
                                            onPressed: () {
                                              Get.back();
                                            },
                                            child: Text(
                                                AppLocalizations.of(context)!
                                                    .no)),
                                        TextButton(
                                            style: TextButton.styleFrom(
                                                foregroundColor: Colors.red),
                                            onPressed: () {
                                              setState(() {
                                                selectedImgPath = null;
                                              });

                                              Get.back();
                                            },
                                            child: Text(
                                                AppLocalizations.of(context)!
                                                    .yes))
                                      ]);
                                });
                          },
                          child: Image.file(File(selectedImgPath!),
                              height: 230, fit: BoxFit.contain),
                        ),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  ElevatedButton.icon(
                      onPressed: () => pickImage(source: ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: Text(AppLocalizations.of(context)!.camera),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple)),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                      onPressed: () => pickImage(source: ImageSource.gallery),
                      icon: const Icon(Icons.image_rounded),
                      label: Text(AppLocalizations.of(context)!.gallery),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple))
                ]),
                const Divider(color: Colors.black45),
                ElevatedButton(
                  onPressed: () => Get.off(() => const Home()),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(206, 128, 203, 1),
                      shape: const StadiumBorder()),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 72),
                    child: Text(AppLocalizations.of(context)!.create_account),
                  ),
                )
              ],
            ),
          ),
        ),
      );

  final ImagePicker picker = ImagePicker();
  final ImageCropper cropper = ImageCropper();

  void pickImage({required ImageSource source}) async {
    XFile? pickedImg = await picker.pickImage(
        source: source, imageQuality: 75, maxHeight: 1000, maxWidth: 1000);

    if (pickedImg != null) {
      CroppedFile? croppedImg = await cropper.cropImage(
          sourcePath: pickedImg.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          compressFormat: ImageCompressFormat.jpg,
          maxHeight: 1000,
          maxWidth: 1000,
          cropStyle: CropStyle.circle,
          uiSettings: [
            AndroidUiSettings(
                toolbarColor: const Color.fromRGBO(206, 128, 203, 1),
                toolbarWidgetColor: Colors.white,
                hideBottomControls: true,
                // ignore: use_build_context_synchronously
                toolbarTitle: AppLocalizations.of(context)!.edit_photo)
          ]);

      if (croppedImg != null) {
        setState(() {
          selectedImgPath = croppedImg.path;
        });
      }
    }
  }
}

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
          TextEditingValue oldValue, TextEditingValue newValue) =>
      TextEditingValue(
        selection: newValue.selection,
        text: newValue.text.toLowerCase(),
      );
}
