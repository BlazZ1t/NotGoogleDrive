from fastapi import FastAPI
from initialize import service_connections
from contextlib import asynccontextmanager

from auth import router as auth_router

def get_mongo():
    return service_connections.get_mongo()

def get_minio():
    return service_connections.get_minio()

app = FastAPI()  
app.include_router(auth_router)

@app.get("/")
async def root():
    return {"message": "Running"}
