import 'package:flutter/material.dart';
import 'package:texting_app/tools.dart';

class OnlineTab extends StatelessWidget {
  const OnlineTab({super.key});

  static List<MiniProfile> profiles = [
    MiniProfile(
        name: "Hallo Ahmed",
        imgPath: MyTools.testPropic2,
        message: "ajsdkhsakjdsaq9w8diok"),
    MiniProfile(
        name: "Halkawt Mahmood",
        imgPath: MyTools.testPropic3,
        message: "ajsdkhsakjdsawdhjqkd"),
    MiniProfile(
        name: "Hallsho Mlshor",
        imgPath: MyTools.testPropic4,
        message: "n8e29es28y71s182u"),
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
      onTap: () {},
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
