# Reminder App

A smart AI-powered reminder and timetable management app built with **FastAPI** and **Flutter**. The app helps students and professionals manage schedules, upload timetables, receive reminders, and organize daily activities more efficiently.

## Features

* User registration and login
* Schedule/reminder creation
* Dashboard for upcoming reminders
* Calendar view
* Timetable upload
* AI-powered timetable extraction using Gemini
* Smart notification workflow
* Cross-platform Flutter frontend
* FastAPI backend with structured routes and services

## Tech Stack

### Backend

* Python
* FastAPI
* SQLite
* SQLAlchemy
* Pydantic
* Gemini AI integration

### Frontend

* Flutter
* Dart
* Android/iOS/Linux/Web support

## Project Structure

```text
REMINDER_APP/
├── backend/
│   ├── app.py
│   ├── database.py
│   ├── models.py
│   ├── schemas.py
│   ├── routes/
│   ├── services/
│   ├── requirements.txt
│   └── .env.example
│
├── frontend/
│   ├── lib/
│   │   ├── models/
│   │   ├── screens/
│   │   └── services/
│   ├── android/
│   ├── ios/
│   ├── web/
│   └── pubspec.yaml
│
├── .gitignore
└── README.md
```

## How to Run the Backend

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app:app --reload
```

Backend runs at:

```text
http://127.0.0.1:8000
```

API documentation:

```text
http://127.0.0.1:8000/docs
```

## How to Run the Frontend

```bash
cd frontend
flutter pub get
flutter run
```

## Environment Variables

Create a `.env` file inside the `backend/` folder using `.env.example` as a guide.

```env
DATABASE_URL=sqlite:///./schedule_app.db
SECRET_KEY=your_secret_key_here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
GEMINI_API_KEY=your_gemini_api_key_here
```

## Screenshots

Add screenshots here:

```text
screenshots/dashboard.png
screenshots/login.png
screenshots/calendar.png
```

## Future Improvements

* Cloud deployment for backend
* Firebase push notifications
* Google Calendar integration
* Email reminders
* Mobile app release
* Admin dashboard

## Author

Built by Nana Arctic.

GitHub: [Oracle-ui](https://github.com/Oracle-ui)
