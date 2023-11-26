import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:texting_app/pages/home_page/home/profile_bottom_sheet.dart';
import 'package:texting_app/tools.dart';

class OnlineTab extends StatelessWidget {
  const OnlineTab({super.key});

  static List<MiniProfile> profiles = [
    MiniProfile(
        name: "Hallo Ahmed", imgPath: MyTools.testPropic2, username: "hallo20"),
    MiniProfile(
        name: "Halkawt Mahmood",
        imgPath: MyTools.testPropic3,
        username: "halkawt69"),
    MiniProfile(
        name: "Hallsho Mlshor",
        imgPath: MyTools.testPropic4,
        username: "halshomlsho"),
  ];

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        return await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
          padding: const EdgeInsets.only(top: 25, left: 12, right: 12),
          itemBuilder: (context, index) {
            return Column(
              children: [
                OnlineTile(profile: profiles[index]),
                const Divider(color: Colors.black45)
              ],
            );
          },
          itemCount: profiles.length),
    );
  }
}

class OnlineTile extends StatelessWidget {
  const OnlineTile({super.key, required this.profile});

  final MiniProfile profile;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.bottomSheet(ProfileBottomSheet(profile: profile),
            isScrollControlled: true);
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
                  child: Image.asset(profile.imgPath, height: 60)),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                profile.name,
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