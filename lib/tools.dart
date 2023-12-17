import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

class MyTools {
  static bool get isKurdish => Get.locale!.languageCode == "fa" ? true : false;

  static String testPropic1 = "assets/images/test/1.jpg";
  static String testPropic2 = "assets/images/test/2.jpg";
  static String testPropic3 = "assets/images/test/3.jpg";
  static String testPropic4 = "assets/images/test/4.jpg";

  static String durationToText(Duration duration) {
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds - 60 * minutes;

    String minutesText = minutes.toString().length == 1
        ? "0${minutes.toString()}"
        : minutes.toString();
    String secondsText = seconds.toString().length == 1
        ? "0${seconds.toString()}"
        : seconds.toString();
    return "$minutesText:$secondsText";
  }
}

class MiniProfile {
  final String name;
  final String? username;
  final String? message;
  final String imgPath;

  const MiniProfile(
      {required this.name, required this.imgPath, this.message, this.username});
}

class Message {
  final String name;
  final String? message;
  final String imgPath;
  final bool isSelf;
  final List<Media>? medias;
  final String? voicePath;

  const Message(
      {required this.name,
      required this.imgPath,
      this.message,
      required this.isSelf,
      this.medias,
      this.voicePath});
}

class VoiceMessage extends StatefulWidget {
  final String voice;
  const VoiceMessage({super.key, required this.voice});

  @override
  State<VoiceMessage> createState() => _VoiceMessageState();
}

class _VoiceMessageState extends State<VoiceMessage> {
  late final AudioPlayer audioPlayer;

  @override
  void initState() {
    super.initState();

    audioPlayer = AudioPlayer();

    audioPlayer
        .setFilePath(widget.voice)
        .then((value) => setState(() => voiceDuration = value));

    audioPlayer.positionStream.listen((event) {
      if (voiceDuration != null) {
        bool isFinished = event.inMilliseconds == voiceDuration!.inMilliseconds;

        if (isFinished) {
          audioPlayer.seek(Duration.zero);
          pauseVoice();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: audioPlayer.positionStream,
        builder: (context, snapshot) {
          return voiceWidget(position: snapshot.data);
        });
  }

  Duration? voiceDuration;
  bool isPlaying = false;

  Widget voiceWidget({Duration? position}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            voiceDuration == null
                ? const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                        )),
                  )
                : InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => isPlaying ? pauseVoice() : playVoice(),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.purple),
                    )),
            Theme(
              data: Theme.of(context).copyWith(
                  sliderTheme: const SliderThemeData(
                      trackHeight: 1,
                      thumbShape:
                          RoundSliderThumbShape(enabledThumbRadius: 7))),
              child: SizedBox(
                height: 20,
                child: Slider(
                  value: voiceDuration == null
                      ? 0
                      : position != null
                          ? position.inMilliseconds /
                              voiceDuration!.inMilliseconds
                          : 0,
                  onChanged: voiceDuration == null
                      ? null
                      : (value) {
                          audioPlayer.seek(Duration(
                              milliseconds:
                                  (voiceDuration!.inMilliseconds * value)
                                      .round()));
                        },
                  onChangeStart: (value) {
                    pauseVoice();
                  },
                  onChangeEnd: (value) {
                    playVoice();
                  },
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 24),
          child: durationText(duration: voiceDuration, position: position),
        )
      ],
    );
  }

  void playVoice() {
    audioPlayer.play();

    setState(() {
      isPlaying = true;
    });
  }

  void pauseVoice() {
    audioPlayer.pause();

    setState(() {
      isPlaying = false;
    });
  }

  Widget durationText({Duration? duration, Duration? position}) {
    String voiceDurationText = "00:00";
    String voicePositionText = "00:00";

    if (duration != null) {
      voiceDurationText = MyTools.durationToText(duration);
    }
    if (position != null) {
      voicePositionText = MyTools.durationToText(position);
    }
    String durationText = "$voiceDurationText / $voicePositionText";

    return Text(durationText,
        style: const TextStyle(color: Colors.black54, fontSize: 12));
  }

  @override
  void dispose() {
    audioPlayer.dispose();

    super.dispose();
  }
}

