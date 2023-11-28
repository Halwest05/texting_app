import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:texting_app/pages/home_page/profile_bottom_sheet.dart';
import 'package:texting_app/tools.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  static final List<MiniProfile> profiles = [
    MiniProfile(
        name: "Hallo Mohammed",
        imgPath: MyTools.testPropic1,
        username: "hallo20"),
    MiniProfile(
        name: "Halmat Mahmood",
        imgPath: MyTools.testPropic3,
        username: "halmat10"),
    MiniProfile(
        name: "Halkawt Ahmed",
        imgPath: MyTools.testPropic4,
        username: "halkawt69"),
    MiniProfile(
        name: "Hallgwrd Salahaddin",
        imgPath: MyTools.testPropic2,
        username: "halgwrd12"),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 25, left: 8, right: 8),
      child: ListView.builder(
          itemBuilder: (context, index) => Column(
                children: [
                  FriendsPageTile(profile: profiles[index]),
                  const Divider(color: Colors.black45)
                ],
              ),
          itemCount: profiles.length),
    );
  }
}

class FriendsPageTile extends StatelessWidget {
  const FriendsPageTile({super.key, required this.profile});

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
            Expanded(
                child: Text(profile.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 17))),
          ],
        ),
      ),
    );
  }
}
