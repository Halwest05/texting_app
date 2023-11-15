import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:get/get.dart';
import 'package:texting_app/pages/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String name = "Halwest Mohammed";

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(name, overflow: TextOverflow.ellipsis),
          centerTitle: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20))),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Get.bottomSheet(const SearchBottomSheet(),
                  isScrollControlled: true);
            },
            foregroundColor: Colors.white,
            child: const Icon(Icons.search_rounded)),
        drawer: Drawer(
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: DrawerHeader(
                    padding: const EdgeInsets.only(top: 10),
                    decoration: const BoxDecoration(
                        color: Color.fromRGBO(206, 128, 203, 1)),
                    child: Column(children: [
                      Card(
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Image.asset("assets/images/unknown_person.jpg",
                            height: 85),
                      ),
                      const Text(
                        "Halwest Mohammed",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "hallo05",
                        style: TextStyle(color: Colors.black54),
                      )
                    ])),
              ),
              ListTile(
                  title: Text(AppLocalizations.of(context)!.friends),
                  leading: const Icon(Icons.people_alt_rounded)),
              const Divider(color: Colors.black45),
              ListTile(
                  title: Text(AppLocalizations.of(context)!.friend_requests),
                  leading: const Icon(Icons.person_add)),
              const Divider(color: Colors.black45),
              ListTile(
                  title: Text(AppLocalizations.of(context)!.add_friend),
                  leading: const Icon(Icons.person_add_alt_1)),
              const Divider(color: Colors.black45),
              ListTile(
                  title: Text(AppLocalizations.of(context)!.logout),
                  leading: const Icon(Icons.logout_rounded),
                  onTap: () => showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title:
                                Text(AppLocalizations.of(context)!.are_u_sure),
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
                                  onPressed: () => Get.off(const LoginPage()),
                                  child:
                                      Text(AppLocalizations.of(context)!.yes))
                            ],
                          )))
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentPage,
            onTap: (value) {
              if (value != currentPage) {
                setState(() {
                  currentPage = value;
                });

                _pageController.animateToPage(value,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut);
              }
            },
            items: [
              BottomNavigationBarItem(
                  icon: const Icon(Icons.chat_rounded),
                  label: AppLocalizations.of(context)!.chats),
              BottomNavigationBarItem(
                  icon: const Icon(Icons.people_alt_rounded),
                  label: AppLocalizations.of(context)!.online)
            ]),
        body: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _pageController,
            children: const [ChatsTab(), OnlineTab()]));
  }
}

class SearchBottomSheet extends StatefulWidget {
  const SearchBottomSheet({super.key});

  @override
  State<SearchBottomSheet> createState() => _SearchBottomSheetState();
}

class _SearchBottomSheetState extends State<SearchBottomSheet>
    with TickerProviderStateMixin {
  late final TextEditingController _searchController;
  late final TabController _tabController;

  @override
  void initState() {
    _searchController = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    _searchController.dispose();
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
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  clipBehavior: Clip.antiAlias,
                  child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.search,
                          suffixIcon: IconButton(
                              onPressed: () => _searchController.clear(),
                              icon: const Icon(Icons.clear_rounded)),
                          prefixIcon: const Icon(Icons.search_rounded))),
                ),
              ),
              TabBar(
                  tabs: const [
                    Tab(icon: Icon(Icons.people), text: "Friends"),
                    Tab(icon: Icon(Icons.public_rounded), text: "Global"),
                  ],
                  controller: _tabController,
                  labelColor: Colors.purple,
                  unselectedLabelColor: Colors.black45),
              const Divider(color: Colors.black45),
              Flexible(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: ListView.builder(
                            itemBuilder: (context, index) =>
                                const Column(children: [
                                  FriendTile(),
                                  Divider(
                                    color: Colors.black45,
                                  )
                                ]),
                            itemCount: 5)),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: ListView.builder(
                            itemBuilder: (context, index) =>
                                const Column(children: [
                                  FriendTile(),
                                  Divider(
                                    color: Colors.black45,
                                  )
                                ]),
                            itemCount: 5)),
                  ],
                ),
              )
            ],
          );
        },
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
      ),
    );
  }
}

class FriendTile extends StatelessWidget {
  const FriendTile({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Card(
                  shape: const CircleBorder(),
                  clipBehavior: Clip.hardEdge,
                  child: Image.asset("assets/images/unknown_person.jpg",
                      height: 60)),
            ),
            const SizedBox(width: 8),
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Halwest Mohammed", style: TextStyle(fontSize: 16)),
                SizedBox(height: 4),
                Row(
                  children: [
                    SizedBox(width: 5),
                    Text("Hallo", style: TextStyle(color: Colors.black54))
                  ],
                )
              ],
            ),
            Expanded(
              child: Align(
                alignment:
                    isKurdish ? Alignment.centerLeft : Alignment.centerRight,
                child: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: IconButton(
                        color: Colors.purple,
                        onPressed: () {},
                        icon: const Icon(Icons.chat))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get isKurdish => Get.locale!.languageCode == "fa" ? true : false;
}

class ChatsTab extends StatelessWidget {
  const ChatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        return await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
          padding: const EdgeInsets.only(top: 25, left: 12, right: 12),
          itemBuilder: (context, index) {
            return const Column(
              children: [
                ChatsTile(),
                Divider(color: Colors.black45),
              ],
            );
          },
          itemCount: 10),
    );
  }
}

class ChatsTile extends StatelessWidget {
  const ChatsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: isKurdish ? 0 : 8, right: isKurdish ? 8 : 0),
              child: Card(
                  shape: const CircleBorder(),
                  clipBehavior: Clip.hardEdge,
                  child: Image.asset("assets/images/unknown_person.jpg",
                      height: 60)),
            ),
            const SizedBox(width: 8),
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Halwest Mohammed", style: TextStyle(fontSize: 16)),
                SizedBox(height: 4),
                Row(
                  children: [
                    SizedBox(width: 5),
                    Text("Hallo", style: TextStyle(color: Colors.black54))
                  ],
                )
              ],
            ),
            Expanded(
              child: Align(
                alignment:
                    isKurdish ? Alignment.centerLeft : Alignment.centerRight,
                child: const Padding(
                  padding: EdgeInsets.only(right: 5),
                  child:
                      Text("5m ago", style: TextStyle(color: Colors.black54)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  bool get isKurdish => Get.locale!.languageCode == "fa" ? true : false;
}

class OnlineTab extends StatelessWidget {
  const OnlineTab({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        return await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
          padding: const EdgeInsets.only(top: 25, left: 12, right: 12),
          itemBuilder: (context, index) {
            return const Column(
              children: [OnlineTile(), Divider(color: Colors.black45)],
            );
          },
          itemCount: 10),
    );
  }
}

class OnlineTile extends StatelessWidget {
  const OnlineTile({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Card(
                  shape: const CircleBorder(),
                  clipBehavior: Clip.hardEdge,
                  child: Image.asset("assets/images/unknown_person.jpg",
                      height: 60)),
            ),
            const SizedBox(width: 6),
            const Text("Halwest Mohammed", style: TextStyle(fontSize: 17)),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    right: isKurdish ? 0 : 12, left: isKurdish ? 12 : 0),
                child: Align(
                    alignment: isKurdish
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Container(
                        height: 12,
                        width: 12,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.green))),
              ),
            )
          ],
        ),
      ),
    );
  }

  bool get isKurdish => Get.locale!.languageCode == "fa" ? true : false;
}
