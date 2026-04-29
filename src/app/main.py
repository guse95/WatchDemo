from app.api import ping, admin, user, auth
from app.db import engine

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# metadata.create_all(engine)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
async def startup():
    async with engine.begin() as conn:
        print("Successfully connected to the database")

@app.on_event("shutdown")
async def shutdown():
    await engine.dispose()

app.include_router(ping.router)
app.include_router(auth.router, prefix="/auth")
app.include_router(admin.router, prefix="/admin")
app.include_router(user.router, prefix="/user")