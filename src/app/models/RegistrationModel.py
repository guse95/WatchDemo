from pydantic import BaseModel, EmailStr


class UserData(BaseModel):
    email: EmailStr
    password: str
    pass_level: int
    username: str | None

class UserDataDB(BaseModel):
    id: int
    email: EmailStr
    pass_level: int
    username: str | None