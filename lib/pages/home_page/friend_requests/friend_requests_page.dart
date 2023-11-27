import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:texting_app/pages/home_page/friend_request_profile_bottom_sheet.dart';
import 'package:texting_app/tools.dart';

class FriendRequestsPage extends StatelessWidget {
  final List<MiniProfile> profiles;
  const FriendRequestsPage({super.key, required this.profiles});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 25, left: 8, right: 8),
      child: ListView.builder(
          itemBuilder: (context, index) => Column(
                children: [
                  FriendRequestsPageTile(profile: profiles[index]),
                  const Divider(color: Colors.black45)
                ],
              ),
          itemCount: profiles.length),
    );
  }
}

class FriendRequestsPageTile extends StatelessWidget {
  const FriendRequestsPageTile({super.key, required this.profile});

  final MiniProfile profile;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.bottomSheet(FriendRequestProfileBottomSheet(profile: profile),
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
                child: Text(profile.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 17))),
            Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () {},
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(Icons.person_remove_rounded,
                        color: Colors.red, size: 28),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () {},
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(Icons.person_add_rounded,
                        color: Colors.green, size: 28),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
