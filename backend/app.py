from fastapi import FastAPI

from database import Base
from database import engine

from routes.auth import router as auth_router
from routes.schedules import router as schedule_router

from services.scheduler import start_scheduler
from routes.upload import router as upload_router
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Class Reminder API"
)

app.include_router(
    auth_router,
    prefix="/auth",
    tags=["Authentication"]
)

app.include_router(
    schedule_router,
    prefix="/schedules",
    tags=["Schedules"]
)
app.include_router(
    upload_router,
    prefix="/upload",
    tags=["Upload"]
)

@app.on_event("startup")
def startup():

    start_scheduler()


@app.get("/")
def root():

    return {
        "message": "Class Reminder API Running"
    }