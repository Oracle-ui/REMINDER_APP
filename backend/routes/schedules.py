from fastapi import APIRouter, Depends, HTTPException, Header
from sqlalchemy.orm import Session
from datetime import timedelta
from jose import jwt, JWTError
import uuid

from database import get_db
from models import Schedule
from schemas import ScheduleCreate

router = APIRouter()

SECRET_KEY = "change-this-secret-key-later"
ALGORITHM = "HS256"


def get_current_user_id(authorization: str = Header(None)):
    if not authorization:
        raise HTTPException(status_code=401, detail="Missing authorization token")

    try:
        scheme, token = authorization.split()

        if scheme.lower() != "bearer":
            raise HTTPException(status_code=401, detail="Invalid authentication scheme")

        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = payload.get("user_id")

        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid token")

        return user_id

    except (JWTError, ValueError):
        raise HTTPException(status_code=401, detail="Invalid or expired token")


def build_schedule(schedule: ScheduleCreate, user_id: int, event_date, group_id=None):
    return Schedule(
        user_id=user_id,
        title=schedule.title,
        description=schedule.description,
        location=schedule.location,
        event_date=event_date,
        start_time=schedule.start_time,

        reminder_24h=schedule.reminder_24h,
        reminder_1h=schedule.reminder_1h,
        reminder_30m=schedule.reminder_30m,
        reminder_15m=schedule.reminder_15m,

        reminder_24h_sent=0,
        reminder_1h_sent=0,
        reminder_30m_sent=0,
        reminder_15m_sent=0,

        is_recurring=schedule.is_recurring,
        recurring_group_id=group_id,
    )


@router.post("/")
def create_schedule(
    schedule: ScheduleCreate,
    db: Session = Depends(get_db),
    current_user_id: int = Depends(get_current_user_id),
):
    if schedule.is_recurring == 1:
        group_id = str(uuid.uuid4())
        created_schedules = []

        for week in range(schedule.recurring_weeks):
            new_schedule = build_schedule(
                schedule=schedule,
                user_id=current_user_id,
                event_date=schedule.event_date + timedelta(weeks=week),
                group_id=group_id,
            )

            db.add(new_schedule)
            created_schedules.append(new_schedule)

        db.commit()

        return {
            "message": "Recurring schedules created successfully",
            "created_count": len(created_schedules),
        }

    new_schedule = build_schedule(
        schedule=schedule,
        user_id=current_user_id,
        event_date=schedule.event_date,
        group_id=None,
    )

    new_schedule.is_recurring = 0

    db.add(new_schedule)
    db.commit()
    db.refresh(new_schedule)

    return {
        "message": "Schedule created successfully",
        "schedule_id": new_schedule.id,
    }


@router.get("/")
def get_schedules(
    db: Session = Depends(get_db),
    current_user_id: int = Depends(get_current_user_id),
):
    return (
        db.query(Schedule)
        .filter(Schedule.user_id == current_user_id)
        .order_by(Schedule.event_date, Schedule.start_time)
        .all()
    )


@router.get("/{schedule_id}")
def get_schedule(
    schedule_id: int,
    db: Session = Depends(get_db),
    current_user_id: int = Depends(get_current_user_id),
):
    schedule = (
        db.query(Schedule)
        .filter(
            Schedule.id == schedule_id,
            Schedule.user_id == current_user_id,
        )
        .first()
    )

    if not schedule:
        raise HTTPException(status_code=404, detail="Schedule not found")

    return schedule


@router.put("/{schedule_id}")
def update_schedule(
    schedule_id: int,
    updated_schedule: ScheduleCreate,
    db: Session = Depends(get_db),
    current_user_id: int = Depends(get_current_user_id),
):
    schedule = (
        db.query(Schedule)
        .filter(
            Schedule.id == schedule_id,
            Schedule.user_id == current_user_id,
        )
        .first()
    )

    if not schedule:
        raise HTTPException(status_code=404, detail="Schedule not found")

    schedule.title = updated_schedule.title
    schedule.description = updated_schedule.description
    schedule.location = updated_schedule.location
    schedule.event_date = updated_schedule.event_date
    schedule.start_time = updated_schedule.start_time

    schedule.reminder_24h = updated_schedule.reminder_24h
    schedule.reminder_1h = updated_schedule.reminder_1h
    schedule.reminder_30m = updated_schedule.reminder_30m
    schedule.reminder_15m = updated_schedule.reminder_15m

    schedule.reminder_24h_sent = 0
    schedule.reminder_1h_sent = 0
    schedule.reminder_30m_sent = 0
    schedule.reminder_15m_sent = 0

    db.commit()
    db.refresh(schedule)

    return {
        "message": "Schedule updated successfully",
        "schedule_id": schedule.id,
    }


@router.delete("/{schedule_id}")
def delete_schedule(
    schedule_id: int,
    db: Session = Depends(get_db),
    current_user_id: int = Depends(get_current_user_id),
):
    schedule = (
        db.query(Schedule)
        .filter(
            Schedule.id == schedule_id,
            Schedule.user_id == current_user_id,
        )
        .first()
    )

    if not schedule:
        raise HTTPException(status_code=404, detail="Schedule not found")

    db.delete(schedule)
    db.commit()

    return {"message": "Schedule deleted successfully"}


@router.delete("/recurring/{group_id}")
def delete_recurring_group(
    group_id: str,
    db: Session = Depends(get_db),
    current_user_id: int = Depends(get_current_user_id),
):
    schedules = (
        db.query(Schedule)
        .filter(
            Schedule.recurring_group_id == group_id,
            Schedule.user_id == current_user_id,
        )
        .all()
    )

    if not schedules:
        raise HTTPException(status_code=404, detail="Recurring schedule group not found")

    for schedule in schedules:
        db.delete(schedule)

    db.commit()

    return {
        "message": "Recurring schedule group deleted successfully",
        "deleted_count": len(schedules),
    }