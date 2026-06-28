from datetime import datetime, timedelta
import subprocess

from database import SessionLocal
from models import Schedule


def send_notification(title: str, message: str):
    try:
        subprocess.run([
            "notify-send",
            title,
            message
        ])
    except Exception as e:
        print(f"Notification Error: {e}")

    print("\n===================================")
    print("REMINDER NOTIFICATION")
    print(f"Title: {title}")
    print(f"Message: {message}")
    print(f"Sent At: {datetime.now()}")
    print("===================================\n")


def check_schedule_reminders():
    db = SessionLocal()

    try:
        schedules = db.query(Schedule).all()

        now = datetime.now()

        for schedule in schedules:

            event_datetime = datetime.combine(
                schedule.event_date,
                schedule.start_time
            )

            remaining = event_datetime - now

            # 24 Hours
            if (
                schedule.reminder_24h == 1 and
                schedule.reminder_24h_sent == 0 and
                timedelta(hours=23, minutes=59)
                <= remaining
                <= timedelta(hours=24, minutes=1)
            ):
                send_notification(
                    f"Upcoming: {schedule.title}",
                    "Starts in 24 hours"
                )

                schedule.reminder_24h_sent = 1

            # 1 Hour
            if (
                schedule.reminder_1h == 1 and
                schedule.reminder_1h_sent == 0 and
                timedelta(minutes=59)
                <= remaining
                <= timedelta(hours=1, minutes=1)
            ):
                send_notification(
                    f"Upcoming: {schedule.title}",
                    "Starts in 1 hour"
                )

                schedule.reminder_1h_sent = 1

            # 30 Minutes
            if (
                schedule.reminder_30m == 1 and
                schedule.reminder_30m_sent == 0 and
                timedelta(minutes=29)
                <= remaining
                <= timedelta(minutes=31)
            ):
                send_notification(
                    f"Upcoming: {schedule.title}",
                    "Starts in 30 minutes"
                )

                schedule.reminder_30m_sent = 1

            # 15 Minutes
            if (
                schedule.reminder_15m == 1 and
                schedule.reminder_15m_sent == 0 and
                timedelta(minutes=14)
                <= remaining
                <= timedelta(minutes=16)
            ):
                send_notification(
                    f"Upcoming: {schedule.title}",
                    "Starts in 15 minutes"
                )

                schedule.reminder_15m_sent = 1

        db.commit()

    except Exception as e:
        print(f"Reminder Error: {e}")

    finally:
        db.close()