import re


def clean_ocr_text(text: str):
    text = text.replace("\f", "\n")
    text = text.replace("|", " ")
    text = re.sub(r"[^\w\s:.,/-]", " ", text)
    text = re.sub(r"\s+", " ", text)
    return text.strip()


def analyze_timetable_text(text: str):
    cleaned_text = clean_ocr_text(text)

    return {
        "cleaned_text": cleaned_text,
        "detected_schedules": [],
        "detected_count": 0,
    }