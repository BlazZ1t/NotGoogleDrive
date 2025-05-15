from pydantic import BaseModel
from datetime import datetime

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

class FileMetadata(BaseModel):
    name: str
    type: str
    size: int
    last_modified: datetime

class FolderMetadata(BaseModel):
    name: str
    is_folder: bool = True

class MoveRequest(BaseModel):
    source_path: str
    destination_path: str