from fastapi import FastAPI
from initialize import service_connections

from routes.auth import router as auth_router
from routes.file_requests import router as files_router
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    docs_url=None,
    redoc_url=None,
    openapi_url=None
)  
app.include_router(auth_router)
app.include_router(files_router)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
async def root():
    return {"message": "Running"}
