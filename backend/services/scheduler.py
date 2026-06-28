from apscheduler.schedulers.background import BackgroundScheduler
from datetime import datetime, timedelta

from database import SessionLocal
from models import Schedule
from services.notifications import send_notification

scheduler = BackgroundScheduler()


def check_events():
    db = SessionLocal()

    try:
        now = datetime.now()

        schedules = db.query(Schedule).all()

        for schedule in schedules:

            event_datetime = datetime.combine(
                schedule.event_date,
                schedule.start_time
            )

            remaining = event_datetime - now

            # =====================
            # 24 HOURS
            # =====================

            if (
                schedule.reminder_24h == 1 and
                schedule.reminder_24h_sent == 0 and
                timedelta(hours=23, minutes=59)
                <= remaining
                <= timedelta(hours=24, minutes=1)
            ):
                send_notification(
                    "Reminder (24 Hours)",
                    f"{schedule.title} starts tomorrow at "
                    f"{schedule.start_time}"
                )

                schedule.reminder_24h_sent = 1

            # =====================
            # 1 HOUR
            # =====================

            if (
                schedule.reminder_1h == 1 and
                schedule.reminder_1h_sent == 0 and
                timedelta(minutes=59)
                <= remaining
                <= timedelta(hours=1, minutes=1)
            ):
                send_notification(
                    "Reminder (1 Hour)",
                    f"{schedule.title} starts in 1 hour"
                )

                schedule.reminder_1h_sent = 1

            # =====================
            # 30 MINUTES
            # =====================

            if (
                schedule.reminder_30m == 1 and
                schedule.reminder_30m_sent == 0 and
                timedelta(minutes=29)
                <= remaining
                <= timedelta(minutes=31)
            ):
                send_notification(
                    "Reminder (30 Minutes)",
                    f"{schedule.title} starts in 30 minutes"
                )

                schedule.reminder_30m_sent = 1

            # =====================
            # 15 MINUTES
            # =====================

            if (
                schedule.reminder_15m == 1 and
                schedule.reminder_15m_sent == 0 and
                timedelta(minutes=14)
                <= remaining
                <= timedelta(minutes=16)
            ):
                send_notification(
                    "Reminder (15 Minutes)",
                    f"{schedule.title} starts in 15 minutes"
                )

                schedule.reminder_15m_sent = 1

        db.commit()

    except Exception as e:
        print(f"Scheduler Error: {e}")

    finally:
        db.close()


def start_scheduler():

    if not scheduler.running:

        scheduler.add_job(
            check_events,
            "interval",
            minutes=1,
            id="schedule_checker",
            replace_existing=True,
        )

        scheduler.start()

        print("Reminder Scheduler Started")