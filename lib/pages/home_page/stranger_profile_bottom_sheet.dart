import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:texting_app/pages/home_page/profile_bottom_sheet.dart';
import 'package:texting_app/tools.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class StrangerProfileBottomSheet extends StatefulWidget {
  final UserProfile user;
  final String uid;

  final bool isQuickAdded;

  const StrangerProfileBottomSheet(
      {super.key,
      required this.user,
      required this.uid,
      required this.isQuickAdded});

  @override
  State<StrangerProfileBottomSheet> createState() =>
      _StrangerProfileBottomSheetState();
}

class _StrangerProfileBottomSheetState
    extends State<StrangerProfileBottomSheet> {
  bool isAdded = false;
  bool isAdding = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return ProfileBottomSheetNew(user: widget.user, uid: widget.uid, actions: [
      isAdded || widget.isQuickAdded
          ? ElevatedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.done_rounded),
              label: Text(AppLocalizations.of(context)!.request_sent,
                  style: const TextStyle(fontSize: 12)))
          : ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent),
              onPressed: isAdding
                  ? null
                  : () async {
                      setState(() {
                        isAdding = true;
                      });

                      await _firestore
                          .collection("users")
                          .doc(widget.user.userData.uid)
                          .collection("friendRequests")
                          .doc(widget.uid)
                          .set({
                        "timestamp": DateTime.now().millisecondsSinceEpoch
                      });

                      setState(() {
                        isAdded = true;
                      });
                    },
              icon: const Icon(Icons.person_add_rounded),
              label: Text(
                AppLocalizations.of(context)!.send_request,
                style: const TextStyle(fontSize: 12),
              )),
      const SizedBox(width: 8),
      OutlinedButton.icon(
          onPressed: () {
            Clipboard.setData(
                ClipboardData(text: widget.user.userData.username.value));

            Get.showSnackbar(GetSnackBar(
              message: AppLocalizations.of(context)!.copied_to_clipbrd,
              mainButton: TextButton(
                  onPressed: () => Get.closeAllSnackbars(),
                  child: Text(AppLocalizations.of(context)!.ok)),
              duration: const Duration(seconds: 3),
              animationDuration: const Duration(milliseconds: 400),
            ));
          },
          style: OutlinedButton.styleFrom(foregroundColor: Colors.deepPurple),
          icon: const Icon(Icons.copy),
          label: Text(AppLocalizations.of(context)!.copy_id))
    ]);
  }
}
