import 'package:flutter/material.dart';
import 'package:texting_app/tools.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

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
    MiniProfile(name: "Ahmed Mohammed", imgPath: MyTools.testPropic2),
    MiniProfile(name: "Karwan Mhaiadin", imgPath: MyTools.testPropic3),
    MiniProfile(name: "Abduljabar farooq", imgPath: MyTools.testPropic4),
    MiniProfile(name: "Halwest Hamamin", imgPath: MyTools.testPropic2),
    MiniProfile(name: "Hallsho Mlshor", imgPath: MyTools.testPropic4),
    MiniProfile(name: "Karzhin Tanzhin", imgPath: MyTools.testPropic1)
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
            ? Expanded(
                child: Center(
                  child: Text(AppLocalizations.of(context)!.no_ppl_found),
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
            Expanded(
                child: Text(profile.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16))),
            Align(
              alignment: MyTools.isKurdish
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Padding(
                  padding: EdgeInsets.only(
                      right: MyTools.isKurdish ? 0 : 5,
                      left: MyTools.isKurdish ? 5 : 0),
                  child: IconButton(
                      color: Colors.purple,
                      iconSize: 28,
                      onPressed: () {},
                      icon: const Icon(Icons.person_add_alt_1))),
            ),
          ],
        ),
      ),
    );
  }
}
