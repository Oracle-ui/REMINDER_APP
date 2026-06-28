import 'package:flutter/material.dart';
import '../models/schedule.dart';
import '../services/api_service.dart';

class EditScheduleScreen extends StatefulWidget {
  final Map schedule;

  const EditScheduleScreen({
    super.key,
    required this.schedule,
  });

  @override
  State<EditScheduleScreen> createState() => _EditScheduleScreenState();
}

class _EditScheduleScreenState extends State<EditScheduleScreen> {
  late TextEditingController title;
  late TextEditingController description;
  late TextEditingController location;

  late String selectedDate;
  late String selectedTime;

  bool isSaving = false;

  late bool reminder24h;
  late bool reminder1h;
  late bool reminder30m;
  late bool reminder15m;

  @override
  void initState() {
    super.initState();

    title = TextEditingController(
      text: widget.schedule["title"] ?? "",
    );

    description = TextEditingController(
      text: widget.schedule["description"] ?? "",
    );

    location = TextEditingController(
      text: widget.schedule["location"] ?? "",
    );

    selectedDate = widget.schedule["event_date"];
    selectedTime = widget.schedule["start_time"];

    reminder24h = widget.schedule["reminder_24h"] == 1;
    reminder1h = widget.schedule["reminder_1h"] == 1;
    reminder30m = widget.schedule["reminder_30m"] == 1;
    reminder15m = widget.schedule["reminder_15m"] == 1;
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(selectedDate),
      firstDate: DateTime.now().subtract(
        const Duration(days: 365),
      ),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        selectedDate =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> pickTime() async {
    final parts = selectedTime.split(":");

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      ),
    );

    if (picked != null) {
      setState(() {
        selectedTime =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00";
      });
    }
  }

  Future<void> saveChanges() async {
    if (title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Title cannot be empty"),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    final updated = Schedule(
      title: title.text.trim(),
      description: description.text.trim(),
      location: location.text.trim(),
      date: selectedDate,
      time: selectedTime,
      reminder24h: reminder24h,
      reminder1h: reminder1h,
      reminder30m: reminder30m,
      reminder15m: reminder15m,
    );

    final success = await ApiService.updateSchedule(
      widget.schedule["id"],
      updated,
    );

    setState(() {
      isSaving = false;
    });

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    location.dispose();
    super.dispose();
  }

  Widget buildPickerTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF2563EB),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget buildReminderSwitch({
    required String titleText,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        titleText,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          TextField(
            controller: title,
            decoration: const InputDecoration(
              labelText: "Schedule Title",
              prefixIcon: Icon(Icons.title),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: description,
            decoration: const InputDecoration(
              labelText: "Description",
              prefixIcon: Icon(Icons.notes),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: location,
            decoration: const InputDecoration(
              labelText: "Location",
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 18),
          buildPickerTile(
            icon: Icons.calendar_today,
            label: "Date",
            value: selectedDate,
            onTap: pickDate,
          ),
          buildPickerTile(
            icon: Icons.access_time,
            label: "Time",
            value: selectedTime,
            onTap: pickTime,
          ),
        ],
      ),
    );
  }

  Widget buildReminderCard() {
    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.notifications_active_outlined,
                color: Color(0xFF2563EB),
              ),
              SizedBox(width: 10),
              Text(
                "Reminder Preferences",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "Choose when you want to be notified before this schedule starts.",
            style: TextStyle(
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 14),
          buildReminderSwitch(
            titleText: "24 hours before",
            subtitle: "Useful for preparing a day ahead",
            value: reminder24h,
            onChanged: (value) {
              setState(() {
                reminder24h = value;
              });
            },
          ),
          buildReminderSwitch(
            titleText: "1 hour before",
            subtitle: "Good for getting ready before the event",
            value: reminder1h,
            onChanged: (value) {
              setState(() {
                reminder1h = value;
              });
            },
          ),
          buildReminderSwitch(
            titleText: "30 minutes before",
            subtitle: "Short reminder before start time",
            value: reminder30m,
            onChanged: (value) {
              setState(() {
                reminder30m = value;
              });
            },
          ),
          buildReminderSwitch(
            titleText: "15 minutes before",
            subtitle: "Final reminder before the event begins",
            value: reminder15m,
            onChanged: (value) {
              setState(() {
                reminder15m = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget buildRecurringNotice() {
    final isRecurring = widget.schedule["is_recurring"] == 1;

    if (!isRecurring) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF86EFAC),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.repeat,
            color: Color(0xFF166534),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "This is part of a recurring schedule. Editing this will update only this occurrence.",
              style: TextStyle(
                color: Color(0xFF166534),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Schedule"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Update reminder",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Modify schedule details, time, date, location, or reminder preferences.",
              style: TextStyle(
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 18),
            buildRecurringNotice(),
            buildFormCard(),
            buildReminderCard(),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : saveChanges,
                icon: const Icon(Icons.save),
                label: Text(
                  isSaving ? "Saving Changes..." : "Save Changes",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}