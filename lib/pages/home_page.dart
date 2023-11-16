import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:get/get.dart';
import 'package:texting_app/pages/login_page.dart';
import 'package:texting_app/tools.dart';

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
                  tabs: const [
                    Tab(icon: Icon(Icons.people), text: "Friends"),
                    Tab(icon: Icon(Icons.public_rounded), text: "Global"),
                  ],
                  controller: _tabController,
                  labelColor: Colors.purple,
                  unselectedLabelColor: Colors.black45),
              Flexible(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    FriendsTabBottomSheet(),
                    GlobalTabBottomSheet()
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

class FriendsTabBottomSheet extends StatefulWidget {
  const FriendsTabBottomSheet({super.key});

  @override
  State<FriendsTabBottomSheet> createState() => _FriendsTabBottomSheetState();
}

class _FriendsTabBottomSheetState extends State<FriendsTabBottomSheet> {
  late final TextEditingController _searchController;

  static List<MiniProfile> profiles = [
    MiniProfile(
        name: "Halmat Mohammed",
        imgPath: MyTools.testPropic1,
        message: "ajsdkhsakjdsaasdjksa"),
    MiniProfile(
        name: "Hallo Ahmed",
        imgPath: MyTools.testPropic2,
        message: "ajsdkhsakjdsaq9w8diok"),
    MiniProfile(
        name: "Halkawt Mahmood",
        imgPath: MyTools.testPropic3,
        message: "ajsdkhsakjdsawdhjqkd"),
    MiniProfile(
        name: "Halwest Hamamin",
        imgPath: MyTools.testPropic1,
        message: "ajsdkhsakjdsa19i2ijks"),
    MiniProfile(
        name: "Hallsho Mlshor",
        imgPath: MyTools.testPropic4,
        message: "n8e29es28y71s182u"),
    MiniProfile(
        name: "Halgwrd Karwan",
        imgPath: MyTools.testPropic3,
        message: "ajsdkhsakjdsaas9duiasojd")
  ];

  List<MiniProfile> filteredProfiles = [];

  @override
  void initState() {
    _searchController = TextEditingController();

    _searchController.addListener(() {
      setState(() {
        filteredProfiles = profiles
            .where((element) => element.name.startsWith(_searchController.text))
            .toList();
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
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
        const Divider(color: Colors.black45),
        filteredProfiles.isEmpty && _searchController.text.isNotEmpty
            ? const Expanded(
                child: Center(
                  child: Text("No people found..."),
                ),
              )
            : Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ListView.builder(
                      itemBuilder: (context, index) => Column(children: [
                            FriendTabBottomSheetTile(
                                profile: _searchController.text.isEmpty
                                    ? profiles[index]
                                    : filteredProfiles[index]),
                            const Divider(color: Colors.black45)
                          ]),
                      itemCount: _searchController.text.isEmpty
                          ? profiles.length
                          : filteredProfiles.length),
                ),
              )
      ],
    );
  }
}

class GlobalTabBottomSheet extends StatefulWidget {
  const GlobalTabBottomSheet({super.key});

  @override
  State<GlobalTabBottomSheet> createState() => _GlobalTabBottomSheetState();
}

class _GlobalTabBottomSheetState extends State<GlobalTabBottomSheet> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    _searchController = TextEditingController();

    _searchController.addListener(() {
      setState(() {
        filteredProfiles = profiles
            .where((element) => element.name.startsWith(_searchController.text))
            .toList();
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  static List<MiniProfile> profiles = [
    MiniProfile(
        name: "Ahmed Mohammed",
        imgPath: MyTools.testPropic2,
        message: "ajsdkhsakjdsaasdjksa"),
    MiniProfile(
        name: "Karwan Mhaiadin",
        imgPath: MyTools.testPropic3,
        message: "ajsdkhsakjdsaq9w8diok"),
    MiniProfile(
        name: "Abduljabar farooq",
        imgPath: MyTools.testPropic4,
        message: "ajsdkhsakjdsawdhjqkd"),
    MiniProfile(
        name: "Halwest Hamamin",
        imgPath: MyTools.testPropic2,
        message: "ajsdkhsakjdsa19i2ijks"),
    MiniProfile(
        name: "Hallsho Mlshor",
        imgPath: MyTools.testPropic4,
        message: "n8e29es28y71s182u"),
    MiniProfile(
        name: "Karzhin Tanzhin",
        imgPath: MyTools.testPropic1,
        message: "ajsdkhsakjdsaas9duiasojd")
  ];

  List<MiniProfile> filteredProfiles = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
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
        const Divider(color: Colors.black45),
        filteredProfiles.isEmpty && _searchController.text.isNotEmpty
            ? const Expanded(
                child: Center(
                  child: Text("No people found..."),
                ),
              )
            : Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ListView.builder(
                      itemBuilder: (context, index) => Column(children: [
                            GlobalTabBottomSheetTile(
                                profile: _searchController.text.isEmpty
                                    ? profiles[index]
                                    : filteredProfiles[index]),
                            const Divider(color: Colors.black45)
                          ]),
                      itemCount: _searchController.text.isEmpty
                          ? profiles.length
                          : filteredProfiles.length),
                ),
              )
      ],
    );
  }
}

class FriendTabBottomSheetTile extends StatelessWidget {
  const FriendTabBottomSheetTile({super.key, required this.profile});

