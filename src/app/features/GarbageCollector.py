from datetime import datetime

from apscheduler.schedulers.asyncio import AsyncIOScheduler
from sqlalchemy import delete

from app.db import Sessions, async_session

scheduler = AsyncIOScheduler()

async def cleanup_sessions():
    async with async_session as db:
        await db.execute(
            delete(Sessions).where(
                Sessions.expires_at < datetime.utcnow()
            )
        )
        await db.commit()


def start_scheduler():
    scheduler.add_job(
        cleanup_sessions,
        "interval",
        hours=1,
    )
    scheduler.start()


def stop_scheduler():
    scheduler.shutdown()