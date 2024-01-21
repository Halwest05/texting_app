// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:texting_app/main.dart';
import 'package:texting_app/pages/login_page.dart';
import 'package:texting_app/tools.dart';

class SettingsPage extends StatelessWidget {
  final FirestoreUser user;
  const SettingsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ListTile(
        title: Text(AppLocalizations.of(context)!.change_username),
        leading: const Icon(Icons.person_rounded),
        subtitle: Text(AppLocalizations.of(context)!.changes_the_username),
        onTap: () {
          Get.dialog(ChangeUsernameDialog(user: user));
        },
      ),
      const Divider(color: Colors.black45),
      ListTile(
        title: Text(AppLocalizations.of(context)!.change_password),
        leading: const Icon(Icons.lock_rounded),
        subtitle: Text(AppLocalizations.of(context)!.changes_the_password),
        onTap: () {
          Get.dialog(ChangePasswordDialog(user: user));
        },
      ),
      const Divider(color: Colors.black45),
      ListTile(
        title: Text(AppLocalizations.of(context)!.change_pfp),
        leading: const Icon(Icons.image),
        subtitle: Text(AppLocalizations.of(context)!.changes_the_pfp),
        onTap: () async {
          final ImagePicker picker = ImagePicker();
          final ImageCropper cropper = ImageCropper();

          String? res = await Get.dialog(
            SimpleDialog(
              title: Text(AppLocalizations.of(context)!.change_pfp),
              contentPadding: const EdgeInsets.all(8),
              children: [
                TextButton.icon(
                    onPressed: () {
                      Get.back(result: "gallery");
                    },
                    icon: const Icon(Icons.image_rounded),
                    label: Text(AppLocalizations.of(context)!.gallery)),
                TextButton.icon(
                    onPressed: () {
                      Get.back(result: "camera");
                    },
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: Text(AppLocalizations.of(context)!.camera))
              ],
            ),
          );

          late ImageSource imageSource;

          if (res == "gallery") {
            imageSource = ImageSource.gallery;
          } else if (res == "camera") {
            imageSource = ImageSource.camera;
          }

          XFile? pickedImage = await picker.pickImage(
              source: imageSource,
              imageQuality: 75,
              maxHeight: 1000,
              maxWidth: 1000);

          if (pickedImage != null) {
            CroppedFile? croppedFile = await cropper.cropImage(
                sourcePath: pickedImage.path,
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

            if (croppedFile != null) {
              final FirebaseFirestore firestore = FirebaseFirestore.instance;
              final FirebaseStorage storage = FirebaseStorage.instance;

              Get.dialog(
                  SimpleDialog(
                    backgroundColor: const Color.fromRGBO(227, 180, 226, 1),
                    children: [
                      const Center(child: CircularProgressIndicator()),
                      const SizedBox(height: 8),
                      Center(
                          child: Text(
                              AppLocalizations.of(context)!.uploadingimage))
                    ],
                  ),
                  barrierDismissible: false);

              Uint8List imgData = await croppedFile.readAsBytes();
              TaskSnapshot imgSnapshot = await storage
                  .ref("users")
                  .child(user.uid)
                  .child("pfp")
                  .putData(imgData);

              String imgPath = await imgSnapshot.ref.getDownloadURL();

              await firestore
                  .collection("users")
                  .doc(user.uid)
                  .update({"imgPath": imgPath});

              Get.back();
            }
          }
        },
      ),
      const Divider(color: Colors.black45),
      ListTile(
        title: Text(AppLocalizations.of(context)!.change_lang),
        leading: const Icon(Icons.public_rounded),
        subtitle: Text(AppLocalizations.of(context)!.changes_the_lang),
        onTap: () {
          Get.to(() => const ChangeLanguagePage());
        },
      ),
      const Divider(color: Colors.black45),
      ListTile(
        title: Text(AppLocalizations.of(context)!.delete_acc),
        leading: const Icon(Icons.person_remove_alt_1_rounded),
        subtitle: Text(AppLocalizations.of(context)!.deletes_the_acc),
        onTap: () async {
          String? res = await Get.dialog(
            AlertDialog(
              title: Text(AppLocalizations.of(context)!.are_u_sure),
              content:
                  Text(AppLocalizations.of(context)!.do_u_wanna_delete_acc),
              actions: [
                TextButton(
                    onPressed: () => Get.back(),
                    child: Text(AppLocalizations.of(context)!.no)),
                TextButton(
                  onPressed: () => Get.back(result: "yes"),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: Text(AppLocalizations.of(context)!.yes),
                )
              ],
            ),
          );

          final FirebaseDatabase database = FirebaseDatabase.instance;
          final FirebaseFirestore firestore = FirebaseFirestore.instance;
          final FirebaseStorage storage = FirebaseStorage.instance;
          final FirebaseAuth auth = FirebaseAuth.instance;

          if (res == "yes") {
            String? passConfirmRes = await Get.dialog(
                DeleteAccountTypeYourPasswordDialog(user: user));

            if (passConfirmRes == "confirmed") {
              Get.dialog(
                  SimpleDialog(
                    backgroundColor: const Color.fromRGBO(227, 180, 226, 1),
                    children: [
                      const Center(child: CircularProgressIndicator()),
                      const SizedBox(height: 8),
                      Center(
                          child:
                              Text(AppLocalizations.of(context)!.deletingacc))
                    ],
                  ),
                  barrierDismissible: false);

              await auth.currentUser!.delete();

              Future<void> removeUserDataFuture =
                  firestore.collection("users").doc(user.uid).delete();

              QuerySnapshot friendsSnapshot = await firestore
                  .collection("users")
                  .doc(user.uid)
                  .collection("friends")
                  .get();

              QuerySnapshot friendRequestsSnapshot = await firestore
                  .collection("users")
                  .doc(user.uid)
                  .collection("friendRequests")
                  .get();

              QuerySnapshot blocklistsSnapshot = await firestore
                  .collection("users")
                  .doc(user.uid)
                  .collection("blocklist")
                  .get();

              List<Future<void>> userSubcollectionFutures = [];

              for (var doc in friendsSnapshot.docs) {
                userSubcollectionFutures.add(doc.reference.delete());
              }

              for (var doc in friendRequestsSnapshot.docs) {
                userSubcollectionFutures.add(doc.reference.delete());
              }

              for (var doc in blocklistsSnapshot.docs) {
                userSubcollectionFutures.add(doc.reference.delete());
              }

              Future<void> removeStoragePFPFuture =
                  storage.ref("users").child(user.uid).child("pfp").delete();

              Future<void> removeOnlineFuture =
                  database.ref("online").child(user.uid).remove();
              Future<void> removeLikesFuture =
                  database.ref("likes").child(user.uid).remove();

              await Future.wait([
                    removeOnlineFuture,
                    removeLikesFuture,
                    removeStoragePFPFuture,
                    removeUserDataFuture
                  ] +
                  userSubcollectionFutures);

              Get.offAll(() => const LoginPage());
            }
          }
        },
      ),
    ]);
  }
}

