import 'package:flutter/material.dart';
import '../models/schedule.dart';
import '../services/api_service.dart';

class AddScheduleScreen extends StatefulWidget {
  const AddScheduleScreen({super.key});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final title = TextEditingController();
  final description = TextEditingController();
  final location = TextEditingController();
  final recurringWeeks = TextEditingController(text: "12");

  String selectedDate = "";
  String selectedTime = "";

  bool repeatWeekly = false;
  bool isSaving = false;

  bool reminder24h = true;
  bool reminder1h = true;
  bool reminder30m = false;
  bool reminder15m = false;

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
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
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        selectedTime =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00";
      });
    }
  }

  Future<void> saveSchedule() async {
    if (title.text.trim().isEmpty ||
        selectedDate.isEmpty ||
        selectedTime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please add title, date, and time"),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    final weeks = int.tryParse(recurringWeeks.text) ?? 1;

    final schedule = Schedule(
      title: title.text.trim(),
      description: description.text.trim(),
      location: location.text.trim(),
      date: selectedDate,
      time: selectedTime,
      isRecurring: repeatWeekly,
      recurringWeeks: repeatWeekly ? weeks : 1,
      reminder24h: reminder24h,
      reminder1h: reminder1h,
      reminder30m: reminder30m,
      reminder15m: reminder15m,
    );

    final success = await ApiService.addSchedule(schedule);

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
    recurringWeeks.dispose();
    super.dispose();
  }

  Widget buildPickerTile({
    required IconData icon,
    required String titleText,
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
            Icon(icon, color: const Color(0xFF2563EB)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value.isEmpty ? titleText : value,
                style: TextStyle(
                  color: value.isEmpty
                      ? const Color(0xFF64748B)
                      : const Color(0xFF0F172A),
                  fontWeight:
                      value.isEmpty ? FontWeight.normal : FontWeight.w700,
                ),
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
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
            titleText: "Select Date",
            value: selectedDate,
            onTap: pickDate,
          ),
          buildPickerTile(
            icon: Icons.access_time,
            titleText: "Select Time",
            value: selectedTime,
            onTap: pickTime,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              "Repeat weekly",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: const Text("Create this schedule for multiple weeks"),
            value: repeatWeekly,
            onChanged: (value) {
              setState(() {
                repeatWeekly = value;
              });
            },
          ),
          if (repeatWeekly) ...[
            const SizedBox(height: 10),
            TextField(
              controller: recurringWeeks,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Number of weeks",
                prefixIcon: Icon(Icons.repeat),
              ),
            ),
          ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Schedule"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Create a new reminder",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Add class, meeting, or personal schedule details.",
              style: TextStyle(
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 18),
            buildFormCard(),
            buildReminderCard(),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : saveSchedule,
                icon: const Icon(Icons.save),
                label: Text(
                  isSaving
                      ? "Saving..."
                      : repeatWeekly
                          ? "Save Recurring Schedule"
                          : "Save Schedule",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}