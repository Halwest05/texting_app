import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:texting_app/pages/home_page/profile_bottom_sheet.dart';
import 'package:texting_app/tools.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class FriendProfileBottomSheet extends StatelessWidget {
  final MiniProfile profile;
  const FriendProfileBottomSheet({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return ProfileBottomSheetNew(profile: profile, actions: [
      ElevatedButton.icon(
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.yellow.shade700),
          onPressed: () {
            Get.back(result: "message");
          },
          icon: const Icon(Icons.message),
          label: Text(AppLocalizations.of(context)!.message)),
      const SizedBox(width: 8),
      OutlinedButton.icon(
          onPressed: () async {
            String? res = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(AppLocalizations.of(context)!.are_u_sure),
                content:
                    Text(AppLocalizations.of(context)!.do_u_wanna_unfriend),
                actions: [
                  TextButton(
                      onPressed: () => Get.back(),
                      child: Text(AppLocalizations.of(context)!.no)),
                  TextButton(
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: () => Get.back(result: "unfriend"),
                      child: Text(AppLocalizations.of(context)!.yes))
                ],
              ),
            );

            if (res == "unfriend") {
              Get.back(result: "unfriend");
            }
          },
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          icon: const Icon(Icons.person_remove_rounded),
          label: Text(AppLocalizations.of(context)!.unfriend))
    ]);
  }
}
