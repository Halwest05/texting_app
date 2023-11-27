import 'package:flutter/material.dart';
import 'package:texting_app/tools.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class FriendRequestProfileBottomSheet extends StatefulWidget {
  final MiniProfile profile;
  const FriendRequestProfileBottomSheet({super.key, required this.profile});

  @override
  State<FriendRequestProfileBottomSheet> createState() =>
      _FriendRequestProfileBottomSheetState();
}

class _FriendRequestProfileBottomSheetState
    extends State<FriendRequestProfileBottomSheet> {
  bool isFav = false;
  int favCount = 0;

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
                      left: MyTools.isKurdish ? 0 : 12,
                      right: MyTools.isKurdish ? 12 : 0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    onTap: () {
                      if (isFav) {
                        favCount--;
                      } else {
                        favCount++;
                      }

                      setState(() {
                        isFav = !isFav;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 2),
                      child: Column(
                        children: [
                          isFav
                              ? const Icon(Icons.favorite,
                                  color: Colors.pinkAccent, size: 36)
                              : const Icon(Icons.favorite_border,
                                  color: Colors.pinkAccent, size: 32),
                          Text(favCount.toString())
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      right: MyTools.isKurdish ? 0 : 16,
                      left: MyTools.isKurdish ? 16 : 0),
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          onPressed: () {},
                          icon: const Icon(Icons.person_add_alt_rounded),
                          label: Text(AppLocalizations.of(context)!.accept)),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red),
                          icon: const Icon(Icons.person_remove_rounded),
                          label: Text(AppLocalizations.of(context)!.reject))
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
