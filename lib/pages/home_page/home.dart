import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
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
  late final PageController _homePageController;

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  late final Timer onlineTimer;

  @override
  void initState() {
    super.initState();

    _homePageController = PageController();

    onlineTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (FirebaseAuth.instance.currentUser != null) {
        if (FirebaseAuth.instance.currentUser!.uid == widget.user.uid) {
          _database
              .ref("online")
              .child(widget.user.uid)
              .set(DateTime.now().millisecondsSinceEpoch);

          return;
        }
      }

      timer.cancel();
    });
  }

  @override
  void dispose() {
    _homePageController.dispose();
    onlineTimer.cancel();

    super.dispose();
  }

  int currentHomePage = 0;
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          appBar: AppBar(
            title: Builder(builder: (context) {
              late String appbarText;

              switch (currentPage) {
                case 0:
                  appbarText = widget.user.name.value;
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
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(20))),
          ),
          floatingActionButton: currentPage == 0 && currentHomePage == 0
              ? FloatingActionButton(
                  onPressed: () {
                    Get.bottomSheet(SearchBottomSheet(user: widget.user),
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
                                  child: MyNetworkImage(
                                      src: widget.user.imgPath.value,
                                      fit: BoxFit.contain),
                                  onTap: () => Get.back(),
                                ),
                              ),
                              child: Card(
                                clipBehavior: Clip.antiAlias,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: MyNetworkImage(
                                    src: widget.user.imgPath.value, height: 85),
                              ),
                            ),
                            Text(
                              widget.user.name.value,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.user.username.value,
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
                    leading: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: _firestore
                            .collection("users")
                            .doc(widget.user.uid)
                            .collection("friendRequests")
                            .snapshots(),
                        builder: (context, snapshot) {
                          int requestCount = 0;

                          if (snapshot.data != null) {
                            requestCount = snapshot.data!.size;
                          }

                          return Badge(
                              isLabelVisible: requestCount > 0 ? true : false,
                              backgroundColor: Colors.red,
                              alignment: MyTools.isKurdish
                                  ? Alignment.topLeft
                                  : Alignment.topRight,
                              offset: MyTools.isKurdish
                                  ? const Offset(-3, -8)
                                  : const Offset(8, -5),
                              label: Text(requestCount.toString()),
                              child: const Icon(Icons.person_add));
                        }),
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
                              title: Text(
                                  AppLocalizations.of(context)!.are_u_sure),
                              content: Text(AppLocalizations.of(context)!
                                  .do_u_wanna_logout),
                              actions: [
                                TextButton(
                                    onPressed: () => Get.back(),
                                    child:
                                        Text(AppLocalizations.of(context)!.no)),
                                TextButton(
                                    style: TextButton.styleFrom(
                                        foregroundColor: Colors.red),
                                    onPressed: () async {
                                      await FirebaseAuth.instance.signOut();

                                      Get.offAll(() => const LoginPage());
                                    },
                                    child:
                                        Text(AppLocalizations.of(context)!.yes))
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
                  return HomePage(
                      homePageController: _homePageController,
                      uid: widget.user.uid);
                case 1:
                  return FriendsPage(uid: widget.user.uid);
                case 2:
                  return FriendRequestsPage(uid: widget.user.uid);
                case 3:
                  return SettingsPage(user: widget.user);
                default:
                  return Container();
              }
            },
          ),
        ));
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
}
