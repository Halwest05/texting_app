import 'package:flutter/material.dart';
import 'package:texting_app/tools.dart';

class ChatPage extends StatelessWidget {
  final MiniProfile profile;
  const ChatPage({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          Card(
              clipBehavior: Clip.antiAlias,
              shape: const CircleBorder(),
              elevation: 3,
              child: Image.asset(profile.imgPath, height: 48)),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.name,
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 4),
                    Text("Active now",
                        style: TextStyle(fontSize: 13, color: Colors.green),
                        overflow: TextOverflow.ellipsis),
                  ],
                )
              ],
            ),
          )
        ]),
        actions: [
          InkWell(
            onTap: () {},
            customBorder: const CircleBorder(),
            child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.videocam_rounded)),
          ),
          InkWell(
            onTap: () {},
            customBorder: const CircleBorder(),
            child: const Padding(
                padding: EdgeInsets.all(8), child: Icon(Icons.call_rounded)),
          ),
          const SizedBox(width: 3)
        ],
      ),
    );
  }
}
