from sqlalchemy import Column, Integer, String, Date, Time, ForeignKey
from database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    password = Column(String, nullable=False)


class Schedule(Base):
    __tablename__ = "schedules"

    id = Column(Integer, primary_key=True, index=True)

    user_id = Column(
        Integer,
        ForeignKey("users.id"),
        nullable=False
    )

    title = Column(String, nullable=False)
    description = Column(String)
    location = Column(String)

    event_date = Column(Date, nullable=False)
    start_time = Column(Time, nullable=False)

    # Reminder Settings
    reminder_24h = Column(Integer, default=1)
    reminder_1h = Column(Integer, default=1)
    reminder_30m = Column(Integer, default=0)
    reminder_15m = Column(Integer, default=0)

    # Sent Tracking
    reminder_24h_sent = Column(Integer, default=0)
    reminder_1h_sent = Column(Integer, default=0)
    reminder_30m_sent = Column(Integer, default=0)
    reminder_15m_sent = Column(Integer, default=0)

    # Recurring Events
    is_recurring = Column(Integer, default=0)

    recurring_group_id = Column(
        String,
        nullable=True
    )