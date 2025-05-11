from fastapi import FastAPI
from minio_manager import MinioManager
from mongo_manager import MongoManager
from contextlib import asynccontextmanager

app = FastAPI()

minio: MinioManager = None
mongo: MongoManager = None

@asynccontextmanager
async def lifespan(app: FastAPI):
    global minio, mongo
    mongo = MongoManager()
    print("Mongo connected")
    minio = MinioManager()
    print("Minio connected")
    
    yield

app = FastAPI(lifespan=lifespan)
    

@app.get("/")
async def root():
    return {"message": "Running"}