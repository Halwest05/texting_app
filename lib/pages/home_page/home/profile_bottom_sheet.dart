import 'package:flutter/material.dart';
import 'package:texting_app/tools.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class ProfileBottomSheet extends StatefulWidget {
  final MiniProfile profile;
  const ProfileBottomSheet({super.key, required this.profile});

  @override
  State<ProfileBottomSheet> createState() => _ProfileBottomSheetState();
}

class _ProfileBottomSheetState extends State<ProfileBottomSheet> {
  bool isFav = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 420,
      child: BottomSheet(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
          onClosing: () {},
          enableDrag: false,
          backgroundColor: const Color.fromRGBO(227, 180, 226, 1),
          builder: (context) {
            return Column(children: [
              const SizedBox(height: 20),
              Card(
                  elevation: 4,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  child: Image.asset(widget.profile.imgPath, height: 200)),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(children: [
                  Text(widget.profile.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 3),
                  Text(
                    "ID: ${widget.profile.username!}",
                    style: const TextStyle(color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                  )
                ]),
              ),
              const Divider(color: Colors.black54),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Padding(
                  padding: EdgeInsets.only(
                      left: MyTools.isKurdish ? 0 : 5,
                      right: MyTools.isKurdish ? 5 : 0),
                  child: IconButton(
                      onPressed: () {
                        setState(() {
                          isFav = !isFav;
                        });
                      },
                      icon:
                          Icon(isFav ? Icons.favorite : Icons.favorite_border),
                      color: Colors.pinkAccent,
                      iconSize: isFav ? 36 : 32),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      right: MyTools.isKurdish ? 0 : 16,
                      left: MyTools.isKurdish ? 16 : 0),
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow.shade700),
                          onPressed: () {},
                          icon: const Icon(Icons.message),
                          label: Text(AppLocalizations.of(context)!.message)),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red),
                          icon: const Icon(Icons.person_remove_rounded),
                          label: Text(AppLocalizations.of(context)!.unfriend))
                    ],
                  ),
                )
              ]),
              const Divider(color: Colors.black54),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.block),
                      const SizedBox(width: 6),
                      Text(AppLocalizations.of(context)!.block)
                    ],
                  ),
                ),
              )
            ]);
          }),
    );
  }
}
