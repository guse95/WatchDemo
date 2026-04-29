import os
import random
import aiosmtplib
from fastapi import APIRouter, Depends, HTTPException
from passlib.context import CryptContext
from passlib.handlers import bcrypt
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from email.message import EmailMessage
from datetime import datetime, timedelta, timezone
import jwt
import secrets
import hashlib

from app.db import get_db, User, Sessions
from app.models.CodeStorage import saveCode, verifyCode
from app.models.AuthModel import RegistrationData, AuthTokens, LoginData, WhoisInfo


def create_access_token(user_id: int, session_id: int):
    expire = datetime.now() + timedelta(minutes=15)

    payload = {
        "sub": str(user_id),
        "session_id": session_id,
        "exp": expire
    }

    KEY = os.getenv("SESSIONS_SECRET_KEY")
    ALG = os.getenv("SESSIONS_ALGORITHM")

    token = jwt.encode(payload, KEY, algorithm=ALG)
    return token


def create_refresh_token():
    return secrets.token_urlsafe(32)


def hash_token(token: str):
    return hashlib.sha256(token.encode()).hexdigest()


router = APIRouter()
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


@router.post("/register", response_model=AuthTokens, status_code=200)
async def register(reg_data: RegistrationData, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == reg_data.email))
    if result.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="Email already registered")

    new_user = User(
        email=reg_data.email,
        username=reg_data.username,
        password_hash=reg_data.password,
        pass_level=1
    )
    db.add(new_user)
    await db.flush()

    refresh_token = create_refresh_token()
    ref_token_hash = hash_token(refresh_token)

    new_session = Sessions(
        user_id=new_user.id,
        refresh_token_hash=ref_token_hash,
        created_at=datetime.now(),
        expires_at=datetime.now() + timedelta(days=30),
        user_agent=reg_data.user_agent,
    )
    db.add(new_session)
    await db.flush()

    access_token = create_access_token(new_user.id, new_session.id)

    await db.commit()

    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
    }


@router.post("/login", response_model=AuthTokens, status_code=200)
async def login(login_data: LoginData, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == login_data.email))
    existing_user = result.scalar_one_or_none()
    if not existing_user:
        raise HTTPException(status_code=400, detail="No user with this email")

    if existing_user.password_hash != login_data.password:
        raise HTTPException(status_code=400, detail="Invalid password")

    refresh_token = create_refresh_token()
    ref_token_hash = hash_token(refresh_token)

    new_session = Sessions(
        user_id=existing_user.id,
        refresh_token_hash=ref_token_hash,
        created_at=datetime.now(),
        expires_at=datetime.now() + timedelta(minutes=15),
        user_agent=login_data.user_agent,
    )
    db.add(new_session)
    await db.flush()
    await db.commit()

    access_token = create_access_token(existing_user.id, new_session.id)
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
    }


@router.post("/logout", status_code=200)
async def logout(token: str, db: AsyncSession = Depends(get_db)):
    ref_token_hash = hash_token(token)
    result = await db.execute(select(Sessions).where(Sessions.refresh_token_hash == ref_token_hash))
    session = result.scalar_one_or_none()
    if not session:
        raise HTTPException(status_code=400, detail="Invalid refresh token")

    session.revoked_at = datetime.now()
    await db.commit()
    return {"status": "success", "message": "Logged out successfully"}


@router.post("/refresh", response_model=AuthTokens, status_code=200)
async def refresh(ref_token: str, db: AsyncSession = Depends(get_db)):
    ref_token_hash = hash_token(ref_token)
    result = await db.execute(select(Sessions).where(Sessions.refresh_token_hash == ref_token_hash))
    session = result.scalar_one_or_none()
    if not session:
        raise HTTPException(status_code=400, detail="Invalid refresh token")

    if session.revoked_at is not None:
        raise HTTPException(status_code=400, detail="Refresh token expired")

    if datetime.now() - session.created_at > timedelta(days=30):
        raise HTTPException(status_code=400, detail="Refresh token expired")

    new_access_token = create_access_token(session.user_id, session.id)
    return {
        "access_token": new_access_token,
        "refresh_token": ref_token,
    }


@router.get("/whois", response_model=WhoisInfo, status_code=200)
async def refresh(ref_token: str, db: AsyncSession = Depends(get_db)):
    ref_token_hash = hash_token(ref_token)
    result = await db.execute(select(Sessions).where(Sessions.refresh_token_hash == ref_token_hash))
    session = result.scalar_one_or_none()
    if not session:
        raise HTTPException(status_code=400, detail="Invalid refresh token")

    user_res = await db.execute(select(User).where(User.id == session.user_id))
    user = user_res.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=400, detail="User does not exist")

    return {
        "email": user.email,
        "id": user.id,
        "pass_level": user.pass_level,
    }


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