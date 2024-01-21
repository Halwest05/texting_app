import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:texting_app/pages/chat_page.dart';
import 'package:texting_app/tools.dart';

class OnlineTab extends StatelessWidget {
  final String uid;
  const OnlineTab({super.key, required this.uid});

  static List<UserProfile> profiles = [];

  @override
  Widget build(BuildContext context) {
    return profiles.isEmpty
        ? const Center(child: Text("No active friends..."))
        : RefreshIndicator(
            onRefresh: () async {
              return await Future.delayed(const Duration(seconds: 1));
            },
            child: ListView.builder(
                padding: const EdgeInsets.only(top: 25, left: 4, right: 4),
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      OnlineTile(profile: profiles[index], uid: uid),
                      const Divider(color: Colors.black45)
                    ],
                  );
                },
                itemCount: profiles.length),
          );
  }
}

class OnlineTile extends StatelessWidget {
  const OnlineTile({super.key, required this.profile, required this.uid});

  final UserProfile profile;
  final String uid;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(
          () => ChatPage(profile: profile, uid: uid),
          transition: Transition.fade,
          duration: const Duration(milliseconds: 200),
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: MyTools.isKurdish ? 0 : 8,
                  right: MyTools.isKurdish ? 8 : 0),
              child: Card(
                  shape: const CircleBorder(),
                  clipBehavior: Clip.hardEdge,
                  child:
                      Image.asset(profile.userData.imgPath.value, height: 60)),
            ),
            Expanded(
              child: Text(
                profile.userData.name.value,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 17),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  right: MyTools.isKurdish ? 0 : 12,
                  left: MyTools.isKurdish ? 12 : 0),
              child: Align(
                  alignment: MyTools.isKurdish
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                      height: 12,
                      width: 12,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.green))),
            )
          ],
        ),
      ),
    );
  }
}
