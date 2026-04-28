from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db import get_db, Resource
from app.models.RegistrationModel import ResourceDTO

router = APIRouter()

@router.get("/all", response_model=list[ResourceDTO])
async def get_all_resources(db: AsyncSession = Depends(get_db)):
    resources = await db.execute(select(Resource))
    return resources.scalars().all()

@router.get("/{resource_type}", response_model=list[ResourceDTO])
async def get_all_resources(resource_type: str, db: AsyncSession = Depends(get_db)):
    resources = await db.execute(select(Resource).where(Resource.type == resource_type))
    return resources.scalars().all()