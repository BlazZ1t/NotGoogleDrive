from fastapi import APIRouter, Depends, File, UploadFile, HTTPException, status
from fastapi.responses import StreamingResponse
from starlette.background import BackgroundTask
from fastapi.security import OAuth2PasswordBearer
from jose import jwt, JWTError
import os
from dotenv import load_dotenv
from initialize import service_connections
from minio_manager import MinioManager
from mongo_manager import MongoManager

load_dotenv()
router = APIRouter()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")

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
        minio: MinioManager = Depends(service_connections.get_minio)
):
    try: 
        contents = await file.read()
        minio.upload_file(
            bucket_name=username,
            file_obj=UploadFileToBinaryIO(file, contents),
            object_name=file.filename,
            content_type=file.content_type
        )
        return {"message": f"File {file.filename} uploaded successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"File upload failed: {str(e)}")
    


@router.get("/download/{filename}")
async def download_file(
    filename: str,
    username: str = Depends(get_current_user),
    minio: MinioManager = Depends(service_connections.get_minio)
):
    try:
        file_stream = minio.download_file(username, filename)

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