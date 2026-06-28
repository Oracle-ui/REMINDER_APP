class Schedule {
  final String title;
  final String description;
  final String location;

  final String date;
  final String time;

  final bool isRecurring;
  final int recurringWeeks;

  final bool reminder24h;
  final bool reminder1h;
  final bool reminder30m;
  final bool reminder15m;

  Schedule({
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.time,
    this.isRecurring = false,
    this.recurringWeeks = 1,
    this.reminder24h = true,
    this.reminder1h = true,
    this.reminder30m = false,
    this.reminder15m = false,
  });

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "description": description,
      "location": location,

      "event_date": date,
      "start_time": time,

      "is_recurring": isRecurring ? 1 : 0,
      "recurring_weeks": recurringWeeks,

      "reminder_24h": reminder24h ? 1 : 0,
      "reminder_1h": reminder1h ? 1 : 0,
      "reminder_30m": reminder30m ? 1 : 0,
      "reminder_15m": reminder15m ? 1 : 0,
    };
  }
}