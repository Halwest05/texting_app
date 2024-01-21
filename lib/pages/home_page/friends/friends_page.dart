import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:texting_app/pages/chat_page.dart';
import 'package:texting_app/pages/home_page/friend_profile_bottom_sheet.dart';
import 'package:texting_app/tools.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class FriendsPage extends StatefulWidget {
  final String uid;
  const FriendsPage({super.key, required this.uid});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 500));
        setState(() {});
      },
      child: FutureBuilder<List<Friend>>(
          future: getFriends(),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return const Center(child: CircularProgressIndicator());
            }

            List<Friend> friends = snapshot.data!;

            if (friends.isEmpty) {
              return Center(
                  child: Text(AppLocalizations.of(context)!.nofriendsyet));
            }

            return ListView.separated(
                separatorBuilder: (context, index) =>
                    const Divider(color: Colors.black45),
                itemBuilder: (context, index) => FriendsPageTile(
                    key: UniqueKey(),
                    friend: friends[index],
                    uid: widget.uid,
                    onUnfriendOrBlock: () => setState(() {})),
                itemCount: friends.length,
                padding: const EdgeInsets.only(top: 25, left: 8, right: 8));
          }),
    );
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Friend>> getFriends() async {
    List<Friend> friends = [];

    QuerySnapshot<Map<String, dynamic>> friendsSnapshot = await _firestore
        .collection("users")
        .doc(widget.uid)
        .collection("friends")
        .get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> doc
        in friendsSnapshot.docs) {
      friends.add(Friend(uid: doc.id, timestamp: doc.get("timestamp")));
    }

    return friends;
  }
}

class FriendsPageTile extends StatefulWidget {
  const FriendsPageTile(
      {super.key,
      required this.friend,
      required this.uid,
      required this.onUnfriendOrBlock});

  final Friend friend;
  final String uid;
  final Function onUnfriendOrBlock;

  @override
  State<FriendsPageTile> createState() => _FriendsPageTileState();
}

class _FriendsPageTileState extends State<FriendsPageTile> {
  UserProfile? _user;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      color: const Color.fromRGBO(227, 180, 226, 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        onTap: () async {
          if (_user != null) {
            String? res = await Get.bottomSheet(
                FriendProfileBottomSheet(user: _user!, uid: widget.uid),
                isScrollControlled: true);

            if (res == "message") {
              Get.to(() => ChatPage(profile: _user!, uid: widget.uid),
                  transition: Transition.fade);
            } else if (res == "unfriend") {
              Future<void> deleteFriendToMeFuture = _firestore
                  .collection("users")
                  .doc(widget.uid)
                  .collection("friends")
                  .doc(widget.friend.uid)
                  .delete();

              Future<void> deleteMeToFriendFuture = _firestore
                  .collection("users")
                  .doc(widget.friend.uid)
                  .collection("friends")
                  .doc(widget.uid)
                  .delete();

              await Future.wait(
                  [deleteFriendToMeFuture, deleteMeToFriendFuture]);

              widget.onUnfriendOrBlock();
            } else if (res == "block") {
              DateTime now = DateTime.now();

              Future<void> blockFriendToMeFuture = _firestore
                  .collection("users")
                  .doc(widget.uid)
                  .collection("blocklist")
                  .doc(_user!.userData.uid)
                  .set({
                "timestamp": now.millisecondsSinceEpoch,
                "by": widget.uid
              });

              Future<void> blockMeToFriendFuture = _firestore
                  .collection("users")
                  .doc(_user!.userData.uid)
                  .collection("blocklist")
                  .doc(widget.uid)
                  .set({
                "timestamp": now.millisecondsSinceEpoch,
                "by": widget.uid
              });

              Future<void> deleteFriendToMeFuture = _firestore
                  .collection("users")
                  .doc(widget.uid)
                  .collection("friends")
                  .doc(_user!.userData.uid)
                  .delete();

              Future<void> deleteMeToFriendFuture = _firestore
                  .collection("users")
                  .doc(_user!.userData.uid)
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
          }
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: FutureBuilder<UserProfile>(
              future: getUserFromFriend(friend: widget.friend),
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Row(children: [
                      Container(
                        height: 80,
                        width: 80,
                        decoration: const ShapeDecoration(
                            shape: CircleBorder(), color: Colors.white),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 125,
                        height: 16,
                        color: Colors.white,
                      )
                    ]),
                  );
                }

                UserProfile user = snapshot.data!;
                _user ??= user;

                return Row(
                  children: [
                    Card(
                      shape: const CircleBorder(),
                      clipBehavior: Clip.hardEdge,
                      child: MyNetworkImage(
                          src: user.userData.imgPath.value, height: 80),
                    ),
                    const SizedBox(width: 4),
                    Text(user.userData.name.value,
                        style: const TextStyle(fontSize: 16))
                  ],
                );
              }),
        ),
      ),
    );
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<UserProfile> getUserFromFriend({required Friend friend}) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection("users").doc(friend.uid).get();

    DataSnapshot likeSnapshot =
        await _database.ref("likes").child(friend.uid).child(widget.uid).get();

    return UserProfile(
        userData: FirestoreUser.mapToFirestoreUser(
            mappedUser: snapshot.data()!, uid: snapshot.id),
        likeState: likeSnapshot.exists);
  }
}

class Friend {
  final String uid;
  final int timestamp;

  const Friend({required this.uid, required this.timestamp});
}
