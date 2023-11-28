import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:texting_app/pages/home_page/profile_bottom_sheet.dart';
import 'package:texting_app/tools.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class ChatPage extends StatefulWidget {
  final MiniProfile profile;
  const ChatPage({super.key, required this.profile});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final FocusNode _chatFocusNode;
  late final TextEditingController _chatController;

  @override
  void initState() {
    super.initState();

    _chatFocusNode = FocusNode();
    _chatController = TextEditingController();

    if (widget.profile.message != null) {
      messages.add(Message(
          name: widget.profile.name,
          imgPath: widget.profile.imgPath,
          message: widget.profile.message!,
          isSelf: false));
    }
  }

  @override
  void dispose() {
    _chatFocusNode.dispose();
    _chatController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        bottomSheet: Card(
          margin: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          ),
          color: const Color.fromRGBO(206, 128, 203, 1),
          child: Row(
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: _chatFocusNode.hasFocus
                    ? const SizedBox()
                    : Row(
                        children: [
                          InkWell(
                            onTap: () {},
                            customBorder: const CircleBorder(),
                            child: const Padding(
                              padding: EdgeInsets.all(7),
                              child: Icon(Icons.camera_alt_rounded,
                                  color: Colors.purple, size: 25),
                            ),
                          ),
                          InkWell(
                            onTap: () {},
                            customBorder: const CircleBorder(),
                            child: const Padding(
                              padding: EdgeInsets.all(7),
                              child: Icon(Icons.image_rounded,
                                  color: Colors.purple, size: 24),
                            ),
                          ),
                        ],
                      ),
              ),
              InkWell(
                onTap: () {},
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.keyboard_voice_rounded,
                      color: Colors.purple, size: 28),
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: TextField(
                    focusNode: _chatFocusNode,
                    controller: _chatController,
                    onTap: () {
                      if (!_chatFocusNode.hasFocus) {
                        setState(() {}); // Fixes initial focus bug
                      }
                    },
                    keyboardType: TextInputType.multiline,
                    maxLines: _chatFocusNode.hasFocus ? 4 : 1,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.type_a_msg,
                      fillColor: const Color.fromRGBO(227, 180, 226, 1),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  if (_chatController.text.isNotEmpty) {
                    setState(() {
                      messages.add(Message(
                          name: "",
                          imgPath: "",
                          message: _chatController.text,
                          isSelf: true));

                      _chatController.clear();
                      _chatFocusNode.unfocus();
                    });
                  }
                },
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.send_rounded,
                    color: Colors.purple,
                    size: 28,
                  ),
                ),
              )
            ],
          ),
        ),
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
          title: InkWell(
            customBorder: const StadiumBorder(),
            onTap: () {
              Get.bottomSheet(ProfileBottomSheet(profile: widget.profile),
                  isScrollControlled: true);
            },
            child: Padding(
              padding: EdgeInsets.only(
                  left: MyTools.isKurdish ? 8 : 0,
                  right: MyTools.isKurdish ? 0 : 8),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Card(
                    clipBehavior: Clip.antiAlias,
                    shape: const CircleBorder(),
                    elevation: 3,
                    child: Image.asset(widget.profile.imgPath, height: 48)),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.profile.name,
                          style: const TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis),
                      Padding(
                        padding: EdgeInsets.only(
                            left: MyTools.isKurdish ? 0 : 4,
                            right: MyTools.isKurdish ? 4 : 0),
                        child: Text(AppLocalizations.of(context)!.active_now,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.green),
                            overflow: TextOverflow.ellipsis),
                      )
                    ],
                  ),
                )
              ]),
            ),
          ),
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
        body: Directionality(
          textDirection: TextDirection.ltr,
          child: ListView.builder(
              padding: const EdgeInsets.only(top: 6),
              itemBuilder: (context, index) =>
                  MessageCard(msg: messages[index]),
              itemCount: messages.length),
        ),
      ),
    );
  }

  List<Message> messages = [];
}

class MessageCard extends StatelessWidget {
  final Message msg;
  const MessageCard({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    return msg.isSelf ? myText() : friendText();
  }

  Widget myText() {
    return Padding(
      padding: const EdgeInsets.only(right: 3),
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: Get.width * 0.80),
          child: Card(
            clipBehavior: Clip.hardEdge,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(8), left: Radius.circular(16))),
            color: const Color.fromRGBO(227, 180, 226, 1),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  myBidirectionalText(text: msg.message),
                  const SizedBox(height: 3),
                  const Text("9:45 AM",
                      style: TextStyle(color: Colors.black54, fontSize: 12))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget friendText() {
    return Row(children: [
      Card(
          clipBehavior: Clip.hardEdge,
          shape: const CircleBorder(),
          child: Image.asset(msg.imgPath, height: 55)),
      ConstrainedBox(
        constraints: BoxConstraints(maxWidth: Get.width * 0.70),
        child: Card(
          clipBehavior: Clip.hardEdge,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(8), right: Radius.circular(16))),
          color: const Color.fromRGBO(227, 180, 226, 1),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                myBidirectionalText(text: msg.message),
                const SizedBox(height: 3),
                const Text("9:45 AM",
                    style: TextStyle(color: Colors.black54, fontSize: 12))
              ],
            ),
          ),
        ),
      )
    ]);
  }

  Widget myBidirectionalText({required String text}) {
    List<String> lines = text.split("\n");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(
        lines.length,
        (index) => Text(lines[index],
            textDirection: intl.Bidi.detectRtlDirectionality(lines[index])
                ? TextDirection.rtl
                : TextDirection.ltr),
      ),
    );
  }
}

class Message {
  final String name;
  final String message;
  final String imgPath;
  final bool isSelf;

  const Message(
      {required this.name,
      required this.imgPath,
      required this.message,
      required this.isSelf});
}