class DeleteAccountTypeYourPasswordDialog extends StatefulWidget {
  final FirestoreUser user;
  const DeleteAccountTypeYourPasswordDialog({super.key, required this.user});

  @override
  State<DeleteAccountTypeYourPasswordDialog> createState() =>
      _DeleteAccountTypeYourPasswordDialogState();
}

class _DeleteAccountTypeYourPasswordDialogState
    extends State<DeleteAccountTypeYourPasswordDialog> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String? _errorText;

  @override
  void initState() {
    _controller = TextEditingController();
    _focusNode = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(AppLocalizations.of(context)!.typeurpasswd),
      contentPadding: const EdgeInsets.all(8),
      children: [
        const Divider(color: Colors.black54),
        Center(
          child: Text(AppLocalizations.of(context)!.plztypeurpass,
              style: const TextStyle(color: Colors.black54)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          obscureText: true,
          keyboardType: TextInputType.visiblePassword,
          onChanged: (value) {
            if (_errorText != null) {
              setState(() {
                _errorText = null;
              });
            }
          },
          decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.password,
              errorText: _errorText,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(50))),
        ),
        const Divider(color: Colors.black54),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton(
              onPressed: canPressConfirm
                  ? () async {
                      setState(() {
                        canPressConfirm = false;
                      });

                      await pressConfirm(_controller.text);

                      setState(() {
                        canPressConfirm = true;
                      });
                    }
                  : null,
              style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
              child: Text(AppLocalizations.of(context)!.confirm)),
        )
      ],
    );
  }

  Future<void> pressConfirm(String pass) async {
    if (pass.isEmpty) {
      _errorText = AppLocalizations.of(context)!.passcantempty;
      _focusNode.requestFocus();

      return;
    } else if (pass.length < 8) {
      _errorText = AppLocalizations.of(context)!.passmore7letters;
      _focusNode.requestFocus();

      return;
    }

    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: widget.user.email, password: pass);

      Get.back(result: "confirmed");
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "wrong-password" || "invalid-credential":
          _errorText = AppLocalizations.of(context)!.wrongpass;
          _focusNode.requestFocus();

          return;
        case "too-many-requests":
          _errorText = AppLocalizations.of(context)!.toomanylogs;
          _focusNode.requestFocus();

          return;

        default:
          return;
      }
    }
  }

  bool canPressConfirm = true;
}

