from fastapi import APIRouter, Depends, File, UploadFile, HTTPException, Query, Body, status
from fastapi.responses import StreamingResponse
from starlette.background import BackgroundTask
from fastapi.security import OAuth2PasswordBearer
from jose import jwt, JWTError
import os
from dotenv import load_dotenv
from initialize import service_connections
from minio_manager import MinioManager
from minio.error import S3Error
from mongo_manager import MongoManager
from typing import Optional, List, Union
from models.schemas import FileMetadata, FolderMetadata, MoveRequest

load_dotenv()
router = APIRouter()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

SECRET_KEY = os.getenv('JWT_KEY')
ALGORITHM = "HS256"

def get_current_user(token: str = Depends(oauth2_scheme)):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username = payload.get("sub")
        if username is None:
            raise HTTPException(status_code=401, detail="Invalid credentials")
        return username
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    


@router.post("/upload")
async def upload(
        file: UploadFile = File(...),
        username: str = Depends(get_current_user),
        minio: MinioManager = Depends(service_connections.get_minio),
        mongo: MongoManager = Depends(service_connections.get_mongo)
):
    try: 
        contents = await file.read()
        bucket_name = mongo.get_bucket_name(username)
        minio.upload_file(
            bucket_name=bucket_name,
            file_obj=UploadFileToBinaryIO(file, contents),
            object_name=file.filename,
            content_type=file.content_type
        )
        return {"message": f"File {file.filename} uploaded successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"File upload failed: {str(e)}")
    


@router.get("/download")
async def download_file(
    filename: str = Query(..., min_length=1, description="Full path to the file"),
    username: str = Depends(get_current_user),
    minio: MinioManager = Depends(service_connections.get_minio),
    mongo: MongoManager = Depends(service_connections.get_mongo)
):
    bucket_name = mongo.get_bucket_name(username)
    try:
        file_stream = minio.download_file(bucket_name=bucket_name, object_name=filename)

        def close_stream():
            file_stream.close()

        return StreamingResponse(
            content=file_stream,
            media_type="application/octet-stream",
            headers={"Content-Disposition": f'attachment; filename="{filename}"'},
            background=BackgroundTask(close_stream)
        )
    except Exception as e:
        raise HTTPException(status_code=404, detail=f"Could not download file: {str(e)}")
    
@router.get("/list", response_model=List[Union[FileMetadata, FolderMetadata]])
async def list_files(
    path: Optional[str] = Query(default=""),
    username: str = Depends(get_current_user),
    minio: MinioManager = Depends(service_connections.get_minio),
    mongo: MongoManager = Depends(service_connections.get_mongo)
):
    try:
        bucket_name = mongo.get_bucket_name(username)

        prefix = f"{path.strip('/')}/" if path else ""
        
        return minio.list_user_objects(bucket_name, prefix)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Could not retrieve objects: {e}")
    
@router.get("/search", response_model=List[FileMetadata])
async def search_files(
    query: str = Query(..., min_length=1),
    username: str = Depends(get_current_user),
    minio: MinioManager = Depends(service_connections.get_minio),
    mongo: MongoManager = Depends(service_connections.get_mongo)
):
    try:
        bucket_name = mongo.get_bucket_name(username)

        return minio.search_files(bucket_name, query)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Search failed: {e}")

@router.put("/move_file")
async def move_file(
    move_request: MoveRequest = Body(...),
    username: str = Depends(get_current_user),
    minio: MinioManager = Depends(service_connections.get_minio),
    mongo: MongoManager = Depends(service_connections.get_mongo)
):
    bucket_name = mongo.get_bucket_name(username)
    try:
        minio.move_file(
            bucket_name,
            move_request.source_path,
            move_request.destination_path
        )
        return {"message": f"Moved '{move_request.source_path}' to '{move_request.destination_path}'"}
    
    except S3Error as e:
        raise HTTPException(status_code=500, detail=f"MinIO error: {e}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Could not update a file: {e}")
    
    
@router.delete("/delete_file")
async def delete_file(
    filename: str = Query(..., description="Full path name"),
    username: str = Depends(get_current_user),
    minio: MinioManager = Depends(service_connections.get_minio),
    mongo: MongoManager = Depends(service_connections.get_mongo)
):
    bucket_name = mongo.get_bucket_name(username)
    try:
        minio.delete_file(bucket_name=bucket_name, object_name=filename)

        return {"message": f"File {filename} deleted"}

    except S3Error as e:
        if e.code == "NoSuchKey":
            raise HTTPException(status_code=404, detail="File not found")
        raise HTTPException(status_code=500, detail=f"MinIO error: {e}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Could not delete a file: {e}")
    


class UploadFileToBinaryIO:
    def __init__(self, upload_file: UploadFile, content: bytes):
        from io import BytesIO
        self.stream = BytesIO(content)
        self.filename = upload_file.filename

    def seek(self, offset, whence=0):
        return self.stream.seek(offset, whence)
    
    def tell(self):
        return self.stream.tell()
    
    def read(self, size=-1):
        return self.stream.read(size)