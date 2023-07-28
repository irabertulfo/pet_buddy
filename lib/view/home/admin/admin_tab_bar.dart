import 'package:flutter/material.dart';
import 'package:pet_buddy/view/home/admin/appointment_calendar.dart/appointment_calendar.dart';

class AdminTabBar extends StatefulWidget {
  const AdminTabBar({Key? key}) : super(key: key);

  @override
  AdminTabBarState createState() => AdminTabBarState();
}

class AdminTabBarState extends State<AdminTabBar>
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
                      "Records Management",
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ),
                  const Center(
                    child: AppointmentCalendar(),
                  ),
                  Center(
                    child: Text(
                      "Transaction History",
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ),
                ],
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
              Tab(icon: Icon(Icons.receipt_outlined)),
              Tab(icon: Icon(Icons.calendar_month_outlined)),
              Tab(icon: Icon(Icons.history_outlined)),
            ],
            indicatorColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
