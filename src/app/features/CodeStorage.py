import os
from datetime import timedelta
from enum import Enum

from redis.asyncio import Redis

from app.models.CodeStatus import CodeStatus

redis_password = os.getenv("REDIS_PASSWORD")

redis = Redis(
    host="redis",
    port=6379,
    db=0,
    password=redis_password,
    decode_responses=True,
)


async def saveCode(email: str, code:str):
    return await redis.set(email, code, ex=timedelta(minutes=5))

async def verifyCode(email: str, inputCode: str) -> CodeStatus:
    code = await redis.get(email)
    match code:
        case None:
            return CodeStatus.EXPIRED
        case c if c == inputCode:
            return CodeStatus.CORRECT
        case _:
            return CodeStatus.WRONG