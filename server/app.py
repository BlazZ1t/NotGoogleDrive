from fastapi import FastAPI
from initialize import service_connections

from routes.auth import router as auth_router
from routes.requests import router as files_router

app = FastAPI()  
app.include_router(auth_router)
app.include_router(files_router)

@app.get("/")
async def root():
    return {"message": "Running"}
