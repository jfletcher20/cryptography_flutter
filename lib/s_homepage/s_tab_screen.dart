import 'package:flutter/material.dart';

class TabScreen extends StatefulWidget {
  final List<String> tabNames;
  final List<Widget?>? tabIcons;
  final List<Widget> children;
  final bool keepAlive;
  const TabScreen({
    super.key,
    required this.children,
    required this.tabNames,
    this.tabIcons,
    this.keepAlive = true,
  }) : assert(tabNames.length == children.length &&
            (tabIcons == null || tabNames.length == tabIcons.length));

  @override
  State<TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> with SingleTickerProviderStateMixin {
  late TabController tabController;

  List<Widget> get _tabs {
    return List.generate(widget.tabNames.length, (index) {
      return Tab(text: widget.tabNames[index], icon: widget.tabIcons?[index]);
    });
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: widget.children.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          TabBar(controller: tabController, tabs: _tabs),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: widget.children.map((child) => Center(child: child)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
