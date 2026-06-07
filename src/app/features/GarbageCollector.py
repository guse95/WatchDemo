import logging
from datetime import datetime
from zoneinfo import ZoneInfo

from apscheduler.schedulers.asyncio import AsyncIOScheduler
from sqlalchemy import delete, update

from app.db import Sessions, async_session, OperationHistory
from app.models.OperationStatus import OperationStatus

scheduler = AsyncIOScheduler()
logger = logging.getLogger("uvicorn.error")

async def cleanup_sessions():
    time_msc = datetime.now(ZoneInfo("Europe/Moscow")).replace(tzinfo=None)
    logger.info(f"[ШЕДУЛЕР] cleanup_sessions запущена. Текущее время: {time_msc}")
    async with async_session() as db:
        await db.execute(
            delete(Sessions).where(
                Sessions.expires_at < time_msc
            )
        )
        await db.commit()

async def update_status_for_bookings():
    time_msc = datetime.now()
    logger.info(f"[ШЕДУЛЕР] update_status_for_bookings запущена. Текущее время: {time_msc}")
    async with async_session() as db:
        async with db.begin():
            await db.execute(
                update(OperationHistory)
                .where(OperationHistory.booked_to < time_msc)
                .values(status = OperationStatus.FINISHED,)
            )


def start_scheduler():
    scheduler.add_job(
        cleanup_sessions,
        "interval",
        hours=1,
        next_run_time=datetime.now()
    )
    scheduler.add_job(
        update_status_for_bookings,
        "interval",
        minutes=10,
        max_instances=1,
        misfire_grace_time=30,
        next_run_time=datetime.now()
    )
    scheduler.start()


def stop_scheduler():
    scheduler.shutdown()