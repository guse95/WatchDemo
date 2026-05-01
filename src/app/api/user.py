from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db import get_db, Resource
from app.features.JWTChecker import get_current_user
from app.models.RegistrationModel import ResourceDTO

router = APIRouter()

@router.get("/all", response_model=list[ResourceDTO])
async def get_all_resources(start_ind: int, limit: int, user_id: int = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    resources = await db.execute(select(Resource))
    resources = resources.scalars().all()
    end_ind = min(start_ind + limit, len(resources))
    return resources[start_ind:end_ind]

@router.get("/{resource_type}", response_model=list[ResourceDTO])
async def get_all_resources(start_ind: int, limit: int, resource_type: str, user_id: int = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    resources = await db.execute(select(Resource).where(Resource.type == resource_type))
    resources = resources.scalars().all()
    end_ind = min(start_ind + limit, len(resources))
    return resources[start_ind:end_ind]