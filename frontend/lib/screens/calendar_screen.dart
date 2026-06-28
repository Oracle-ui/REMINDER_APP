import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  final List schedules;

  const CalendarScreen({
    super.key,
    required this.schedules,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  List getSchedulesForDay(DateTime day) {
    final dateText =
        "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";

    return widget.schedules.where((schedule) {
      return schedule["event_date"].toString() == dateText;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedSchedules = getSchedulesForDay(selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendar View"),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: TableCalendar(
              firstDay: DateTime(2020),
              lastDay: DateTime(2035),
              focusedDay: focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(selectedDay, day);
              },
              onDaySelected: (selected, focused) {
                setState(() {
                  selectedDay = selected;
                  focusedDay = focused;
                });
              },
              eventLoader: getSchedulesForDay,
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Color(0xFF93C5FD),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Expanded(
            child: selectedSchedules.isEmpty
                ? const Center(
                    child: Text("No schedules for this day"),
                  )
                : ListView.builder(
                    itemCount: selectedSchedules.length,
                    itemBuilder: (context, index) {
                      final item = selectedSchedules[index];

                      return Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.event_note,
                            color: Color(0xFF2563EB),
                          ),
                          title: Text(item["title"]),
                          subtitle: Text(
                            "${item["start_time"]}\n${item["location"] ?? "No location"}",
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}