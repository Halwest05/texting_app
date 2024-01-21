import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:texting_app/pages/chat_page.dart';
import 'package:texting_app/pages/home_page/friend_profile_bottom_sheet.dart';
import 'package:texting_app/tools.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class FriendsTabBottomSheet extends StatefulWidget {
  final FirestoreUser me;
  const FriendsTabBottomSheet({super.key, required this.me});

  @override
  State<FriendsTabBottomSheet> createState() => _FriendsTabBottomSheetState();
}

class _FriendsTabBottomSheetState extends State<FriendsTabBottomSheet> {
  late final TextEditingController _searchController;

  List<UserProfile> friends = [];
  List<UserProfile> filteredFriends = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  @override
  void initState() {
    _searchController = TextEditingController();

    refreshFriends();

    _searchController.addListener(() {
      if (_searchController.text.length >= 3) {
        setState(() {
          filteredFriends = friends
              .where((element) =>
                  element.userData.username.contains(_searchController.text))
              .toList();
        });
      }
    });

    super.initState();
  }

  void refreshFriends() {
    _firestore
        .collection("users")
        .doc(widget.me.uid)
        .collection("friends")
        .get()
        .then((query) async {
      friends = [];

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in query.docs) {
        _firestore.collection("users").doc(doc.id).get().then((snapshot) =>
            _database
                .ref("likes")
                .child(snapshot.id)
                .child(widget.me.uid)
                .get()
                .then((likeSnapshot) => friends.add(UserProfile(
                    userData: FirestoreUser.mapToFirestoreUser(
                        mappedUser: snapshot.data()!, uid: snapshot.id),
                    likeState: likeSnapshot.exists))));
      }
    });

    filteredFriends = [];
    _searchController.clear();
  }

  @override
  void dispose() {
    _searchController.dispose();

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
            ? filteredFriends.isEmpty
                ? Expanded(
                    child: Center(
                        child: Text(
                            AppLocalizations.of(context)!.nofriendsfound,
                            style: const TextStyle(color: Colors.black45))))
                : Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: ListView.separated(
                          separatorBuilder: (context, index) =>
                              const Divider(color: Colors.black45),
                          itemBuilder: (context, index) =>
                              FriendTabBottomSheetTile(
                                  onUnfriendOrBlock: () =>
                                      setState(() => refreshFriends()),
                                  user: filteredFriends[index],
                                  uid: widget.me.uid,
                                  key: UniqueKey()),
                          itemCount: filteredFriends.length),
                    ),
                  )
            : Expanded(
                child: Center(
                child: Text(AppLocalizations.of(context)!.searchforfriends,
                    style: const TextStyle(color: Colors.black45)),
              ))
      ],
    );
  }
}

class FriendTabBottomSheetTile extends StatefulWidget {
  const FriendTabBottomSheetTile(
      {super.key,
      required this.user,
      required this.uid,
      required this.onUnfriendOrBlock});

  final UserProfile user;
  final String uid;
  final Function() onUnfriendOrBlock;

  @override
  State<FriendTabBottomSheetTile> createState() =>
      _FriendTabBottomSheetTileState();
}

class _FriendTabBottomSheetTileState extends State<FriendTabBottomSheetTile> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        String? res = await Get.bottomSheet(
            FriendProfileBottomSheet(
              user: widget.user,
              uid: widget.uid,
            ),
            isScrollControlled: true);

        if (res == "message") {
          Get.to(() => ChatPage(profile: widget.user, uid: widget.uid),
              transition: Transition.fade);
        } else if (res == "unfriend") {
          Future<void> deleteFriendToMeFuture = _firestore
              .collection("users")
              .doc(widget.uid)
              .collection("friends")
              .doc(widget.user.userData.uid)
              .delete();

          Future<void> deleteMeToFriendFuture = _firestore
              .collection("users")
              .doc(widget.user.userData.uid)
              .collection("friends")
              .doc(widget.uid)
              .delete();

          await Future.wait([deleteFriendToMeFuture, deleteMeToFriendFuture]);

          widget.onUnfriendOrBlock();
        } else if (res == "block") {
          DateTime now = DateTime.now();

          Future<void> blockFriendToMeFuture = _firestore
              .collection("users")
              .doc(widget.uid)
              .collection("blocklist")
              .doc(widget.user.userData.uid)
              .set({"timestamp": now.millisecondsSinceEpoch, "by": widget.uid});

          Future<void> blockMeToFriendFuture = _firestore
              .collection("users")
              .doc(widget.user.userData.uid)
              .collection("blocklist")
              .doc(widget.uid)
              .set({"timestamp": now.millisecondsSinceEpoch, "by": widget.uid});

          Future<void> deleteFriendToMeFuture = _firestore
              .collection("users")
              .doc(widget.uid)
              .collection("friends")
              .doc(widget.user.userData.uid)
              .delete();

          Future<void> deleteMeToFriendFuture = _firestore
              .collection("users")
              .doc(widget.user.userData.uid)
              .collection("friends")
              .doc(widget.uid)
              .delete();

          await Future.wait([
            blockFriendToMeFuture,
            blockMeToFriendFuture,
            deleteFriendToMeFuture,
            deleteMeToFriendFuture
          ]);

          widget.onUnfriendOrBlock();
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
              onPressed: () {
                Get.to(() => ChatPage(profile: widget.user, uid: widget.uid),
                    transition: Transition.fade);
              },
              icon: const Icon(Icons.chat),
            ),
            const SizedBox(width: 4)
          ],
        ),
      ),
    );
  }
}