class ChangeUsernameDialog extends StatefulWidget {
  final FirestoreUser user;
  const ChangeUsernameDialog({super.key, required this.user});

  @override
  State<ChangeUsernameDialog> createState() => _ChangeUsernameDialogState();
}

class _ChangeUsernameDialogState extends State<ChangeUsernameDialog> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String? errorText;

  @override
  void initState() {
    _controller = TextEditingController();
    _focusNode = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: const EdgeInsets.all(8),
      title: Text(AppLocalizations.of(context)!.change_username),
      children: [
        const Divider(color: Colors.black54),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            maxLength: 20,
            inputFormatters: [LowerCaseTextFormatter()],
            controller: _controller,
            focusNode: _focusNode,
            onChanged: (value) {
              if (errorText != null) {
                setState(() {
                  errorText = null;
                });
              }
            },
            decoration: InputDecoration(
                errorText: errorText,
                labelText: AppLocalizations.of(context)!.newusrname,
                counterText: "",
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50))),
          ),
        ),
        const SizedBox(height: 8),
        const Divider(color: Colors.black45),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton(
              onPressed: canPressConfirm
                  ? () async {
                      _focusNode.unfocus();

                      setState(() {
                        canPressConfirm = false;
                      });

                      await changeUsername(_controller.text);

                      setState(() {
                        canPressConfirm = true;
                      });
                    }
                  : null,
              style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
              child: Text(AppLocalizations.of(context)!.confirm)),
        )
      ],
    );
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool canPressConfirm = true;

  Future<void> changeUsername(String newUsername) async {
    if (newUsername.isEmpty) {
      errorText = AppLocalizations.of(context)!.usercantempty;
      _focusNode.requestFocus();

      return;
    } else if (newUsername.length < 3) {
      errorText = AppLocalizations.of(context)!.usermore2letters;
      _focusNode.requestFocus();

      return;
    } else if (newUsername == widget.user.username.value) {
      errorText = AppLocalizations.of(context)!.usercantold;
      _focusNode.requestFocus();

      return;
    }

    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
        .collection("users")
        .where("username", isEqualTo: newUsername)
        .get();

    if (querySnapshot.size > 0) {
      errorText = AppLocalizations.of(context)!.userexists;
      _focusNode.requestFocus();

      return;
    }

    await _firestore
        .collection("users")
        .doc(widget.user.uid)
        .update({"username": newUsername});

    widget.user.setUsername(newUsername);

    Get.back();
  }
}

class ChangePasswordDialog extends StatefulWidget {
  final FirestoreUser user;
  const ChangePasswordDialog({super.key, required this.user});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  late final TextEditingController _oldPassController;
  late final FocusNode _oldPassFocusNode;
  String? _oldPassErrorText;

  late final TextEditingController _newPassController;
  late final FocusNode _newPassFocusNode;
  String? _newPassErrorText;

