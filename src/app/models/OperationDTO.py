from datetime import datetime
from pydantic import BaseModel
from app.models.OperationStatus import OperationStatus


class OperationDTO(BaseModel):
    id: int
    booker_id: int
    resource_id: int
    status: OperationStatus
    created_at: datetime
    last_update_at: datetime
    booked_from: datetime
    booked_to: datetime