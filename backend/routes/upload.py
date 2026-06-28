import os
import shutil

from fastapi import APIRouter, UploadFile, File
from PIL import Image, ImageEnhance, ImageFilter
import pytesseract
from pdf2image import convert_from_path
from pydantic import BaseModel
from datetime import date, timedelta, datetime

from services.timetable_analyzer import analyze_timetable_text
from services.gemini_timetable_analyzer import analyze_timetable_image
from database import SessionLocal
from models import Schedule

router = APIRouter()

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)


class ExtractedScheduleRequest(BaseModel):
    text: str
    user_id: int


class GeminiScheduleRequest(BaseModel):
    user_id: int
    schedules: list


def preprocess_image(image):
    image = image.convert("L")
    image = image.resize((image.width * 2, image.height * 2))
    image = ImageEnhance.Contrast(image).enhance(2)
    image = image.filter(ImageFilter.SHARPEN)
    return image


def get_next_weekday(day_name: str):
    days = {
        "monday": 0,
        "tuesday": 1,
        "wednesday": 2,
        "thursday": 3,
        "friday": 4,
        "saturday": 5,
        "sunday": 6,
    }

    today = date.today()
    target_day = days[day_name.lower()]
    days_ahead = target_day - today.weekday()

    if days_ahead < 0:
        days_ahead += 7

    return today + timedelta(days=days_ahead)


@router.post("/timetable")
async def upload_timetable(file: UploadFile = File(...)):
    file_path = os.path.join(UPLOAD_DIR, file.filename)

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    extracted_text = ""
    gemini_analysis = None

    if file.filename.lower().endswith((".png", ".jpg", ".jpeg")):
        print("Gemini analyzer is running...")
        gemini_analysis = analyze_timetable_image(file_path)

        image = Image.open(file_path)
        image = preprocess_image(image)

        extracted_text = pytesseract.image_to_string(
            image,
            config="--psm 6"
        )

    elif file.filename.lower().endswith(".pdf"):
        pages = convert_from_path(file_path)

        for page in pages:
            page = preprocess_image(page)

            extracted_text += pytesseract.image_to_string(
                page,
                config="--psm 6"
            ) + "\n"

    else:
        return {
            "error": "Unsupported file type. Upload PNG, JPG, JPEG, or PDF."
        }

    analysis = analyze_timetable_text(extracted_text)

    return {
        "message": "File processed successfully",
        "gemini_schedules": gemini_analysis.get("schedules", []) if gemini_analysis else [],
        "gemini_error": gemini_analysis.get("error") if gemini_analysis else None,
        "extracted_text": extracted_text,
        "cleaned_text": analysis["cleaned_text"],
        "detected_schedules": analysis["detected_schedules"],
        "detected_count": analysis["detected_count"],
    }


@router.post("/save-extracted")
def save_extracted_schedules(request: ExtractedScheduleRequest):
    db = SessionLocal()
    saved = []

    try:
        lines = request.text.splitlines()

        for line in lines:
            parts = [part.strip() for part in line.split(",")]

            if len(parts) != 4:
                continue

            day_name, time_text, title, location = parts

            try:
                event_date = get_next_weekday(day_name)
                start_time = datetime.strptime(
                    time_text,
                    "%H:%M"
                ).time()

                schedule = Schedule(
                    user_id=request.user_id,
                    title=title,
                    description="Created from uploaded timetable",
                    location=location,
                    event_date=event_date,
                    start_time=start_time,
                )

                db.add(schedule)
                saved.append(title)

            except Exception:
                continue

        db.commit()

        return {
            "message": "Schedules saved successfully",
            "saved_count": len(saved),
            "saved": saved,
        }

    finally:
        db.close()


@router.post("/save-gemini")
def save_gemini_schedules(request: GeminiScheduleRequest):
    db = SessionLocal()
    saved = []

    try:
        for item in request.schedules:
            try:
                day = item.get("day", "")
                time_text = item.get("time", "")

                if not day or not time_text:
                    continue

                event_date = get_next_weekday(day)

                start_time = datetime.strptime(
                    time_text,
                    "%H:%M"
                ).time()

                schedule = Schedule(
                    user_id=request.user_id,
                    title=item.get("title", "Detected Class"),
                    description="Created by Gemini timetable analyzer",
                    location=item.get("location", "Not specified"),
                    event_date=event_date,
                    start_time=start_time,
                )

                db.add(schedule)
                saved.append(schedule.title)

            except Exception:
                continue

        db.commit()

        return {
            "message": "Gemini schedules saved successfully",
            "saved_count": len(saved),
            "saved": saved,
        }

    finally:
        db.close()