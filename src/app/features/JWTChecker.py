import os

from fastapi import Header, Depends, HTTPException
import jwt
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db import get_db, Sessions

security = HTTPBearer()

async def get_current_user(
        credentials: HTTPAuthorizationCredentials = Depends(security),
        db: AsyncSession = Depends(get_db)
):
    token = credentials.credentials

    try:
        KEY = os.getenv("SESSIONS_SECRET_KEY")
        ALG = os.getenv("SESSIONS_ALGORITHM")
        payload = jwt.decode(token, KEY, algorithms=[ALG])

        user_id: str = payload.get("sub")
        session_id: str = payload.get("session_id")
        expire_at: str = payload.get("exp")
        pass_level: int = payload.get("pass_lvl")

        if user_id is None or session_id is None:
            raise HTTPException(status_code=401, detail="Invalid token payload")

    except jwt.exceptions.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token has expired")

    except jwt.exceptions.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")

    result = await db.execute(
        select(Sessions).where(
            Sessions.id == session_id,
            Sessions.revoked_at == None
        )
    )
    session = result.scalar_one_or_none()

    if not session:
        raise HTTPException(status_code=401, detail="Session expired or logged out")

    return int(user_id)