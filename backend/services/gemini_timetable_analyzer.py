import os
import json
import re
import mimetypes
from google import genai
from google.genai import types

MODEL_NAME = "gemini-2.5-flash"


def extract_json(text: str):
    try:
        cleaned = text.strip()

        if cleaned.startswith("```json"):
            cleaned = cleaned.replace("```json", "").replace("```", "").strip()
        elif cleaned.startswith("```"):
            cleaned = cleaned.replace("```", "").strip()

        match = re.search(r"\{.*\}", cleaned, re.DOTALL)

        if not match:
            return {
                "schedules": [],
                "error": "No JSON found in Gemini response",
                "raw_response": text,
            }

        return json.loads(match.group(0))

    except Exception as e:
        return {
            "schedules": [],
            "error": f"Invalid JSON from Gemini: {str(e)}",
            "raw_response": text,
        }


def analyze_timetable_image(file_path: str):
    api_key = os.getenv("GEMINI_API_KEY")

    if not api_key:
        return {
            "schedules": [],
            "error": "GEMINI_API_KEY not found",
        }

    try:
        client = genai.Client(api_key=api_key)

        mime_type, _ = mimetypes.guess_type(file_path)

        if mime_type is None:
            mime_type = "image/png"

        with open(file_path, "rb") as f:
            image_bytes = f.read()

        prompt = """
You are a highly accurate university timetable image analyzer.

Carefully inspect the uploaded timetable image.

Extract class schedules from the table.

Return ONLY valid JSON. No markdown. No explanation.

Use this format exactly:

{
  "schedules": [
    {
      "day": "Monday",
      "time": "08:00",
      "title": "Course or class name",
      "location": "Room or lab",
      "confidence": 0.90
    }
  ]
}

Rules:
- Detect days such as Monday, Tuesday, Wednesday, Thursday, Friday.
- Detect class/course names even if abbreviated.
- Detect rooms/labs/locations.
- If time range is shown, use the start time only.
- Use 24-hour time format HH:MM.
- If location is unclear, use "Not specified".
- If no schedules are visible, return {"schedules": []}.
- Do not invent schedules.
"""

        response = client.models.generate_content(
            model=MODEL_NAME,
            contents=[
                types.Part.from_bytes(
                    data=image_bytes,
                    mime_type=mime_type,
                ),
                prompt,
            ],
        )

        print("===== GEMINI RAW RESPONSE =====")
        print(response.text)
        print("===============================")

        return extract_json(response.text)

    except Exception as e:
        return {
            "schedules": [],
            "error": str(e),
        }