  final MiniProfile profile;

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
                  left: MyTools.isKurdish ? 0 : 8,
                  right: MyTools.isKurdish ? 8 : 0),
              child: Card(
                  shape: const CircleBorder(),
                  clipBehavior: Clip.hardEdge,
                  child: Image.asset(profile.imgPath, height: 60)),
            ),
            const SizedBox(width: 8),
            Text(profile.name, style: const TextStyle(fontSize: 16)),
            Expanded(
              child: Align(
                alignment: MyTools.isKurdish
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Padding(
                    padding: EdgeInsets.only(
                        right: MyTools.isKurdish ? 0 : 5,
                        left: MyTools.isKurdish ? 5 : 0),
                    child: IconButton(
                      color: Colors.purple,
                      onPressed: () {},
                      icon: const Icon(Icons.chat),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GlobalTabBottomSheetTile extends StatelessWidget {
  final MiniProfile profile;
  const GlobalTabBottomSheetTile({super.key, required this.profile});

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
                  left: MyTools.isKurdish ? 0 : 8,
                  right: MyTools.isKurdish ? 8 : 0),
              child: Card(
                  shape: const CircleBorder(),
                  clipBehavior: Clip.hardEdge,
                  child: Image.asset(profile.imgPath, height: 60)),
            ),
            const SizedBox(width: 8),
            Text(profile.name, style: const TextStyle(fontSize: 16)),
            Expanded(
              child: Align(
                alignment: MyTools.isKurdish
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Padding(
                    padding: EdgeInsets.only(
                        right: MyTools.isKurdish ? 0 : 5,
                        left: MyTools.isKurdish ? 5 : 0),
                    child: IconButton(
                        color: Colors.purple,
                        onPressed: () {},
                        icon: const Icon(Icons.person_add_alt_1))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatsTab extends StatelessWidget {
  const ChatsTab({super.key});

  static List<MiniProfile> profiles = [
    MiniProfile(
        name: "Halmat Mohammed",
        imgPath: MyTools.testPropic1,
        message: "ajsdkhsakjdsaasdjksa"),
    MiniProfile(
        name: "Hallo Ahmed",
        imgPath: MyTools.testPropic2,
        message: "ajsdkhsakjdsaq9w8diok"),
    MiniProfile(
        name: "Halkawt Mahmood",
        imgPath: MyTools.testPropic3,
        message: "ajsdkhsakjdsawdhjqkd"),
    MiniProfile(
        name: "Halwest Hamamin",
        imgPath: MyTools.testPropic1,
        message: "ajsdkhsakjdsa19i2ijks"),
    MiniProfile(
        name: "Hallsho Mlshor",
        imgPath: MyTools.testPropic4,
        message: "n8e29es28y71s182u"),
    MiniProfile(
        name: "Halgwrd Karwan",
        imgPath: MyTools.testPropic3,
        message: "ajsdkhsakjdsaas9duiasojd")
  ];

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        return await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
          padding: const EdgeInsets.only(top: 25, left: 12, right: 12),
          itemBuilder: (context, index) {
            return Column(
              children: [
                ChatsTile(profile: profiles[index]),
                const Divider(color: Colors.black45),
              ],
            );
          },
          itemCount: profiles.length),
    );
  }
}

class ChatsTile extends StatelessWidget {
  const ChatsTile({super.key, required this.profile});

  final MiniProfile profile;

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
                  left: MyTools.isKurdish ? 0 : 8,
                  right: MyTools.isKurdish ? 8 : 0),
              child: Card(
                shape: const CircleBorder(),
                clipBehavior: Clip.hardEdge,
                child: Image.asset(profile.imgPath, height: 60),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.name, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const SizedBox(width: 5),
                    Text(profile.message,
                        style: const TextStyle(color: Colors.black54))
                  ],
                )
              ],
            ),
            Expanded(
              child: Align(
                alignment: MyTools.isKurdish
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(
                      right: MyTools.isKurdish ? 0 : 5,
                      left: MyTools.isKurdish ? 5 : 0),
                  child: const Text("5m ago",
                      style: TextStyle(color: Colors.black54)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class OnlineTab extends StatelessWidget {
  const OnlineTab({super.key});

  static List<MiniProfile> profiles = [
    MiniProfile(
        name: "Hallo Ahmed",
        imgPath: MyTools.testPropic2,
        message: "ajsdkhsakjdsaq9w8diok"),
    MiniProfile(
        name: "Halkawt Mahmood",
        imgPath: MyTools.testPropic3,
        message: "ajsdkhsakjdsawdhjqkd"),
    MiniProfile(
        name: "Hallsho Mlshor",
        imgPath: MyTools.testPropic4,
        message: "n8e29es28y71s182u"),
  ];

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        return await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
          padding: const EdgeInsets.only(top: 25, left: 12, right: 12),
          itemBuilder: (context, index) {
            return Column(
              children: [
                OnlineTile(profile: profiles[index]),
                const Divider(color: Colors.black45)
              ],
            );
          },
          itemCount: profiles.length),
    );
  }
}

class OnlineTile extends StatelessWidget {
  const OnlineTile({super.key, required this.profile});

  final MiniProfile profile;

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
                  left: MyTools.isKurdish ? 0 : 8,
                  right: MyTools.isKurdish ? 8 : 0),
              child: Card(
                  shape: const CircleBorder(),
                  clipBehavior: Clip.hardEdge,
                  child: Image.asset(profile.imgPath, height: 60)),
            ),
            const SizedBox(width: 6),
            Text(profile.name, style: const TextStyle(fontSize: 17)),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    right: MyTools.isKurdish ? 0 : 12,
                    left: MyTools.isKurdish ? 12 : 0),
                child: Align(
                    alignment: MyTools.isKurdish
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
}
