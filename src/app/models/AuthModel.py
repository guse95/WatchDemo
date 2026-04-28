from pydantic import BaseModel, EmailStr

class RegistrationData(BaseModel):
    email: EmailStr
    password: str
    username: str | None
    user_agent: str | None


class LoginData(BaseModel):
    email: EmailStr
    password: str
    user_agent: str | None


class AuthTokens(BaseModel):
    access_token: str
    refresh_token: str


class WhoisInfo(BaseModel):
    email: EmailStr
    id: int
    pass_level: int