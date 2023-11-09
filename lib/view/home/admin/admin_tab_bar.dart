import 'package:flutter/material.dart';
import 'package:pet_buddy/view/home/admin/appointment_calendar/appointment_calendar.dart';
import 'package:pet_buddy/view/home/admin/inventory/inventory.dart';
import 'package:pet_buddy/view/home/admin/records_management/records_management_screen.dart';

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
                children: const [
                  RecordsManagementScreen(),
                  Center(child: AppointmentCalendar()),
                  InventoryScreen(),
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
              Tab(icon: Icon(Icons.inventory_2)),
            ],
            indicatorColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
