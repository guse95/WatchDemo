from app.api import ping, auth
from app.db import engine
from fastapi import FastAPI

# metadata.create_all(engine)

app = FastAPI()

@app.on_event("startup")
async def startup():
    async with engine.begin() as conn:
        print("Successfully connected to the database")

@app.on_event("shutdown")
async def shutdown():
    await engine.dispose()

app.include_router(ping.router)
app.include_router(auth.router, prefix="/auth")