import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' as intl;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:texting_app/pages/home_page/friend_profile_bottom_sheet.dart';
import 'package:texting_app/tools.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ChatPage extends StatefulWidget {
  final MiniProfile profile;
  const ChatPage({super.key, required this.profile});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final FocusNode _chatFocusNode;
  late final TextEditingController _chatController;
  late final ScrollController _chatScrollController;

  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _chatFocusNode = FocusNode();
    _chatController = TextEditingController();
    _chatScrollController = ScrollController();

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
    _chatScrollController.dispose();
    recorder.dispose();

    super.dispose();
  }

  bool isRecording = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          leadingWidth: 34,
          title: InkWell(
            customBorder: const StadiumBorder(),
            onTap: () async {
              String? res = await Get.bottomSheet(
                  FriendProfileBottomSheet(profile: widget.profile),
                  isScrollControlled: true);

              if (res == "unfriend" || res == "block") {
                Get.back();
              }
            },
            child: Padding(
              padding: EdgeInsets.only(
                  left: MyTools.isKurdish ? 8 : 0,
                  right: MyTools.isKurdish ? 0 : 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Card(
                      clipBehavior: Clip.antiAlias,
                      shape: const CircleBorder(),
                      elevation: 3,
                      child: Image.asset(widget.profile.imgPath, height: 45)),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.profile.name,
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis),
                        Padding(
                          padding: EdgeInsets.only(
                              left: MyTools.isKurdish ? 0 : 4,
                              right: MyTools.isKurdish ? 4 : 0),
                          child: Text(AppLocalizations.of(context)!.active_now,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.green),
                              overflow: TextOverflow.ellipsis),
                        )
                      ],
                    ),
                  )
                ],
              ),
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
        body: Column(
          children: [
            Expanded(
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: AnimatedList(
                  key: _listKey,
                  controller: _chatScrollController,
                  initialItemCount: messages.length,
                  padding: const EdgeInsets.only(top: 6),
                  itemBuilder: (context, index, animation) => SlideTransition(
                    position: animation.drive(
                      Tween(
                              begin: messages.last.isSelf
                                  ? const Offset(1, 0)
                                  : const Offset(-1, 0),
                              end: const Offset(0, 0))
                          .chain(
                        CurveTween(curve: Curves.easeOut),
                      ),
                    ),
                    child: MessageCard(
                      msg: messages[index],
                    ),
                  ),
                ),
              ),
            ),
            Card(
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
                                onTapDown: (details) async {
                                  setState(() {
                                    isRecording = true;
                                  });

                                  if (await recorder.hasPermission()) {
                                    recorder.start(
                                        const RecordConfig(
                                            encoder: AudioEncoder.wav),
                                        path:
                                            "${(await getTemporaryDirectory()).path}${DateTime.now()}.wav");
                                  } else {
                                    setState(() {
                                      isRecording = false;
                                    });
                                  }
                                },
                                onTapCancel: () {
                                  setState(() {
                                    isRecording = false;
                                  });

                                  recorder.stop();
                                },
                                onTapUp: (details) async {
                                  setState(() {
                                    isRecording = false;
                                  });

                                  String? outputPath = await recorder.stop();

                                  if (outputPath != null) {
                                    AudioPlayer player = AudioPlayer();

                                    Duration? duration =
                                        await player.setFilePath(outputPath);

                                    if (duration!.inSeconds >= 1) {
                                      sendMessage(
                                          name: "",
                                          imgPath: "",
                                          isSelf: true,
                                          voicePath: outputPath);
                                    }

                                    player.dispose();
                                  }
                                },
                                customBorder: const CircleBorder(),
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Icon(
                                      isRecording
                                          ? Icons.settings_voice_rounded
                                          : Icons.keyboard_voice_rounded,
                                      color: Colors.purple,
                                      size: 28),
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  String? res = await showDialog(
                                    context: context,
                                    builder: (context) {
                                      return SimpleDialog(
                                        title: Text(
                                            AppLocalizations.of(context)!
                                                .choose_cam_way),
                                        children: [
                                          TextButton.icon(
                                            onPressed: () {
                                              Get.back(result: "photo");
                                            },
                                            icon:
                                                const Icon(Icons.image_rounded),
                                            label: Text(
                                                AppLocalizations.of(context)!
                                                    .photo),
                                          ),
                                          TextButton.icon(
                                            onPressed: () {
                                              Get.back(result: "video");
                                            },
                                            icon: const Icon(
                                                Icons.video_collection_rounded),
                                            label: Text(
                                                AppLocalizations.of(context)!
                                                    .video),
                                          )
                                        ],
                                      );
                                    },
                                  );

                                  if (res == "photo") {
                                    XFile? imageFile =
                                        await _imagePicker.pickImage(
                                            source: ImageSource.camera,
                                            imageQuality: 75,
                                            maxHeight: 1500,
                                            maxWidth: 1500);

                                    if (imageFile != null) {
                                      Media media = Media(
                                          type: MediaType.picture,
                                          img: imageFile.path);

                                      sendMessage(
                                          name: "",
                                          imgPath: "",
                                          isSelf: true,
                                          medias: <Media>[media]);
                                    }
                                  } else if (res == "video") {
                                    XFile? vidFile = await _imagePicker
                                        .pickVideo(source: ImageSource.camera);

                                    if (vidFile != null) {
                                      String thumbnailPath =
                                          (await VideoThumbnail.thumbnailFile(
                                              video: vidFile.path,
                                              maxWidth: 1500,
                                              maxHeight: 1500,
                                              quality: 75))!;

                                      Media media = Media(
                                          type: MediaType.video,
                                          vid: Video(
                                              thumbnailPath: thumbnailPath,
                                              vidPath: vidFile.path));

                                      sendMessage(
                                          name: "",
                                          imgPath: "",
                                          isSelf: true,
                                          medias: <Media>[media]);
                                    }
                                  }
                                },
                                customBorder: const CircleBorder(),
                                child: const Padding(
                                  padding: EdgeInsets.all(7),
                                  child: Icon(Icons.camera_alt_rounded,
                                      color: Colors.purple, size: 25),
                                ),
                              ),
                            ],
                          ),
                  ),
                  InkWell(
                    onTap: pickMediaFromGallery,
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(7),
                      child: Icon(Icons.image_rounded,
                          color: Colors.purple, size: 24),
                    ),
                  ),
                  isRecording
                      ? SizedBox(
                          height: 60,
                          child: Row(
                            children: [
                              const MyRecordTimeCounter(),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.slide_to_cancel,
                                style: const TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Flexible(
                          child: Row(children: [
                            Flexible(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: TextField(
                                  focusNode: _chatFocusNode,
                                  controller: _chatController,
                                  onTap: () {
                                    if (!_chatFocusNode.hasFocus) {
                                      setState(
                                          () {}); // Fixes initial focus bug
                                    }
                                  },
                                  keyboardType: TextInputType.multiline,
                                  maxLines: _chatFocusNode.hasFocus ? 4 : 1,
                                  minLines: 1,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!
                                        .type_a_msg,
                                    fillColor:
                                        const Color.fromRGBO(227, 180, 226, 1),
                                    filled: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                if (_chatController.text.trim().isNotEmpty) {
                                  sendMessage(
                                      name: "",
                                      imgPath: "",
                                      isSelf: true,
                                      message: _chatController.text.trim());
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
                          ]),
                        ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void pickMediaFromGallery() async {
    List<XFile> mediaFiles = await _imagePicker.pickMultipleMedia(
        imageQuality: 75, maxHeight: 1500, maxWidth: 1500);

    if (mediaFiles.isNotEmpty) {
      List<Media> medias = [];

      for (XFile mediaFile in mediaFiles) {
        String mediaPath = mediaFile.path;

        if (mediaPath.isImageFileName) {
          medias.add(Media(type: MediaType.picture, img: mediaPath));
        } else if (mediaPath.isVideoFileName) {
          String thumbnail = (await VideoThumbnail.thumbnailFile(
              video: mediaPath,
              imageFormat: ImageFormat.JPEG,
              maxHeight: 1500,
              maxWidth: 1500,
              quality: 75))!;

          Video vid = Video(thumbnailPath: thumbnail, vidPath: mediaPath);

          medias.add(Media(type: MediaType.video, vid: vid));
        }
      }

      sendMessage(name: "", imgPath: "", isSelf: true, medias: medias);
    }
  }

  final AudioRecorder recorder = AudioRecorder();

  void sendMessage(
      {required String name,
      required String imgPath,
      String? message,
      required bool isSelf,
      List<Media>? medias,
      String? voicePath}) {
    setState(() {
      messages.add(Message(
          name: name,
          imgPath: imgPath,
          message: message,
          isSelf: isSelf,
          medias: medias,
          voicePath: voicePath));

      _listKey.currentState!.insertItem(messages.length - 1,
          duration: const Duration(milliseconds: 400));

      _chatController.clear();
      _chatFocusNode.unfocus();
    });

    Future.delayed(const Duration(milliseconds: 125), () {
      _chatScrollController
          .jumpTo(_chatScrollController.position.maxScrollExtent);
    });
  }

  final ImagePicker _imagePicker = ImagePicker();

  List<Message> messages = [];
}

class MessageCard extends StatelessWidget {
  final Message msg;
  const MessageCard({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.ltr,
        child: msg.isSelf ? myText() : friendText());
  }

  Widget myText() {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: Get.width * 0.80),
        child: Card(
          clipBehavior: Clip.hardEdge,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(
                right: Radius.circular(8), left: Radius.circular(16)),
          ),
          color: const Color.fromRGBO(227, 180, 226, 1),
          child: Padding(
            padding:
                const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                theMessage(),
                const SizedBox(height: 6),
                const Text(
                  "9:45 AM",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                )
              ],
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
            padding:
                const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                theMessage(),
                const SizedBox(height: 6),
                const Text(
                  "9:45 AM",
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                )
              ],
            ),
          ),
        ),
      )
    ]);
  }

  Widget theMessage() {
    if (msg.medias != null) {
      return mediaMessage(medias: msg.medias!);
    } else if (msg.voicePath != null) {
      return VoiceMessage(voice: msg.voicePath!);
    }

    return myBidirectionalText(text: msg.message!);
  }

  Widget mediaMessage({required List<Media> medias}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        medias.length,
        (index) => Column(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 180),
              child: GestureDetector(
                onTap: () => Get.dialog(
                  medias[index].type == MediaType.picture
                      ? GestureDetector(
                          onTap: () => Get.back(),
                          child: pictureView(medias[index].img!),
                        )
                      : MyVideoPlayer(vid: medias[index].vid!),
                ),
                child: Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.hardEdge,
                  child: medias[index].type == MediaType.picture
                      ? pictureView(medias[index].img!)
                      : thumbnailView(medias[index].vid!),
                ),
              ),
            ),
            index == medias.length - 1
                ? const SizedBox()
                : const Divider(color: Colors.black54)
          ],
        ),
      ),
    );
  }

  Widget pictureView(String path) {
    return Image.file(File(path));
  }

  Widget thumbnailView(Video vid) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.file(File(vid.thumbnailPath)),
        const Icon(Icons.play_circle, color: Colors.white, size: 58)
      ],
    );
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

class MyRecordTimeCounter extends StatefulWidget {
  const MyRecordTimeCounter({super.key});

  @override
  State<MyRecordTimeCounter> createState() => _MyRecordTimeCounterState();
}

class _MyRecordTimeCounterState extends State<MyRecordTimeCounter> {
  Duration time = Duration.zero;

  late Timer timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        time += const Duration(seconds: 1);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(MyTools.durationToText(time));
  }

  @override
  void dispose() {
    timer.cancel();

    super.dispose();
  }
}
