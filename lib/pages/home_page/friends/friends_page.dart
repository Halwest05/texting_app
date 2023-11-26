import 'package:flutter/material.dart';
import 'package:texting_app/tools.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  static final List<MiniProfile> profiles = [
    MiniProfile(
        name: "Hallo Mohammed", imgPath: MyTools.testPropic1, message: ""),
    MiniProfile(
        name: "Halmat Mahmood", imgPath: MyTools.testPropic3, message: ""),
    MiniProfile(
        name: "Halkawt Ahmed", imgPath: MyTools.testPropic4, message: ""),
    MiniProfile(
        name: "Hallgwrd Salahaddin", imgPath: MyTools.testPropic2, message: ""),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 25, left: 12, right: 12),
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
            Text(profile.name, style: const TextStyle(fontSize: 17)),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    right: MyTools.isKurdish ? 0 : 8,
                    left: MyTools.isKurdish ? 8 : 0),
                child: Align(
                    alignment: MyTools.isKurdish
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: IconButton(
                        color: Colors.purple,
                        onPressed: () {},
                        icon: const Icon(Icons.person_remove_rounded))),
              ),
            )
          ],
        ),
      ),
    );
  }
}
