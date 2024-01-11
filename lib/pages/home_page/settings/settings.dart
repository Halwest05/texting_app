import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:get/get.dart';
import 'package:texting_app/main.dart';
import 'package:texting_app/tools.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ListTile(
        title: Text(AppLocalizations.of(context)!.change_username),
        leading: const Icon(Icons.person_rounded),
        subtitle: Text(AppLocalizations.of(context)!.changes_the_username),
        onTap: () {},
      ),
      const Divider(color: Colors.black45),
      ListTile(
        title: Text(AppLocalizations.of(context)!.change_password),
        leading: const Icon(Icons.lock_rounded),
        subtitle: Text(AppLocalizations.of(context)!.changes_the_password),
        onTap: () {},
      ),
      const Divider(color: Colors.black45),
      ListTile(
        title: Text(AppLocalizations.of(context)!.change_pfp),
        leading: const Icon(Icons.image),
        subtitle: Text(AppLocalizations.of(context)!.changes_the_pfp),
        onTap: () {},
      ),
      const Divider(color: Colors.black45),
      ListTile(
        title: Text(AppLocalizations.of(context)!.change_lang),
        leading: const Icon(Icons.public_rounded),
        subtitle: Text(AppLocalizations.of(context)!.changes_the_lang),
        onTap: () {
          Get.to(() => const ChangeLanguagePage());
        },
      ),
      const Divider(color: Colors.black45),
      ListTile(
        title: Text(AppLocalizations.of(context)!.delete_acc),
        leading: const Icon(Icons.person_remove_alt_1_rounded),
        subtitle: Text(AppLocalizations.of(context)!.deletes_the_acc),
        onTap: () {},
      ),
    ]);
  }
}

class ChangeLanguagePage extends StatefulWidget {
  const ChangeLanguagePage({super.key});

  @override
  State<ChangeLanguagePage> createState() => _ChangeLanguagePageState();
}

class _ChangeLanguagePageState extends State<ChangeLanguagePage> {
  @override
  Widget build(BuildContext context) {
    int currentValue = MyTools.isKurdish ? 1 : 0;

    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Text(AppLocalizations.of(context)!.change_lang)),
        body: Column(children: [
          ListTile(
              title: const Text(
                "English",
                style: TextStyle(fontFamily: "Roboto"),
              ),
              leading: Card(
                clipBehavior: Clip.antiAlias,
                elevation: 3,
                child: Image.asset(
                  "assets/images/us_flag.png",
                  height: 32,
                ),
              ),
              trailing: Radio(
                value: currentValue,
                groupValue: 0,
                onChanged: (value) {},
              ),
              onTap: () => MainApp.changeToEnglish()),
          const Divider(color: Colors.black45),
          ListTile(
              title: const Text(
                "کوردی",
                style: TextStyle(fontFamily: "GretaTextArabic"),
              ),
              leading: Card(
                clipBehavior: Clip.antiAlias,
                elevation: 3,
                child: Image.asset(
                  "assets/images/kurdistan_flag.png",
                  height: 32,
                ),
              ),
              trailing: Radio(
                value: currentValue,
                groupValue: 1,
                onChanged: (value) {},
              ),
              onTap: () => MainApp.changeToKurdish()),
          const Divider(color: Colors.black45)
        ]));
  }
}
