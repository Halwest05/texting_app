import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:texting_app/pages/home_page/profile_bottom_sheet.dart';
import 'package:texting_app/tools.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class StrangerProfileBottomSheet extends StatelessWidget {
  final MiniProfile profile;
  const StrangerProfileBottomSheet({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return ProfileBottomSheetNew(profile: profile, actions: [
      ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent),
          onPressed: () {},
          icon: const Icon(Icons.person_add_rounded),
          label: Text(AppLocalizations.of(context)!.send_request)),
      const SizedBox(width: 8),
      OutlinedButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: profile.username!));

            Get.showSnackbar(GetSnackBar(
              message: AppLocalizations.of(context)!.copied_to_clipbrd,
              mainButton: TextButton(
                  onPressed: () => Get.closeAllSnackbars(),
                  child: Text(AppLocalizations.of(context)!.ok)),
              duration: const Duration(seconds: 3),
              animationDuration: const Duration(milliseconds: 400),
            ));
          },
          style: OutlinedButton.styleFrom(foregroundColor: Colors.deepPurple),
          icon: const Icon(Icons.copy),
          label: Text(AppLocalizations.of(context)!.copy_id))
    ]);
  }
}
