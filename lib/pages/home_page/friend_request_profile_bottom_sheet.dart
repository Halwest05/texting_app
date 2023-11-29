import 'package:flutter/material.dart';
import 'package:texting_app/pages/home_page/profile_bottom_sheet.dart';
import 'package:texting_app/tools.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class FriendRequestProfileBottomSheet extends StatelessWidget {
  final MiniProfile profile;
  const FriendRequestProfileBottomSheet({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return ProfileBottomSheetNew(profile: profile, actions: [
      ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () {},
          icon: const Icon(Icons.person_add_alt_rounded),
          label: Text(AppLocalizations.of(context)!.accept)),
      const SizedBox(width: 8),
      OutlinedButton.icon(
          onPressed: () {},
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          icon: const Icon(Icons.person_remove_rounded),
          label: Text(AppLocalizations.of(context)!.reject))
    ]);
  }
}
