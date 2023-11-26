import 'package:flutter/material.dart';
import 'package:texting_app/tools.dart';

class ChatsTab extends StatelessWidget {
  const ChatsTab({super.key});

  static List<MiniProfile> profiles = [
    MiniProfile(
        name: "Halmat Mohammed",
        imgPath: MyTools.testPropic1,
        message: "ajsdkhsakjdsaasdjksa"),
    MiniProfile(
        name: "Hallo Ahmed",
        imgPath: MyTools.testPropic2,
        message: "ajsdkhsakjdsaq9w8diok"),
    MiniProfile(
        name: "Halkawt Mahmood",
        imgPath: MyTools.testPropic3,
        message: "ajsdkhsakjdsawdhjqkd"),
    MiniProfile(
        name: "Halwest Hamamin",
        imgPath: MyTools.testPropic1,
        message: "ajsdkhsakjdsa19i2ijks"),
    MiniProfile(
        name: "Hallsho Mlshor",
        imgPath: MyTools.testPropic4,
        message: "n8e29es28y71s182u"),
    MiniProfile(
        name: "Halgwrd Karwan",
        imgPath: MyTools.testPropic3,
        message: "ajsdkhsakjdsaas9duiasojd")
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
                ChatsTile(profile: profiles[index]),
                const Divider(color: Colors.black45),
              ],
            );
          },
          itemCount: profiles.length),
    );
  }
}

class ChatsTile extends StatelessWidget {
  const ChatsTile({super.key, required this.profile});

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
                child: Image.asset(profile.imgPath, height: 60),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.name, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const SizedBox(width: 5),
                    Text(profile.message,
                        style: const TextStyle(color: Colors.black54))
                  ],
                )
              ],
            ),
            Expanded(
              child: Align(
                alignment: MyTools.isKurdish
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(
                      right: MyTools.isKurdish ? 0 : 5,
                      left: MyTools.isKurdish ? 5 : 0),
                  child: const Text("5m ago",
                      style: TextStyle(color: Colors.black54)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
