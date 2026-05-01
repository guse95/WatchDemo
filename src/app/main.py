from contextlib import asynccontextmanager

from uvicorn.middleware.proxy_headers import ProxyHeadersMiddleware

from app.api import ping, admin, user, auth
from app.db import engine

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

@asynccontextmanager
async def lifespan(app: FastAPI):
    async with engine.begin() as conn:
        print("Successfully connected to the database")
    yield
    await engine.dispose()

app = FastAPI(lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(ping.router)
app.include_router(auth.router, prefix="/auth")
app.include_router(admin.router, prefix="/resoures/admin")
app.include_router(user.router, prefix="/resoures/user")