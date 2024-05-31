import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class RootNavigation extends StatelessWidget {
  const RootNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final tabPage = TabPage.of(context);
    bool isVertical = MediaQuery.of(context).size.width < 640;

    return Scaffold(
      body: Row(
        children: [
          if (!isVertical)
            NavigationRail(
              selectedIndex: tabPage.index,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.list),
                  label: Text("Orders"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.menu_book),
                  label: Text("Menu"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.show_chart),
                  label: Text("Stats"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.store),
                  label: Text("Info"),
                ),
              ],
              onDestinationSelected: (value) => tabPage.index = value,
              groupAlignment: 0,
              labelType: NavigationRailLabelType.all,
            ),
          if (!isVertical)
            const VerticalDivider(
              width: 1,
              thickness: 1,
            ),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: tabPage.controller,
              children: [
                for (final stack in tabPage.stacks)
                  PageStackNavigator(stack: stack)
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isVertical
          ? NavigationBar(
              selectedIndex: tabPage.index,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.list),
                  label: "Orders",
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu_book),
                  label: "Menu",
                ),
                NavigationDestination(
                  icon: Icon(Icons.show_chart),
                  label: "Stats",
                ),
                NavigationDestination(
                  icon: Icon(Icons.store),
                  label: "Info",
                ),
              ],
              onDestinationSelected: (value) => tabPage.index = value,
            )
          : null,
    );
  }
}
