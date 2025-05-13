import os
import re
from datetime import datetime, timedelta
from jose import JWTError, jwt
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from dotenv import load_dotenv

from initialize import service_connections
from mongo_manager import MongoManager
from minio_manager import MinioManager

from models.schemas import UserCreate, TokenResponse




router = APIRouter()

load_dotenv()
SECRET_KEY = os.getenv('JWT_KEY')
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30


@router.post("/register", status_code=201)
def register(user: UserCreate, mongo: MongoManager = Depends(service_connections.get_mongo), minio: MinioManager = Depends(service_connections.get_minio)):
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

@router.post("/login", response_model=TokenResponse)
def login(form_data: OAuth2PasswordRequestForm = Depends(), mongo: MongoManager = Depends(service_connections.get_mongo)):
    user = mongo.get_user(form_data.username)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    user = mongo.verify_user(form_data.username, form_data.password)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    access_token = create_access_token(
        data={"sub": user["username"]},
        expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    )

    return {"access_token": access_token, "token_type": "bearer"}


oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")

def create_access_token(data: dict, expires_delta: timedelta = None):
    to_encode = data.copy()
    expire = datetime.now() + (expires_delta or timedelta(minutes=15))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)