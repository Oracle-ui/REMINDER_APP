from pydantic import BaseModel, Field
from datetime import date, time


# ==========================
# USER SCHEMAS
# ==========================

class UserCreate(BaseModel):
    full_name: str
    email: str
    password: str = Field(
        min_length=8,
        max_length=64
    )


class UserLogin(BaseModel):
    email: str
    password: str = Field(
        min_length=8,
        max_length=64
    )


class UserResponse(BaseModel):
    id: int
    full_name: str
    email: str

    class Config:
        from_attributes = True


# ==========================
# SCHEDULE CREATION
# ==========================

class ScheduleCreate(BaseModel):
    title: str
    description: str
    location: str

    event_date: date
    start_time: time

    user_id: int

    # Recurring Settings
    is_recurring: int = 0
    recurring_weeks: int = 1

    # Reminder Settings
    reminder_24h: int = 1
    reminder_1h: int = 1
    reminder_30m: int = 0
    reminder_15m: int = 0


# ==========================
# SCHEDULE RESPONSE
# ==========================

class ScheduleResponse(BaseModel):
    id: int

    user_id: int

    title: str
    description: str
    location: str

    event_date: date
    start_time: time

    is_recurring: int
    recurring_group_id: str | None = None

    # Reminder Preferences
    reminder_24h: int
    reminder_1h: int
    reminder_30m: int
    reminder_15m: int

    # Reminder Status
    reminder_24h_sent: int
    reminder_1h_sent: int
    reminder_30m_sent: int
    reminder_15m_sent: int

    class Config:
        from_attributes = True