import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:texting_app/tools.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class ProfileBottomSheetNew extends StatefulWidget {
  final String uid;
  final UserProfile user;
  final List<Widget> actions;

  const ProfileBottomSheetNew(
      {super.key,
      required this.user,
      required this.uid,
      this.actions = const []});

  @override
  State<ProfileBottomSheetNew> createState() => _ProfileBottomSheetStateNew();
}

class _ProfileBottomSheetStateNew extends State<ProfileBottomSheetNew> {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  int? likeCount;

  @override
  void initState() {
    super.initState();

    _database
        .ref("likes")
        .child(widget.user.userData.uid)
        .get()
        .then((snapshot) => setState(() {
              likeCount = snapshot.children.length;
            }));
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      onClosing: () {},
      enableDrag: false,
      backgroundColor: const Color.fromRGBO(227, 180, 226, 1),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 5),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Flexible(
              child: Card(
                elevation: 4,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                child: GestureDetector(
                  onTap: () => Get.dialog(GestureDetector(
                      onTap: () => Get.back(),
                      child: MyNetworkImage(
                          src: widget.user.userData.imgPath.value,
                          fit: BoxFit.contain))),
                  child: MyNetworkImage(
                      src: widget.user.userData.imgPath.value, height: 200),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(children: [
                Text(widget.user.userData.name.value,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 3),
                Text(
                  "ID: ${widget.user.userData.username}",
                  style: const TextStyle(color: Colors.black54),
                  overflow: TextOverflow.ellipsis,
                )
              ]),
            ),
            const Divider(color: Colors.black45),
            Row(
              children: [
                const SizedBox(width: 4),
                Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: () {
                        if (likeCount != null) {
                          if (!widget.user.likeState) {
                            _database
                                .ref("likes")
                                .child(widget.user.userData.uid)
                                .child(widget.uid)
                                .set(true);
                            likeCount = likeCount! + 1;
                          } else {
                            _database
                                .ref("likes")
                                .child(widget.user.userData.uid)
                                .child(widget.uid)
                                .remove();

                            likeCount = likeCount! - 1;
                          }

                          setState(() {
                            widget.user.setLikeState(!widget.user.likeState);
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        child: Column(
                          children: [
                            widget.user.likeState
                                ? const Icon(Icons.favorite,
                                    color: Colors.pinkAccent, size: 34)
                                : const Icon(Icons.favorite_border,
                                    color: Colors.pinkAccent, size: 32),
                            likeCount == null
                                ? Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(
                                        color: Colors.white,
                                        height: 7,
                                        width: 14))
                                : Text(likeCount.toString())
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                        height: 50,
                        child: VerticalDivider(color: Colors.black45))
                  ],
                ),
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.actions,
                  ),
                )
              ],
            ),
            const Divider(color: Colors.black45),
            ElevatedButton(
              onPressed: () async {
                String? res = await Get.dialog(
                  AlertDialog(
                    title: Text(AppLocalizations.of(context)!.are_u_sure),
                    content:
                        Text(AppLocalizations.of(context)!.do_u_wanna_block),
                    actions: [
                      TextButton(
                          onPressed: () => Get.back(),
                          child: Text(AppLocalizations.of(context)!.no)),
                      TextButton(
                          style:
                              TextButton.styleFrom(foregroundColor: Colors.red),
                          onPressed: () => Get.back(result: "block"),
                          child: Text(AppLocalizations.of(context)!.yes))
                    ],
                  ),
                );

                if (res == "block") {
                  Get.back(result: "block");
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.block),
                    const SizedBox(width: 6),
                    Text(AppLocalizations.of(context)!.block)
                  ],
                ),
              ),
            )
          ]),
        );
      },
    );
  }
}
