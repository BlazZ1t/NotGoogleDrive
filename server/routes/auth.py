import os
import re
from datetime import datetime, timedelta
from jose import JWTError, jwt
from fastapi import APIRouter, Depends, HTTPException, Body, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from dotenv import load_dotenv

from typing import Union

from initialize import service_connections
from mongo_manager import MongoManager
from minio_manager import MinioManager

from models.schemas import UserCreate, AccessTokenResponse, TokenResponse, LoginRequest




router = APIRouter()

load_dotenv()
SECRET_KEY = os.getenv('JWT_KEY')
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30


@router.post("/register", status_code=201)
async def register(user: UserCreate, mongo: MongoManager = Depends(service_connections.get_mongo), minio: MinioManager = Depends(service_connections.get_minio)):
    if mongo.user_exists(user.username):
        raise HTTPException(status_code=409, detail="Username already exists")
    try:
        mongo.create_user(user.username, user.password)
    except Exception as e:
        raise HTTPException(status_code=500, detail={f"Could not create a database record for a user {e}"})
    
    try:
        bucket_name = mongo.get_bucket_name(user.username)
        minio.create_bucket(bucket_name)
    except Exception as e:
        mongo.delete_user(user.username)
        raise HTTPException(status_code=500, detail=f"Could not create a bucket for a user {e}")
    
    

    return {"message": "User registered"}

@router.post("/login", response_model=Union[AccessTokenResponse, TokenResponse])
async def login(
    credentials: LoginRequest,
    mongo: MongoManager = Depends(service_connections.get_mongo)
):
    user = mongo.get_user(credentials.username)
    if not user or not mongo.verify_user(credentials.username, credentials.password):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    access_token = create_access_token(
        data={"sub": user["username"]},
        expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    )

    if credentials.remember_me:
        refresh_token = create_access_token(
            data={"sub": user["username"]},
        )
        return TokenResponse(access_token=access_token, refresh_token=refresh_token)



    return AccessTokenResponse(access_token=access_token)

@router.post("/refresh", response_model=AccessTokenResponse)
async def refresh(refresh_token: str = Body(...)):
    try:
        payload = jwt.decode(refresh_token, SECRET_KEY, algorithms=[ALGORITHM])
        username = payload.get("sub")
        if not username:
            raise HTTPException(status_code=401, detail="Invalid token")
        
        new_token = create_access_token({"sub": username}, timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))

        return AccessTokenResponse(access_token=new_token)
    
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid or expired refresh token")


def create_access_token(data: dict, expires_delta: timedelta = timedelta(days=7)):
    to_encode = data.copy()
    expire = datetime.now() + expires_delta
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)