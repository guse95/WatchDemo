from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException
from fastapi.openapi.models import Operation
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.db import get_db, Resource, OperationHistory
from app.features.JWTChecker import get_current_user
from app.models.OperationStatus import OperationStatus
from app.models.OperationDTO import OperationDTO
from app.models.RegistrationModel import ResourceDTO

router = APIRouter(tags=["User"], prefix="/resources/user")

@router.get("/all", response_model=list[ResourceDTO])
async def get_all_resources(
        start_ind: int = 0,
        limit: int = 50,
        user_id: int = Depends(get_current_user),
        db: AsyncSession = Depends(get_db)
):
    resources = await db.execute(select(Resource))
    resources = resources.scalars().all()
    end_ind = min(start_ind + limit, len(resources))
    return resources[start_ind:end_ind]

@router.get("/{resource_type}", response_model=list[ResourceDTO])
async def get_certain_resources(
        resource_type: str,
        start_ind: int = 0,
        limit: int = 50,
        user_id: int = Depends(get_current_user),
        db: AsyncSession = Depends(get_db)
):
    resources = await db.execute(select(Resource).where(Resource.type == resource_type))
    resources = resources.scalars().all()
    end_ind = min(start_ind + limit, len(resources))
    return resources[start_ind:end_ind]

@router.post("/book/{resource_id}")
async def book_resource(
        resource_id: int,
        description: str,
        booked_from: datetime,
        booked_to: datetime,
        user_id: int = Depends(get_current_user),
        db: AsyncSession = Depends(get_db)
):
    try:
        booking = OperationHistory(
            booker_id=user_id,
            resource_id=resource_id,
            description=description,
            booked_from=booked_from,
            booked_to=booked_to,
        )

        db.add(booking)
        await db.commit()
        await db.refresh(booking)
        return {
            "id": booking.id,
            "status": booking.status,
            "booker_id": booking.booker_id,
            "resource_id": booking.resource_id,
            "description": booking.description,
            "booked_from": booking.booked_from,
            "booked_to": booking.booked_to,
        }
    except IntegrityError:
        await db.rollback()
        raise HTTPException(status_code=409, detail="Time slot is already booked")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.patch("/book/{operation_id}")
async def cancel_booking(
        operation_id: int,
        user_id: int = Depends(get_current_user),
        db: AsyncSession = Depends(get_db)
):
    operation = await db.get(OperationHistory, operation_id)

    if operation is None:
        raise HTTPException(status_code=404, detail="Booking not found")

    if operation.booker_id != user_id:
        raise HTTPException(status_code=403, detail="You have no rights")

    operation.status = OperationStatus.CANCELED

    await db.commit()
    await db.refresh(operation)
    return {
        "id": operation.id,
        "status": operation.status,
        "booker_id": operation.booker_id,
        "resource_id": operation.resource_id,
        "description": operation.description,
        "booked_from": operation.booked_from,
        "booked_to": operation.booked_to,
    }

@router.get("/book/my")
async def get_my_bookings(
        time_from: datetime = datetime.now().replace(hour=0, minute=0, second=0),
        time_to: datetime = datetime.now().replace(hour=23, minute=59, second=59),
        user_id: int = Depends(get_current_user),
        db: AsyncSession = Depends(get_db)
):
    bookings = await db.scalars(
        select(OperationHistory)
        .where(
            OperationHistory.booker_id == user_id,
            OperationHistory.status.in_([OperationStatus.ACTIVE, OperationStatus.FINISHED]),
            OperationHistory.booked_from < time_to,
            OperationHistory.booked_to > time_from
        ).options(selectinload(OperationHistory.resource))
    )
    return bookings.all()

@router.get("/book/{resource_id}")
async def get_resource_bookings(
        resource_id: int,
        time_from: datetime = datetime.now().replace(hour=0, minute=0, second=0),
        time_to: datetime = datetime.now().replace(hour=23, minute=59, second=59),
        user_id: int = Depends(get_current_user),
        db: AsyncSession = Depends(get_db)
):
    bookings = await db.scalars(
        select(OperationHistory)
        .where(
            OperationHistory.resource_id == resource_id,
            OperationHistory.status.in_([OperationStatus.ACTIVE, OperationStatus.FINISHED]),
            OperationHistory.booked_from < time_to,
            OperationHistory.booked_to > time_from
        ).options(selectinload(OperationHistory.resource))
    )
    return bookings.all()