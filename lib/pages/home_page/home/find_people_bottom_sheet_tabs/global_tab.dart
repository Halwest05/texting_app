import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:texting_app/pages/home_page/stranger_profile_bottom_sheet.dart';
import 'package:texting_app/tools.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class GlobalTabBottomSheet extends StatefulWidget {
  final FirestoreUser me;
  const GlobalTabBottomSheet({super.key, required this.me});

  @override
  State<GlobalTabBottomSheet> createState() => _GlobalTabBottomSheetState();
}

class _GlobalTabBottomSheetState extends State<GlobalTabBottomSheet> {
  late final TextEditingController _searchController;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  List<UserProfile> _peopleFound = [];

  List<String> friendUsernames = [];
  List<String> blocklistUsernames = [];

  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _friendsStream;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _blocklistStream;

  @override
  void initState() {
    _searchController = TextEditingController();

    _friendsStream = _firestore
        .collection("users")
        .doc(widget.me.uid)
        .collection("friends")
        .snapshots()
        .listen((event) {
      friendUsernames = [];

      for (QueryDocumentSnapshot<Map<String, dynamic>> friendDoc
          in event.docs) {
        _firestore
            .collection("users")
            .doc(friendDoc.id)
            .get()
            .then((value) => friendUsernames.add(value.get("username")));
      }
    });

    _blocklistStream = _firestore
        .collection("users")
        .doc(widget.me.uid)
        .collection("blocklist")
        .snapshots()
        .listen((event) {
      blocklistUsernames = [];

      for (QueryDocumentSnapshot<Map<String, dynamic>> blockedDoc
          in event.docs) {
        _firestore
            .collection("users")
            .doc(blockedDoc.id)
            .get()
            .then((value) => blocklistUsernames.add(value.get("username")));
      }
    });

    _searchController.addListener(() async {
      if (_searchController.text.length >= 3) {
        QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
            .collection("users")
            .where("username",
                isGreaterThanOrEqualTo: _searchController.text,
                isLessThanOrEqualTo: "${_searchController.text}~",
                whereNotIn: [widget.me.username.value] +
                    friendUsernames +
                    blocklistUsernames)
            .get();

        List<UserProfile> asyncPeopleFound = [];

        for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
          FirestoreUser user = FirestoreUser.mapToFirestoreUser(
              mappedUser: doc.data(), uid: doc.id);

          DataSnapshot likeSnapshot = await _database
              .ref("likes")
              .child(user.uid)
              .child(widget.me.uid)
              .get();

          asyncPeopleFound
              .add(UserProfile(userData: user, likeState: likeSnapshot.exists));
        }

        setState(() {
          _peopleFound = asyncPeopleFound;
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _friendsStream.cancel();
    _blocklistStream.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            clipBehavior: Clip.antiAlias,
            child: TextField(
                controller: _searchController,
                inputFormatters: [LowerCaseTextFormatter()],
                decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.search,
                    suffixIcon: IconButton(
                        onPressed: () => _searchController.clear(),
                        icon: const Icon(Icons.clear_rounded)),
                    prefixIcon: const Icon(Icons.search_rounded))),
          ),
        ),
        const Divider(color: Colors.black45),
        _searchController.text.length >= 3
            ? _peopleFound.isNotEmpty
                ? Flexible(
                    child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        separatorBuilder: (context, index) =>
                            const Divider(color: Colors.black45),
                        itemBuilder: (context, index) =>
                            GlobalTabBottomSheetTile(
                                onBlock: () => setState(() {
                                      _peopleFound.remove(_peopleFound[index]);
                                    }),
                                uid: widget.me.uid,
                                user: _peopleFound[index],
                                key: UniqueKey()),
                        itemCount: _peopleFound.length),
                  )
                : Expanded(
                    child: Center(
                        child: Text(AppLocalizations.of(context)!.nopplfound,
                            style: const TextStyle(color: Colors.black45))))
            : Expanded(
                child: Center(
                    child: Text(AppLocalizations.of(context)!.searchforppl,
                        style: const TextStyle(color: Colors.black45))))
      ],
    );
  }
}

class GlobalTabBottomSheetTile extends StatefulWidget {
  final UserProfile user;
  final String uid;
  final Function() onBlock;

  const GlobalTabBottomSheetTile(
      {super.key,
      required this.user,
      required this.uid,
      required this.onBlock});

  @override
  State<GlobalTabBottomSheetTile> createState() =>
      _GlobalTabBottomSheetTileState();
}

class _GlobalTabBottomSheetTileState extends State<GlobalTabBottomSheetTile> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        String? res = await Get.bottomSheet(
            StrangerProfileBottomSheet(
                isQuickAdded: added, uid: widget.uid, user: widget.user),
            isScrollControlled: true);

        if (res == "block") {
          DateTime now = DateTime.now();

          Future<void> blockUserToMeFuture = _firestore
              .collection("users")
              .doc(widget.uid)
              .collection("blocklist")
              .doc(widget.user.userData.uid)
              .set({"timestamp": now.millisecondsSinceEpoch, "by": widget.uid});

          Future<void> blockMeToUserFuture = _firestore
              .collection("users")
              .doc(widget.user.userData.uid)
              .collection("blocklist")
              .doc(widget.uid)
              .set({"timestamp": now.millisecondsSinceEpoch, "by": widget.uid});

          await Future.wait([blockUserToMeFuture, blockMeToUserFuture]);

          widget.onBlock();
        }
      },
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            const SizedBox(width: 5),
            Card(
                shape: const CircleBorder(),
                clipBehavior: Clip.hardEdge,
                child: MyNetworkImage(
                    src: widget.user.userData.imgPath.value, height: 70)),
            Expanded(
                child: Text(widget.user.userData.name.value,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16))),
            IconButton(
              color: Colors.purple,
              iconSize: 28,
              onPressed: addPressed
                  ? null
                  : () async {
                      setState(() {
                        addPressed = true;
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
                        added = true;
                      });
                    },
              icon: added
                  ? const Icon(Icons.done_rounded)
                  : const Icon(Icons.person_add_alt_1),
            ),
            const SizedBox(width: 4)
          ],
        ),
      ),
    );
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool addPressed = false;
  bool added = false;
}
