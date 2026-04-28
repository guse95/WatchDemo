from fastapi.params import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.db import get_db
from app.models.RegistrationModel import UserData


# async def create_user(user: UserData, db: AsyncSession = Depends(get_db)):
#     query =