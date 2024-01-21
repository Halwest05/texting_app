import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:texting_app/pages/home_page/home/find_people_bottom_sheet_tabs/friends_tab.dart';
import 'package:texting_app/pages/home_page/home/find_people_bottom_sheet_tabs/global_tab.dart';
import 'package:texting_app/tools.dart';

class SearchBottomSheet extends StatefulWidget {
  final FirestoreUser user;
  const SearchBottomSheet({super.key, required this.user});

  @override
  State<SearchBottomSheet> createState() => _SearchBottomSheetState();
}

class _SearchBottomSheetState extends State<SearchBottomSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height * 0.72,
      child: BottomSheet(
        backgroundColor: const Color.fromRGBO(227, 180, 226, 1),
        onClosing: () {},
        enableDrag: false,
        builder: (context) {
          return Column(
            children: [
              const SizedBox(height: 10),
              TabBar(
                  tabs: [
                    Tab(
                        icon: const Icon(Icons.people),
                        text: AppLocalizations.of(context)!.friends),
                    Tab(
                        icon: const Icon(Icons.public_rounded),
                        text: AppLocalizations.of(context)!.global),
                  ],
                  controller: _tabController,
                  labelColor: Colors.purple,
                  unselectedLabelColor: Colors.black45),
              Flexible(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    FriendsTabBottomSheet(me: widget.user),
                    GlobalTabBottomSheet(me: widget.user)
                  ],
                ),
              )
            ],
          );
        },
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      ),
    );
  }
}
