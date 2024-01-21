import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:texting_app/pages/home_page/friend_request_profile_bottom_sheet.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:texting_app/tools.dart';

class FriendRequestsPage extends StatefulWidget {
  final String uid;
  const FriendRequestsPage({super.key, required this.uid});

  @override
  State<FriendRequestsPage> createState() => _FriendRequestsPageState();
}

class _FriendRequestsPageState extends State<FriendRequestsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<FriendRequest> requests = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestore
            .collection("users")
            .doc(widget.uid)
            .collection("friendRequests")
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.data!.size == 0) {
            return Center(
              child: Text(
                AppLocalizations.of(context)!.norqestyet,
                style: const TextStyle(color: Colors.black45),
              ),
            );
          }

          requests = [];

          for (QueryDocumentSnapshot<Map<String, dynamic>> doc
              in snapshot.data!.docs) {
            requests.add(FriendRequest(
              uid: doc.id,
              requestDate: DateTime.fromMillisecondsSinceEpoch(
                doc.get("timestamp"),
              ),
            ));
          }

          return ListView.separated(
            separatorBuilder: (context, index) =>
                const Divider(color: Colors.black45),
            itemBuilder: (context, index) => FriendRequestsPageTile(
                key: UniqueKey(), request: requests[index], uid: widget.uid),
            itemCount: requests.length,
            padding: const EdgeInsets.only(top: 25, left: 8, right: 8),
          );
        });
  }
}

class FriendRequestsPageTile extends StatefulWidget {
  const FriendRequestsPageTile(
      {super.key, required this.request, required this.uid});

  final String uid;
  final FriendRequest request;

  @override
  State<FriendRequestsPageTile> createState() => _FriendRequestsPageTileState();
}

class _FriendRequestsPageTileState extends State<FriendRequestsPageTile> {
  UserProfile? _user;

  Offset currentOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
      offset: currentOffset,
      onEnd: animationEnded,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        clipBehavior: Clip.hardEdge,
        color: const Color.fromRGBO(227, 180, 226, 1),
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          onTap: () async {
            if (_user != null) {
              String? res = await Get.bottomSheet(
                  FriendRequestProfileBottomSheet(
                      user: _user!, uid: widget.uid),
                  isScrollControlled: true);

              if (res == "block") {
                DateTime now = DateTime.now();

                Future<void> blockUserToMeFuture = _firestore
                    .collection("users")
                    .doc(widget.uid)
                    .collection("blocklist")
                    .doc(_user!.userData.uid)
                    .set({
                  "timestamp": now.millisecondsSinceEpoch,
                  "by": widget.uid
                });

                Future<void> blockMeToUserFuture = _firestore
                    .collection("users")
                    .doc(_user!.userData.uid)
                    .collection("blocklist")
                    .doc(widget.uid)
                    .set({
                  "timestamp": now.millisecondsSinceEpoch,
                  "by": widget.uid
                });

                Future<void> deleteRequestFuture = _firestore
                    .collection("users")
                    .doc(widget.uid)
                    .collection("friendRequests")
                    .doc(_user!.userData.uid)
                    .delete();

                await Future.wait([
                  blockUserToMeFuture,
                  blockMeToUserFuture,
                  deleteRequestFuture
                ]);
              }
            }
          },
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                FutureBuilder<UserProfile>(
                    future: getUserFromRequest(request: widget.request),
                    builder: (context, snapshot) {
                      if (snapshot.data == null) {
                        return Expanded(
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Row(children: [
                              Container(
                                height: 80,
                                width: 80,
                                decoration: const ShapeDecoration(
                                    shape: CircleBorder(), color: Colors.white),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 125,
                                height: 16,
                                color: Colors.white,
                              )
                            ]),
                          ),
                        );
                      }

                      UserProfile user = snapshot.data!;
                      _user ??= user;

                      return Expanded(
                        child: Row(
                          children: [
                            Card(
                              shape: const CircleBorder(),
                              clipBehavior: Clip.hardEdge,
                              child: MyNetworkImage(
                                  src: user.userData.imgPath.value, height: 80),
                            ),
                            const SizedBox(width: 6),
                            Text(user.userData.name.value,
                                style: const TextStyle(fontSize: 16))
                          ],
                        ),
                      );
                    }),
                Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: isActing
                          ? null
                          : () {
                              setState(() {
                                isActing = true;
                                currentOffset = const Offset(-1, 0);
                              });
                            },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Icon(Icons.person_remove_rounded,
                            color: isActing ? Colors.grey : Colors.red,
                            size: 28),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: isActing
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
                                  .doc(widget.request.uid)
                                  .set({
                                "timestamp": now.millisecondsSinceEpoch
                              });

                              Future<void> setMeForUserFuture = _firestore
                                  .collection("users")
                                  .doc(widget.request.uid)
                                  .collection("friends")
                                  .doc(widget.uid)
                                  .set({
                                "timestamp": now.millisecondsSinceEpoch
                              });

                              Future<void> deleteFriendsFriendRequestFuture =
                                  _firestore
                                      .collection("users")
                                      .doc(widget.request.uid)
                                      .collection("friendRequests")
                                      .doc(widget.uid)
                                      .delete();

                              await Future.wait([
                                setUserForMeFuture,
                                setMeForUserFuture,
                                deleteFriendsFriendRequestFuture
                              ]);

                              setState(() {
                                currentOffset = const Offset(1, 0);
                              });
                            },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Icon(Icons.person_add_rounded,
                            color: isActing ? Colors.grey : Colors.green,
                            size: 28),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void animationEnded() {
    _firestore
        .collection("users")
        .doc(widget.uid)
        .collection("friendRequests")
        .doc(widget.request.uid)
        .delete();
  }

  bool isActing = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<UserProfile> getUserFromRequest(
      {required FriendRequest request}) async {
    DocumentSnapshot<Map<String, dynamic>> docSnapshot =
        await _firestore.collection("users").doc(request.uid).get();

    DataSnapshot likeSnapshot = await _database
        .ref("likes")
        .child(docSnapshot.id)
        .child(widget.uid)
        .get();

    return UserProfile(
        userData: FirestoreUser.mapToFirestoreUser(
            mappedUser: docSnapshot.data()!, uid: docSnapshot.id),
        likeState: likeSnapshot.exists);
  }
}

class FriendRequest {
  final String uid;
  final DateTime requestDate;

  const FriendRequest({required this.uid, required this.requestDate});
}
