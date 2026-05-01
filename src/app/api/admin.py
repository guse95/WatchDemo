from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db import get_db, Resource
from app.features.JWTChecker import get_current_user
from app.models.RegistrationModel import ResourceDTO, ResourceData, EditResourceData

router = APIRouter()

@router.post("/create", response_model=ResourceDTO)
async def create_resource(resource: ResourceData, user_id: int = Depends(get_current_user),  db: AsyncSession = Depends(get_db)):
    new_resource = Resource(
        name=resource.name,
        type=resource.type,
        description=resource.description,
        extra_attributes=resource.extra_attributes
    )

    db.add(new_resource)
    await db.commit()
    await db.refresh(new_resource)
    return new_resource

@router.put("/update", response_model=ResourceDTO)
async def update_resource(resource_data: EditResourceData, user_id: int = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    resource = await db.execute(select(Resource).where(Resource.id == resource_data.id))

    resource = resource.scalar_one_or_none()
    if resource is None:
        raise HTTPException(status_code=400, detail="Resource does not exists")

    if resource.type != resource_data.type:
        update_data = resource_data.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            if value is not None:
                setattr(resource, key, value)
    else:
        update_data = resource_data.model_dump(exclude_unset=True, exclude={"extra_attributes"})
        for key, value in update_data.items():
            if value is not None:
                setattr(resource, key, value)

        if resource_data.extra_attributes is not None:
            current_extra = resource.extra_attributes or {}

            new_extra = {k: v for k, v in resource_data.extra_attributes.items() if v is not None}

            resource.extra_attributes = {**current_extra, **new_extra}

            from sqlalchemy.orm.attributes import flag_modified
            flag_modified(resource, "extra_attributes")

    await db.commit()
    await db.refresh(resource)
    return resource