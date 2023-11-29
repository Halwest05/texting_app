import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:texting_app/pages/chat_page.dart';
import 'package:texting_app/tools.dart';

class ChatsTab extends StatelessWidget {
  const ChatsTab({super.key});

  static List<MiniProfile> profiles = [
    MiniProfile(
        name: "Halmat Mohammed",
        imgPath: MyTools.testPropic1,
        message: "ajsdkhsakjdsaasdjksa",
        username: "halmat10"),
    MiniProfile(
        name: "Hallo Ahmed",
        imgPath: MyTools.testPropic2,
        message: "ajsdkhsakjdsaq9w8diok aaksdha",
        username: "hallo20"),
    MiniProfile(
        name: "Halkawt Mahmood",
        imgPath: MyTools.testPropic3,
        message: "ajsdkhsakjdsawdhjqkd",
        username: "halkawt69"),
    MiniProfile(
        name: "Halwest Hamamin",
        imgPath: MyTools.testPropic1,
        message: "ajsdkhsakjdsa19i2ijks",
        username: "halwest12"),
    MiniProfile(
        name: "Hallsho Mlshor",
        imgPath: MyTools.testPropic4,
        message: "n8e29es28y71s182u",
        username: "halshomlshor"),
    MiniProfile(
        name: "Halgwrd Karwan",
        imgPath: MyTools.testPropic3,
        message: "ajsdkhsakjdsaas9duiasojd",
        username: "halgwrd01")
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: const EdgeInsets.only(top: 25, left: 4, right: 4),
        itemBuilder: (context, index) {
          return Column(
            children: [
              ChatsTile(profile: profiles[index]),
              const Divider(color: Colors.black45),
            ],
          );
        },
        itemCount: profiles.length);
  }
}

class ChatsTile extends StatelessWidget {
  const ChatsTile({super.key, required this.profile});

  final MiniProfile profile;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(ChatPage(profile: profile), transition: Transition.fade);
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
                child: Image.asset(profile.imgPath, height: 60),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  Padding(
                    padding: EdgeInsets.only(
                        left: MyTools.isKurdish ? 0 : 5,
                        right: MyTools.isKurdish ? 5 : 0),
                    child: Text(profile.message!,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black54)),
                  )
                ],
              ),
            ),
            Align(
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
            )
          ],
        ),
      ),
    );
  }
}
