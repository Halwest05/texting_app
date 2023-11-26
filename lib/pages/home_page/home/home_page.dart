import 'package:flutter/material.dart';
import 'package:texting_app/pages/home_page/home/tabs/chats_tab.dart';
import 'package:texting_app/pages/home_page/home/tabs/online_tab.dart';

class HomePage extends StatefulWidget {
  final PageController homePageController;
  const HomePage({super.key, required this.homePageController});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: widget.homePageController,
        children: const [ChatsTab(), OnlineTab()]);
  }
}