import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'add_schedule_screen.dart';
import 'upload_timetable_screen.dart';
import 'edit_schedule_screen.dart';
import 'login_screen.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List schedules = [];
  List filteredSchedules = [];

  final TextEditingController searchController = TextEditingController();

  Future<void> loadSchedules() async {
    schedules = await ApiService.getSchedules();
    filteredSchedules = List.from(schedules);
    setState(() {});
  }

  void searchSchedules(String query) {
    setState(() {
      filteredSchedules = schedules.where((schedule) {
        final title = schedule["title"].toString().toLowerCase();
        final location = schedule["location"].toString().toLowerCase();
        final date = schedule["event_date"].toString().toLowerCase();

        return title.contains(query.toLowerCase()) ||
            location.contains(query.toLowerCase()) ||
            date.contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> logout() async {
    await ApiService.logout();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    }
  }

  Future<void> deleteSchedule(Map item) async {
    final isRecurring = item["is_recurring"] == 1;
    final groupId = item["recurring_group_id"];

    if (isRecurring && groupId != null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Delete recurring schedule"),
          content: const Text("What do you want to delete?"),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await ApiService.deleteSchedule(item["id"]);
                loadSchedules();
              },
              child: const Text("Only this one"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await ApiService.deleteRecurringGroup(groupId);
                loadSchedules();
              },
              child: const Text("All recurring"),
            ),
          ],
        ),
      );
    } else {
      await ApiService.deleteSchedule(item["id"]);
      loadSchedules();
    }
  }

  @override
  void initState() {
    super.initState();
    loadSchedules();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Widget buildHeroHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2563EB),
            Color(0xFF1D4ED8),
            Color(0xFF0F172A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.notifications_active,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back,",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.82),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ApiService.fullName ?? "User",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Stay ahead of your classes and meetings.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.82),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatsRow() {
    final today = DateTime.now().toString().substring(0, 10);

    final todayCount = schedules.where((schedule) {
      return schedule["event_date"].toString() == today;
    }).length;

    final now = DateTime.now();
    final weekEnd = now.add(const Duration(days: 7));

    final weekCount = schedules.where((schedule) {
      final eventDate = DateTime.parse(schedule["event_date"]);
      return eventDate.isAfter(
            now.subtract(const Duration(days: 1)),
          ) &&
          eventDate.isBefore(weekEnd);
    }).length;

    final recurringCount = schedules.where((schedule) {
      return schedule["is_recurring"] == 1;
    }).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          buildStatCard(
            title: "Total",
            value: schedules.length.toString(),
            icon: Icons.calendar_month,
          ),
          const SizedBox(width: 8),
          buildStatCard(
            title: "Today",
            value: todayCount.toString(),
            icon: Icons.today,
          ),
          const SizedBox(width: 8),
          buildStatCard(
            title: "Week",
            value: weekCount.toString(),
            icon: Icons.view_week,
          ),
          const SizedBox(width: 8),
          buildStatCard(
            title: "Repeats",
            value: recurringCount.toString(),
            icon: Icons.repeat,
          ),
        ],
      ),
    );
  }

  Widget buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xFF2563EB),
              size: 22,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddScheduleScreen(),
                  ),
                );

                loadSchedules();
              },
              icon: const Icon(Icons.add),
              label: const Text("Add"),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UploadTimetableScreen(),
                  ),
                );

                loadSchedules();
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text("AI Upload"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFF2563EB)),
                foregroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CalendarScreen(
                      schedules: schedules,
                    ),
                  ),
                );

                loadSchedules();
              },
              icon: const Icon(Icons.calendar_month),
              label: const Text("Calendar"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFF2563EB)),
                foregroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: searchController,
        decoration: const InputDecoration(
          hintText: "Search by title, date, or location...",
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: searchSchedules,
      ),
    );
  }

  Widget buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Row(
        children: [
          const Text(
            "Upcoming schedules",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const Spacer(),
          Text(
            "${filteredSchedules.length} shown",
            style: const TextStyle(
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.event_busy,
                size: 52,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "No schedules found",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Add a schedule or upload a timetable to get started.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMiniInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF64748B),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildScheduleCard(Map item) {
    final isRecurring = item["is_recurring"] == 1;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 12,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.event_note,
            color: Color(0xFF2563EB),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item["title"],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            if (isRecurring)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Repeat",
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF166534),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildMiniInfo(
                Icons.schedule,
                "${item["event_date"]} at ${item["start_time"]}",
              ),
              const SizedBox(height: 4),
              buildMiniInfo(
                Icons.location_on_outlined,
                item["location"] ?? "No location",
              ),
            ],
          ),
        ),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditScheduleScreen(
                schedule: item,
              ),
            ),
          );

          loadSchedules();
        },
        trailing: IconButton(
          icon: const Icon(
            Icons.delete_outline,
            color: Color(0xFFEF4444),
          ),
          onPressed: () => deleteSchedule(item),
        ),
      ),
    );
  }

  Widget buildScheduleList() {
    if (filteredSchedules.isEmpty) {
      return buildEmptyState();
    }

    return ListView.builder(
      itemCount: filteredSchedules.length,
      itemBuilder: (context, index) {
        final item = filteredSchedules[index];

        return buildScheduleCard(item);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reminder App"),
        actions: [
          IconButton(
            tooltip: "Settings",
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: "Logout",
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          buildHeroHeader(),
          buildStatsRow(),
          buildQuickActions(),
          buildSearchBox(),
          buildSectionTitle(),
          Expanded(
            child: buildScheduleList(),
          ),
        ],
      ),
    );
  }
}