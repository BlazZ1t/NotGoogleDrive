from pydantic import BaseModel

class LoginRequest(BaseModel):
    username: str
    password: str
    remember_me: bool = False

class UserCreate(BaseModel):
    username: str
    password: str

class AccessTokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"

class TokenResponse(AccessTokenResponse):
    refresh_token: str