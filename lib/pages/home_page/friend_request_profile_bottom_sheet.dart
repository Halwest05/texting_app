import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:texting_app/pages/home_page/profile_bottom_sheet.dart';
import 'package:texting_app/tools.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class FriendRequestProfileBottomSheet extends StatefulWidget {
  final UserProfile user;
  final String uid;

  const FriendRequestProfileBottomSheet(
      {super.key, required this.user, required this.uid});

  @override
  State<FriendRequestProfileBottomSheet> createState() =>
      _FriendRequestProfileBottomSheetState();
}

class _FriendRequestProfileBottomSheetState
    extends State<FriendRequestProfileBottomSheet> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isActing = false;

  bool isAccepted = false;
  bool isRejected = false;

  @override
  Widget build(BuildContext context) {
    return ProfileBottomSheetNew(user: widget.user, uid: widget.uid, actions: [
      ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: isActing
              ? null
              : () async {
                  setState(() {
                    isActing = true;
                  });

                  DateTime now = DateTime.now();

                  Future<void> setUserForMeFuture = _firestore
                      .collection("users")
                      .doc(widget.uid)
                      .collection("friends")
                      .doc(widget.user.userData.uid)
                      .set({"timestamp": now.millisecondsSinceEpoch});

                  Future<void> setMeForUserFuture = _firestore
                      .collection("users")
                      .doc(widget.user.userData.uid)
                      .collection("friends")
                      .doc(widget.uid)
                      .set({"timestamp": now.millisecondsSinceEpoch});

                  Future<void> deleteMyRequest = _firestore
                      .collection("users")
                      .doc(widget.uid)
                      .collection("friendRequests")
                      .doc(widget.user.userData.uid)
                      .delete();

                  Future<void> deleteFriendRequest = _firestore
                      .collection("users")
                      .doc(widget.user.userData.uid)
                      .collection("friendRequests")
                      .doc(widget.uid)
                      .delete();

                  await Future.wait([
                    setUserForMeFuture,
                    setMeForUserFuture,
                    deleteMyRequest,
                    deleteFriendRequest
                  ]);

                  setState(() {
                    isAccepted = true;
                  });
                },
          icon: isAccepted
              ? const Icon(Icons.done_rounded)
              : const Icon(Icons.person_add_alt_rounded),
          label: Text(isAccepted
              ? AppLocalizations.of(context)!.accepted
              : AppLocalizations.of(context)!.accept)),
      const SizedBox(width: 8),
      OutlinedButton.icon(
          onPressed: isActing
              ? null
              : () async {
                  setState(() {
                    isActing = true;
                  });

                  await _firestore
                      .collection("users")
                      .doc(widget.uid)
                      .collection("friendRequests")
                      .doc(widget.user.userData.uid)
                      .delete();

                  setState(() {
                    isRejected = true;
                  });
                },
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          icon: isRejected
              ? const Icon(Icons.done_rounded)
              : const Icon(Icons.person_remove_rounded),
          label: isRejected
              ? Text(AppLocalizations.of(context)!.rejected)
              : Text(AppLocalizations.of(context)!.reject))
    ]);
  }
}
