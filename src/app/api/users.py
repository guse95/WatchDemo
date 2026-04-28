import os
import random

import aiosmtplib
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.sql import crud
from starlette import responses
import ssl
from email.message import EmailMessage

from app.db import get_db, User
from app.models.CodeStorage import saveCode, verifyCode
from app.models.RegistrationModel import UserData, UserDataDB

router = APIRouter()

@router.post("/register/", response_model=UserDataDB, status_code=200)
async def register(user: UserData, db: AsyncSession = Depends(get_db)):
    # TODO: убрать за ненадобностью
    result = await db.execute(select(User).where(User.email == user.email))
    if result.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="Email already registered")

    new_user = User(
        email=user.email,
        username=user.username,
        password_hash="test",
        pass_level=user.pass_level
    )
    db.add(new_user)
    await db.commit()
    await db.refresh(new_user)
    return (new_user


@router.post("/login/", response_model=UserDataDB, status_code=200))
async def login(user: UserData, db: AsyncSession = Depends(get_db)):

    # TODO: убрать за ненадобностью
    result = await db.execute(select(User).where(User.email == user.email))
    if result.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="Email already registered")

    new_user = User(
        email=user.email,
        username=user.username,
        password_hash="test",
        pass_level=user.pass_level
    )
    db.add(new_user)
    await db.commit()
    await db.refresh(new_user)
    return new_user

@router.get("/check-email", status_code=200)
async def check_email(email: str, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == email))
    if result.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="Email already registered")

    email_sender = os.getenv("SMTP_USERNAME")
    email_password = os.getenv("SMTP_PASSWORD")
    email_receiver = email

    subject = "Код подтверждения"
    code = str(random.randint(100000, 999999))
    body = f"""
    Ваш код: {code}
    Никому не сообщайте его.
    """

    em = EmailMessage()
    em['From'] = email_sender
    em['To'] = email_receiver
    em['Subject'] = subject
    em.set_content(body)

    try:
        await aiosmtplib.send(
            em,
            hostname=os.getenv("SMTP_HOST"),
            port=int(os.getenv("SMTP_PORT")),
            username=email_sender,
            password=email_password,
            use_tls=True,
        )
        saveCode(email, code)
        return {"status": "success", "message": "Verification code sent to email"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Mail error: {e}")


@router.get("/check-code", status_code=200)
async def check_email(email: str, code: str):
    if not verifyCode(email, code):
        raise HTTPException(status_code=400, detail=f"Wrong code")
    return {"status": "success", "message": "Verification passed"}