from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.sql import crud
from starlette import responses

from app.db import get_db, User
from app.models.RegistrationModel import UserData, UserDataDB

router = APIRouter()

@router.post("/register/", response_model=UserDataDB, status_code=200)
async def register(user: UserData, db: AsyncSession = Depends(get_db)):
    # user_id = await crud.create_user(user)
    # response = {
    #     "id": user_id,
    #     "email": user.email,
    #     "username": user.username,
    #     "login": user.login,
    #     "pass_level": user.pass_level,
    # }

    result = await db.execute(select(User).where(User.email == user.email))
    if result.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="Email already registered")

    new_user = User(
        email=user.email,
        username=user.username,
        login=user.login,
        password_hash="test",
        pass_level=user.pass_level
    )
    db.add(new_user)
    await db.commit()
    await db.refresh(new_user)
    return new_user