class Video {
  final String vidPath;
  final String thumbnailPath;

  const Video({required this.thumbnailPath, required this.vidPath});
}

class Media {
  final MediaType type;
  final String? img;
  final Video? vid;

  const Media({required this.type, this.img, this.vid});
}

enum MediaType { video, picture }

class MyVideoPlayer extends StatefulWidget {
  final Video vid;
  const MyVideoPlayer({super.key, required this.vid});

  @override
  State<MyVideoPlayer> createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoPlayer> {
  late VideoPlayerController _controller;
  late Future<void> initFuture;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.file(File(widget.vid.vidPath));
    initFuture = _controller.initialize();

    _controller.play();

    _controller.addListener(() {
      if (_controller.value.isCompleted) {
        _controller.pause().then((value) => setState(() {}));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 500),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            FutureBuilder(
                future: initFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          VideoPlayer(_controller),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              AnimatedOpacity(
                                opacity: !goingBackward ? 0 : 1,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                    MyTools.isKurdish
                                        ? Icons.skip_next_rounded
                                        : Icons.skip_previous_rounded,
                                    color:
                                        const Color.fromRGBO(206, 128, 203, 1),
                                    size: 58),
                              ),
                              AnimatedOpacity(
                                opacity: _controller.value.isPlaying || isActing
                                    ? 0
                                    : 1,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                    _controller.value.isPlaying
                                        ? Icons.play_circle
                                        : Icons.pause_circle,
                                    color:
                                        const Color.fromRGBO(206, 128, 203, 1),
                                    size: 58),
                              ),
                              AnimatedOpacity(
                                opacity: !goingForward ? 0 : 1,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                    MyTools.isKurdish
                                        ? Icons.skip_previous_rounded
                                        : Icons.skip_next_rounded,
                                    color:
                                        const Color.fromRGBO(206, 128, 203, 1),
                                    size: 58),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 3,
                                child: GestureDetector(
                                    onTapDown: (details) => onTapDown(details,
                                        action: VideoAction.backward),
                                    onTapUp: onTapUp),
                              ),
                              Flexible(
                                flex: 5,
                                child: GestureDetector(
                                  onTap: () async {
                                    _controller.value.isPlaying
                                        ? await _controller.pause()
                                        : await _controller.play();

                                    setState(() {});
                                  },
                                ),
                              ),
                              Flexible(
                                flex: 3,
                                child: GestureDetector(
                                  onTapDown: (details) => onTapDown(details,
                                      action: VideoAction.forward),
                                  onTapUp: onTapUp,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  }

                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 100),
                    child: CircularProgressIndicator(),
                  );
                }),
            VideoProgressIndicator(
              _controller,
              allowScrubbing: false,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              colors: const VideoProgressColors(playedColor: Colors.purple),
            ),
          ],
        ),
      ),
    );
  }

  late Timer timer;
  bool isActing = false;

  bool goingForward = false;
  bool goingBackward = false;

  int vidSkipMultiplication = 1;

  void onTapDown(TapDownDetails details, {required VideoAction action}) async {
    await _controller.pause();

    timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (action == VideoAction.backward) {
        _controller.seekTo(_controller.value.position -
            Duration(milliseconds: 200 * vidSkipMultiplication));
      } else {
        _controller.seekTo(_controller.value.position +
            Duration(milliseconds: 200 * vidSkipMultiplication));
      }

      if (vidSkipMultiplication < 7) {
        vidSkipMultiplication++;
      }
    });

    setState(() {
      isActing = true;
      action == VideoAction.forward
          ? goingForward = true
          : goingBackward = true;
    });
  }

  void onTapUp(TapUpDetails details) async {
    timer.cancel();

    await _controller.play();

    setState(() {
      isActing = false;
      goingBackward = false;
      goingForward = false;

      vidSkipMultiplication = 1;
    });
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }
}

enum VideoAction { forward, backward }
