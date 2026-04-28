from enum import Enum
from pydantic import BaseModel, EmailStr

class ResourceType (Enum):
    ROOM = "room"
    LAPTOP = "laptop"
    PROJECTOR = "projector"
    BOARD = "board"

class EditResourceData(BaseModel):
    id: int
    name: str | None
    type: ResourceType | None
    description: str | None
    extra_attributes: dict | None

class ResourceData(BaseModel):
    name: str
    type: ResourceType
    description: str
    extra_attributes: dict | None

class ResourceDTO(ResourceData):
    id: int