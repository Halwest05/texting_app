// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  late final FocusNode _usernameFN;
  late final TextEditingController _usernameTEC;
  String? _usernameErrorText;

  late final FocusNode _passwordFN;
  late final TextEditingController _passwordTEC;
  String? _passwordErrorText;

  bool passIsVis = false;

  SharedPreferences? sharedPreferences;

  bool canPressEnter = true;

  bool userGot = false;
  FirestoreUser? gottenUser;

  @override
  void initState() {
    super.initState();

    _usernameFN = FocusNode();
    _usernameTEC = TextEditingController();

    _passwordFN = FocusNode();
    _passwordTEC = TextEditingController();

    getUser().then((value) {
      setState(() {
        gottenUser = value;
        userGot = true;
      });
    });
  }

  @override
  void dispose() {
    _usernameFN.dispose();
    _usernameTEC.dispose();

    _passwordFN.dispose();
    _passwordTEC.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: userGot
            ? gottenUser != null
                ? Builder(builder: (context) {
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) =>
                        Get.offAll(() => Home(user: gottenUser!)));
                    return Container();
                  })
                : SafeArea(
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
                                  child: Image.asset(
                                      "assets/images/us_flag.png",
                                      height: 32),
                                ),
                              ),
                              GestureDetector(
                                onTap: MainApp.changeToKurdish,
                                child: Card(
                                  elevation: 3,
                                  clipBehavior: Clip.antiAlias,
                                  child: Image.asset(
                                      "assets/images/kurdistan_flag.png",
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                child: Column(children: [
                                  const SizedBox(height: 12),
                                  Row(children: [
                                    const Expanded(
                                        child: Divider(
                                            color: Colors.black45,
                                            endIndent: 3)),
                                    Text(
                                      AppLocalizations.of(context)!
                                          .login_or_sign_up,
                                      style: const TextStyle(
                                          color: Colors.black45),
                                    ),
                                    const Expanded(
                                        child: Divider(
                                            color: Colors.black45, indent: 3))
                                  ]),
                                  const SizedBox(height: 20),
                                  TextField(
                                    focusNode: _usernameFN,
                                    controller: _usernameTEC,
                                    onSubmitted: (value) =>
                                        _passwordFN.requestFocus(),
                                    onChanged: _usernameErrorText == null
                                        ? null
                                        : (value) => setState(
                                            () => _usernameErrorText = null),
                                    decoration: InputDecoration(
                                        errorText: _usernameErrorText,
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(50)),
                                        labelText: AppLocalizations.of(context)!
                                            .username,
                                        prefixIcon: const Icon(Icons.person)),
                                  ),
                                  const SizedBox(height: 7),
                                  TextField(
                                    focusNode: _passwordFN,
                                    controller: _passwordTEC,
                                    onSubmitted: canPressEnter
                                        ? (value) async {
                                            setState(() {
                                              canPressEnter = false;
                                            });

                                            await login(
                                                username: _usernameTEC.text,
                                                password: _passwordTEC.text);

                                            setState(() {
                                              canPressEnter = true;
                                            });
                                          }
                                        : null,
                                    onChanged: _passwordErrorText == null
                                        ? null
                                        : (value) => setState(
                                            () => _passwordErrorText = null),
                                    keyboardType: TextInputType.visiblePassword,
                                    obscureText: !passIsVis,
                                    decoration: InputDecoration(
                                        errorText: _passwordErrorText,
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(50)),
                                        labelText: AppLocalizations.of(context)!
                                            .password,
                                        prefixIcon: const Icon(Icons.lock),
                                        suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                passIsVis = !passIsVis;
                                              });
                                            },
                                            icon: passIsVis
                                                ? const Icon(Icons.visibility)
                                                : const Icon(
                                                    Icons.visibility_off))),
                                  ),
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24),
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: GestureDetector(
                                        onTap: () {},
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .forgot_password,
                                          style: const TextStyle(
                                              color: Colors.purple),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        shape: const StadiumBorder(),
                                        backgroundColor: const Color.fromRGBO(
                                            206, 128, 203, 1)),
                                    onPressed: canPressEnter
                                        ? () async {
                                            setState(() {
                                              canPressEnter = false;
                                            });

                                            await login(
                                                username: _usernameTEC.text,
                                                password: _passwordTEC.text);

                                            setState(() {
                                              canPressEnter = true;
                                            });
                                          }
                                        : null,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 64),
                                      child: Text(AppLocalizations.of(context)!
                                          .enter_account),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(children: [
                                    const Expanded(
                                      child: Divider(
                                          color: Colors.black45, endIndent: 3),
                                    ),
                                    Text(
                                      AppLocalizations.of(context)!
                                          .dont_have_acc,
                                      style: const TextStyle(
                                          color: Colors.black45),
                                    ),
                                    const Expanded(
                                      child: Divider(
                                          color: Colors.black45, indent: 3),
                                    )
                                  ]),
                                  TextButton(
                                      onPressed: () => Get.to(
                                          () => const CreateAccountPage(),
                                          transition: Transition.downToUp),
                                      style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.purple),
                                      child: Text(AppLocalizations.of(context)!
                                          .create_account))
                                ]),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<FirestoreUser?> getUser() async {
    if (_auth.currentUser != null) {
      String email = _auth.currentUser!.email!;

      QuerySnapshot<Map<String, dynamic>> emailQuerySnapshot =
          await _firebaseFirestore
              .collection("users")
              .where("email", isEqualTo: email)
              .get();

      FirestoreUser user = FirestoreUser.mapToFirestoreUser(
          mappedUser: emailQuerySnapshot.docs.single.data(),
          mUsername: emailQuerySnapshot.docs.single.id);

      return user;
    }

    return null;
  }

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> login(
      {required String username, required String password}) async {
    if (username.isEmpty) {
      _usernameErrorText = AppLocalizations.of(context)!.usercantempty;
      _usernameFN.requestFocus();

      return;
    } else if (password.isEmpty) {
      _passwordErrorText = AppLocalizations.of(context)!.passcantempty;
      _passwordFN.requestFocus();

      return;
    }

    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _firebaseFirestore.collection("users").doc(username).get();

    if (!snapshot.exists) {
      _usernameErrorText = AppLocalizations.of(context)!.userdoesntexist;
      _usernameFN.requestFocus();

      return;
    }

    FirestoreUser user = FirestoreUser.mapToFirestoreUser(
        mappedUser: snapshot.data()!, mUsername: username);

    try {
      await _auth.signInWithEmailAndPassword(
          email: user.email, password: password);

      Get.offAll(() => Home(user: user));
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "user-disabled":
          _usernameErrorText = AppLocalizations.of(context)!.userdisabled;
          _usernameFN.requestFocus();

          return;
        case "wrong-password" || "invalid-credential":
          _passwordErrorText = AppLocalizations.of(context)!.wrongpass;
          _passwordFN.requestFocus();

          return;
      }
    }
  }
}

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  late final PageController _pageController;

  late final FocusNode _usernameFN;
  late final TextEditingController _usernameTEC;
  String? _usernameErrorText;

  late final FocusNode _emailAddressFN;
  late final TextEditingController _emailAddressTEC;
  String? _emailAddressErrorText;

  late final FocusNode _passwordFN;
  late final TextEditingController _passwordTEC;
  String? _passwordErrorText;

  late final FocusNode _firstNameFN;
  late final TextEditingController _firstNameTEC;
  String? _firstNameErrorText;

  late final FocusNode _lastNameFN;
  late final TextEditingController _lastNameTEC;
  String? _lastNameErrorText;

  late String mUsername;
  late String mEmail;
  late String mPassword;
  late String mFirstName;
  late String mLastName;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: 0);

    _usernameFN = FocusNode();
    _usernameTEC = TextEditingController();

    _emailAddressFN = FocusNode();
    _emailAddressTEC = TextEditingController();

    _passwordFN = FocusNode();
    _passwordTEC = TextEditingController();

    _firstNameFN = FocusNode();
    _firstNameTEC = TextEditingController();

    _lastNameFN = FocusNode();
    _lastNameTEC = TextEditingController();
  }

  @override
  void dispose() {
    _pageController.dispose();

    _usernameFN.dispose();
    _usernameTEC.dispose();

    _emailAddressFN.dispose();
    _emailAddressTEC.dispose();

    _passwordFN.dispose();
    _passwordTEC.dispose();

    _firstNameFN.dispose();
    _firstNameTEC.dispose();

    _lastNameFN.dispose();
    _lastNameTEC.dispose();

    super.dispose();
  }

  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
  bool canPressFirstPageContinue = true;

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
                    onSubmitted: (value) => _emailAddressFN.requestFocus(),
                    maxLength: 20,
                    onChanged: _usernameErrorText == null
                        ? null
                        : (value) => setState(() => _usernameErrorText = null),
                    focusNode: _usernameFN,
                    controller: _usernameTEC,
                    inputFormatters: [LowerCaseTextFormatter()],
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.username,
                      counterText: "",
                      errorText: _usernameErrorText,
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
                    onSubmitted: (value) => _passwordFN.requestFocus(),
                    onChanged: _emailAddressErrorText == null
                        ? null
                        : (value) =>
                            setState(() => _emailAddressErrorText = null),
                    focusNode: _emailAddressFN,
                    controller: _emailAddressTEC,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.email_address,
                      errorText: _emailAddressErrorText,
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
                    onSubmitted: canPressFirstPageContinue
                        ? (_) async {
                            setState(() {
                              canPressFirstPageContinue = false;
                            });

                            await gotoSecondPage(
                                username: _usernameTEC.text.trim(),
                                email: _emailAddressTEC.text.trim(),
                                password: _passwordTEC.text.trim());

                            setState(() {
                              canPressFirstPageContinue = true;
                            });
                          }
                        : null,
                    onChanged: _passwordErrorText == null
                        ? null
                        : (value) => setState(() => _passwordErrorText = null),
                    focusNode: _passwordFN,
                    controller: _passwordTEC,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: !passIsVis,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.password,
                      errorText: _passwordErrorText,
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
                  onPressed: canPressFirstPageContinue
                      ? () async {
                          setState(() {
                            canPressFirstPageContinue = false;
                          });

                          await gotoSecondPage(
                              username: _usernameTEC.text.trim(),
                              email: _emailAddressTEC.text.trim(),
                              password: _passwordTEC.text.trim());

                          setState(() {
                            canPressFirstPageContinue = true;
                          });
                        }
                      : null,
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

  Future<void> gotoSecondPage(
      {required String username,
      required String email,
      required String password}) async {
    if (username.isEmpty) {
      _usernameErrorText = AppLocalizations.of(context)!.usercantempty;
      _usernameFN.requestFocus();

      return;
    } else if (username.length < 3) {
      _usernameErrorText = AppLocalizations.of(context)!.usermore2letters;
      _usernameFN.requestFocus();

      return;
    } else if (email.isEmpty) {
      _emailAddressErrorText = AppLocalizations.of(context)!.emailcantempty;
      _emailAddressFN.requestFocus();

      return;
    } else if (!email.isEmail) {
      _emailAddressErrorText = AppLocalizations.of(context)!.emailinvalid;
      _emailAddressFN.requestFocus();

      return;
    } else if (password.isEmpty) {
      _passwordErrorText = AppLocalizations.of(context)!.passcantempty;
      _passwordFN.requestFocus();

      return;
    } else if (password.length < 8) {
      _passwordErrorText = AppLocalizations.of(context)!.passmore7letters;
      _passwordFN.requestFocus();

      return;
    }

    DocumentSnapshot usernameSnapshot =
        await firebaseFirestore.collection("users").doc(username).get();

    QuerySnapshot emailSnapshot = await firebaseFirestore
        .collection("users")
        .where("email", isEqualTo: email)
        .get();

    if (context.mounted) {
      if (usernameSnapshot.exists) {
        _usernameErrorText = AppLocalizations.of(context)!.userexists;
        _usernameFN.requestFocus();

        return;
      } else if (emailSnapshot.size > 0) {
        _emailAddressErrorText = AppLocalizations.of(context)!.emailexists;
        _emailAddressFN.requestFocus();

        return;
      }

      mUsername = username;
      mEmail = email;
      mPassword = password;

      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    }
  }

  String? gender;
  String? genderError;

  bool canPressSecondPageContinue = true;

  DateTime birthdate = DateTime(DateTime.now().year - 18);

  Widget secondPage() => Center(
        child: SizedBox(
          height: 485,
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
                    focusNode: _firstNameFN,
                    controller: _firstNameTEC,
                    onSubmitted: (value) => _lastNameFN.requestFocus(),
                    onChanged: _firstNameErrorText == null
                        ? null
                        : (value) => setState(() => _firstNameErrorText = null),
                    maxLength: 20,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      errorText: _firstNameErrorText,
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
                    focusNode: _lastNameFN,
                    controller: _lastNameTEC,
                    onChanged: _lastNameErrorText == null
                        ? null
                        : (value) => setState(() => _lastNameErrorText = null),
                    maxLength: 20,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      errorText: _lastNameErrorText,
                      labelText: AppLocalizations.of(context)!.lastname,
                      prefixIcon: const Icon(Icons.person_4_rounded),
                      counterText: "",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    genderError != null
                        ? Row(
                            children: [
                              Text(AppLocalizations.of(context)!.selecturgender,
                                  style: TextStyle(
                                      color: Colors.red.shade900,
                                      fontSize: 12)),
                              const SizedBox(width: 8),
                            ],
                          )
                        : const SizedBox(),
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
                        if (genderError != null) {
                          genderError = null;
                        }

                        if (value != null) {
                          setState(() {
                            gender = value;
                          });
                        }
                      },
                    )
                  ],
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
                  initialDate: birthdate,
                  onChange: (dateTime, selectedIndex) {
                    birthdate = dateTime;
                  },
                ),
                const Divider(color: Colors.black45),
                ElevatedButton(
                  onPressed: canPressSecondPageContinue
                      ? () async {
                          setState(() {
                            canPressSecondPageContinue = false;
                          });

                          await gotoThirdPage(
                              fn: _firstNameTEC.text,
                              ln: _lastNameTEC.text,
                              gn: gender,
                              bd: birthdate);

                          setState(() {
                            canPressSecondPageContinue = true;
                          });
                        }
                      : null,
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

  Future<void> gotoThirdPage(
      {required String fn,
      required String ln,
      String? gn,
      required DateTime bd}) async {
    if (fn.isEmpty) {
      _firstNameErrorText = AppLocalizations.of(context)!.fncantempty;
      _firstNameFN.requestFocus();

      return;
    } else if (fn.length < 3) {
      _firstNameErrorText = AppLocalizations.of(context)!.fnmore2letters;
      _firstNameFN.requestFocus();

      return;
    } else if (ln.isEmpty) {
      _lastNameErrorText = AppLocalizations.of(context)!.lncantempty;
      _lastNameFN.requestFocus();

      return;
    } else if (ln.length < 3) {
      _lastNameErrorText = AppLocalizations.of(context)!.lnmore2letters;
      _lastNameFN.requestFocus();

      return;
    } else if (gn == null) {
      genderError = AppLocalizations.of(context)!.selecturgender;

      return;
    }

    mFirstName = fn;
    mLastName = ln;

    _pageController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
  }

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
                  onPressed: () async {
                    setState(() {
                      canPressDone = false;
                    });

                    await onDone();

                    setState(() {
                      canPressDone = true;
                    });
                  },
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

  bool canPressDone = true;

  Future<void> onDone() async {
    late Uint8List imgData;

    if (selectedImgPath == null) {
      ByteData byteData =
          await rootBundle.load("assets/images/unknown_person.jpg");

      imgData = byteData.buffer.asUint8List();
    } else {
      imgData = File(selectedImgPath!).readAsBytesSync();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const SimpleDialog(
          backgroundColor: Color.fromRGBO(227, 180, 226, 1),
          children: [
            Center(child: CircularProgressIndicator()),
            SizedBox(height: 8),
            Center(child: Text("Creating account... Please wait"))
          ],
        );
      },
    );

    try {
      await firebaseAuth.createUserWithEmailAndPassword(
          email: mEmail, password: mPassword);

      TaskSnapshot taskSnapshot = await firebaseStorage
          .ref("users")
          .child(mUsername)
          .child("pfp")
          .putData(imgData);

      String imgPath = await taskSnapshot.ref.getDownloadURL();

      FirestoreUser user = FirestoreUser(
          username: mUsername,
          name: "$mFirstName $mLastName",
          email: mEmail,
          gender: gender!,
          imgPath: imgPath,
          birthdate: birthdate.millisecondsSinceEpoch);

      await firebaseFirestore
          .collection("users")
          .doc(mUsername)
          .set(user.mappedUser);

      Get.offAll(() => Home(user: user));
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "email-already-in-use":
          await _pageController.animateToPage(0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeIn);

          _emailAddressErrorText = AppLocalizations.of(context)!.emailexists;
          _emailAddressFN.requestFocus();

          return;

        case "invalid-email":
          await _pageController.animateToPage(0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeIn);

          _emailAddressErrorText = AppLocalizations.of(context)!.emailinvalid;
          _emailAddressFN.requestFocus();

          return;

        case "weak-password":
          await _pageController.animateToPage(0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeIn);

          _passwordErrorText = AppLocalizations.of(context)!.passweak;
          _passwordFN.requestFocus();

          return;

        default:
          return;
      }
    }
  }

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
