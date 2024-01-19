import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:get/get.dart';
import 'package:texting_app/pages/home_page/friend_requests/friend_requests_page.dart';
import 'package:texting_app/pages/home_page/friends/friends_page.dart';
import 'package:texting_app/pages/home_page/home/home_page.dart';
import 'package:texting_app/pages/home_page/home/find_people_bottom_sheet.dart';
import 'package:texting_app/pages/home_page/settings/settings.dart';
import 'package:texting_app/pages/login_page.dart';
import 'package:texting_app/tools.dart';

class Home extends StatefulWidget {
  final FirestoreUser user;
  const Home({super.key, required this.user});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String name;

  late final PageController _homePageController;

  @override
  void initState() {
    super.initState();

    _homePageController = PageController();
    name = widget.user.name;
  }

  @override
  void dispose() {
    _homePageController.dispose();

    super.dispose();
  }

  int currentHomePage = 0;
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Builder(builder: (context) {
          late String appbarText;

          switch (currentPage) {
            case 0:
              appbarText = name;
              break;
            case 1:
              appbarText = AppLocalizations.of(context)!.friends;
              break;
            case 2:
              appbarText = AppLocalizations.of(context)!.friend_requests;
              break;
            case 3:
              appbarText = AppLocalizations.of(context)!.settings;
              break;
          }

          return Text(appbarText, overflow: TextOverflow.ellipsis);
        }),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      floatingActionButton: currentPage == 0 && currentHomePage == 0
          ? FloatingActionButton(
              onPressed: () {
                Get.bottomSheet(const SearchBottomSheet(),
                    isScrollControlled: true);
              },
              foregroundColor: Colors.white,
              child: const Icon(Icons.search_rounded),
            )
          : null,
      drawer: Drawer(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: DrawerHeader(
                padding: const EdgeInsets.only(top: 10),
                decoration: const BoxDecoration(
                    color: Color.fromRGBO(206, 128, 203, 1)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => Get.dialog(
                            GestureDetector(
                              child: Image.network(
                                widget.user.imgPath,
                                fit: BoxFit.contain,
                              ),
                              onTap: () => Get.back(),
                            ),
                          ),
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Image.network(
                              widget.user.imgPath,
                              height: 85,
                            ),
                          ),
                        ),
                        Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.user.username,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black54),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
                title: Text(AppLocalizations.of(context)!.home),
                leading: const Icon(Icons.home_rounded),
                onTap: () => setState(() {
                      currentPage = 0;

                      Get.back();
                    })),
            const Divider(color: Colors.black45),
            ListTile(
                title: Text(AppLocalizations.of(context)!.friends),
                leading: const Icon(Icons.people_alt_rounded),
                onTap: () => setState(() {
                      currentPage = 1;
                      currentHomePage = 0;

                      Get.back();
                    })),
            const Divider(color: Colors.black45),
            ListTile(
                title: Text(AppLocalizations.of(context)!.friend_requests),
                leading: Badge(
                    backgroundColor: Colors.red,
                    alignment: MyTools.isKurdish
                        ? Alignment.topLeft
                        : Alignment.topRight,
                    offset: MyTools.isKurdish
                        ? const Offset(-3, -8)
                        : const Offset(8, -5),
                    label: const Text("0"),
                    child: const Icon(Icons.person_add)),
                onTap: () => setState(() {
                      currentPage = 2;
                      currentHomePage = 0;

                      Get.back();
                    })),
            const Divider(color: Colors.black45),
            ListTile(
                title: Text(AppLocalizations.of(context)!.settings),
                leading: const Icon(Icons.settings_rounded),
                onTap: () => setState(() {
                      currentPage = 3;
                      currentHomePage = 0;

                      Get.back();
                    })),
            const Divider(color: Colors.black45),
            ListTile(
                title: Text(AppLocalizations.of(context)!.logout),
                leading: const Icon(Icons.logout_rounded),
                onTap: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: Text(AppLocalizations.of(context)!.are_u_sure),
                          content: Text(
                              AppLocalizations.of(context)!.do_u_wanna_logout),
                          actions: [
                            TextButton(
                                onPressed: () => Get.back(),
                                child: Text(AppLocalizations.of(context)!.no)),
                            TextButton(
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.red),
                                onPressed: () async {
                                  await _auth.signOut();

                                  Get.offAll(() => const LoginPage());
                                },
                                child: Text(AppLocalizations.of(context)!.yes))
                          ],
                        ))),
          ],
        ),
      ),
      bottomNavigationBar: currentPage == 0
          ? BottomNavigationBar(
              currentIndex: currentHomePage,
              onTap: (value) {
                if (value != currentHomePage) {
                  setState(() {
                    currentHomePage = value;
                  });

                  _homePageController.animateToPage(value,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut);
                }
              },
              items: [
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.chat_rounded),
                      label: AppLocalizations.of(context)!.chats),
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.people_alt_rounded),
                      label: AppLocalizations.of(context)!.online)
                ])
          : null,
      body: Builder(
        builder: (context) {
          switch (currentPage) {
            case 0:
              return HomePage(homePageController: _homePageController);
            case 1:
              return const FriendsPage();
            case 2:
              return const FriendRequestsPage(profiles: []);
            case 3:
              return const SettingsPage();
            default:
              return Container();
          }
        },
      ),
    );
  }
}
