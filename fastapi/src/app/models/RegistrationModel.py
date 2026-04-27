from pydantic import BaseModel, EmailStr


class UserData(BaseModel):
    email: EmailStr
    username: str
    login: str
    pass_level: int

class UserDataDB(UserData):
    id: int