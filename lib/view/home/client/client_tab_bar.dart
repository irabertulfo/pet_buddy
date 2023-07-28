import 'package:flutter/material.dart';

class ClientTabBar extends StatefulWidget {
  const ClientTabBar({Key? key}) : super(key: key);

  @override
  ClientTabBarState createState() => ClientTabBarState();
}

class ClientTabBarState extends State<ClientTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              TabBarView(
                controller: _tabController,
                children: [
                  Center(
                    child: Text(
                      "Appointment History",
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ),
                  Center(
                    child: Text(
                      "Appointments",
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ),
                  Center(
                    child: Text(
                      "Chat Bot",
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: FloatingActionButton(
                    onPressed: () {},
                    child: const Icon(Icons.add),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.history_outlined)),
              Tab(icon: Icon(Icons.calendar_month_outlined)),
              Tab(icon: Icon(Icons.chat_bubble_outlined)),
            ],
            indicatorColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