  @override
  void initState() {
    _oldPassController = TextEditingController();
    _oldPassFocusNode = FocusNode();

    _newPassController = TextEditingController();
    _newPassFocusNode = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    _oldPassController.dispose();
    _oldPassFocusNode.dispose();

    _newPassController.dispose();
    _newPassFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(AppLocalizations.of(context)!.change_password),
      contentPadding: const EdgeInsets.all(8),
      children: [
        const Divider(color: Colors.black54),
        const SizedBox(height: 6),
        TextField(
          controller: _oldPassController,
          obscureText: true,
          keyboardType: TextInputType.visiblePassword,
          focusNode: _oldPassFocusNode,
          onChanged: (value) {
            if (_oldPassErrorText != null) {
              setState(() {
                _oldPassErrorText = null;
              });
            }
          },
          onSubmitted: (value) => _newPassFocusNode.requestFocus(),
          decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.oldpasswd,
              errorText: _oldPassErrorText,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(50))),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _newPassController,
          focusNode: _newPassFocusNode,
          obscureText: true,
          keyboardType: TextInputType.visiblePassword,
          onChanged: (value) {
            if (_newPassErrorText != null) {
              setState(() {
                _newPassErrorText = null;
              });
            }
          },
          decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.newpasswd,
              errorText: _newPassErrorText,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(50))),
        ),
        const Divider(color: Colors.black54),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton(
              onPressed: canPressConfirm
                  ? () async {
                      setState(() {
                        canPressConfirm = false;
                      });

                      await changePassword(
                          oldPass: _oldPassController.text,
                          newPass: _newPassController.text);

                      setState(() {
                        canPressConfirm = true;
                      });
                    }
                  : null,
              style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
              child: Text(AppLocalizations.of(context)!.confirm)),
        )
      ],
    );
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> changePassword(
      {required String oldPass, required String newPass}) async {
    if (oldPass.isEmpty) {
      _oldPassErrorText = AppLocalizations.of(context)!.passcantempty;
      _oldPassFocusNode.requestFocus();

      return;
    } else if (oldPass.length < 8) {
      _oldPassErrorText = AppLocalizations.of(context)!.passmore7letters;
      _oldPassFocusNode.requestFocus();

      return;
    } else if (newPass.isEmpty) {
      _newPassErrorText = AppLocalizations.of(context)!.passcantempty;
      _newPassFocusNode.requestFocus();

      return;
    } else if (newPass.length < 8) {
      _newPassErrorText = AppLocalizations.of(context)!.passmore7letters;
      _newPassFocusNode.requestFocus();

      return;
    } else if (newPass == oldPass) {
      _newPassErrorText = AppLocalizations.of(context)!.newpasscantold;
      _newPassFocusNode.requestFocus();

      return;
    }

    try {
      UserCredential creds = await _auth.signInWithEmailAndPassword(
          email: widget.user.email, password: oldPass);

      try {
        await creds.user!.updatePassword(newPass);

        Get.back();
      } on FirebaseAuthException catch (updatePasswordException) {
        if (updatePasswordException.code == "weak-password") {
          _newPassErrorText = AppLocalizations.of(context)!.passweak;
          _newPassFocusNode.requestFocus();
          _newPassController.clear();

          return;
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "wrong-password" || e.code == "invalid-credential") {
        _oldPassErrorText = AppLocalizations.of(context)!.wrongpass;
        _oldPassFocusNode.requestFocus();
        _oldPassController.clear();

        return;
      }

      _oldPassErrorText = AppLocalizations.of(context)!.toomanylogs;
      _oldPassFocusNode.requestFocus();
      _oldPassController.clear();

      return;
    }
  }

  bool canPressConfirm = true;
}

class ChangeLanguagePage extends StatelessWidget {
  const ChangeLanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    int currentValue = MyTools.isKurdish ? 1 : 0;

    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Text(AppLocalizations.of(context)!.change_lang)),
        body: Column(children: [
          ListTile(
              title: const Text(
                "English",
                style: TextStyle(fontFamily: "Roboto"),
              ),
              leading: Card(
                clipBehavior: Clip.antiAlias,
                elevation: 3,
                child: Image.asset(
                  "assets/images/us_flag.png",
                  height: 32,
                ),
              ),
              trailing: Radio(
                value: currentValue,
                groupValue: 0,
                onChanged: (value) {},
              ),
              onTap: () => MainApp.changeToEnglish()),
          const Divider(color: Colors.black45),
          ListTile(
              title: const Text(
                "کوردی",
                style: TextStyle(fontFamily: "GretaTextArabic"),
              ),
              leading: Card(
                clipBehavior: Clip.antiAlias,
                elevation: 3,
                child: Image.asset(
                  "assets/images/kurdistan_flag.png",
                  height: 32,
                ),
              ),
              trailing: Radio(
                value: currentValue,
                groupValue: 1,
                onChanged: (value) {},
              ),
              onTap: () => MainApp.changeToKurdish()),
          const Divider(color: Colors.black45)
        ]));
  }
}
