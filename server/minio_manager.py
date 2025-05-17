import os
import re
from dotenv import load_dotenv
from minio import Minio
from minio.error import S3Error
from minio.commonconfig import CopySource
from io import BufferedReader
from typing import BinaryIO
from models.schemas import FileMetadata, FolderMetadata


class MinioManager:
    def __init__(self):
        load_dotenv()

        access_key = os.getenv('ACCESS_KEY')
        secret_key = os.getenv('SECRET_KEY')
        minio_url = os.getenv('MINIO_URL')

        self.client = Minio(
            minio_url,
            access_key=access_key,
            secret_key=secret_key,
            secure=False
        )

        try:
            self.client.list_buckets()
        except S3Error as e:
            raise ConnectionError(f"MinIO connection failed: {e}")

    def sanitize_bucket_name(self, bucket_name: str) -> str:
        bucket_name = re.sub(r"[^a-zA-Z0-9\-\.]", "-", bucket_name)

        return bucket_name
    


    def create_bucket(self, bucket_name):
        bucket_name = self.sanitize_bucket_name(bucket_name)
        if not self.client.bucket_exists(bucket_name):
            self.client.make_bucket(bucket_name)
            return True
        else:
            return False
        
    def create_folder(
      self,
      bucket_name,
      path_to_folder      
    ):
        bucket_name = self.sanitize_bucket_name(bucket_name)

        if not self.client.bucket_exists(bucket_name):
            raise Exception(f"Bucket '{bucket_name}' doesn't exist")
        
        self.client.put_object(bucket_name, path_to_folder, data=b"", length=0)
        
    def upload_file(
            self,
            bucket_name: str,
            file_obj: BinaryIO,
            object_name: str,
            content_type: str = "application/octet-stream"
    ) -> None:
        bucket_name = self.sanitize_bucket_name(bucket_name)

        if not self.client.bucket_exists(bucket_name):
            raise Exception(f"Bucket '{bucket_name}' does not exist.")
        
        file_obj.seek(0, os.SEEK_END)
        file_size = file_obj.tell()
        file_obj.seek(0)

        self.client.put_object(
            bucket_name=bucket_name,
            object_name=object_name,
            data=file_obj,
            length=file_size,
            content_type=content_type
        )

        print(f"Uploaded '{object_name}' to bucket '{bucket_name}'.") 




    def list_user_objects(self, bucket_name, path):
        bucket_name = self.sanitize_bucket_name(bucket_name)
        if path and not path.endswith("/"):
            path += "/"

        objects = self.client.list_objects(bucket_name, prefix=path, recursive=False)

        result = []
        seen_folders = set()

        for obj in objects:
            relative_path = obj.object_name[len(path):]
            if "/" in relative_path:
                folder_name = relative_path.split("/")[0]
                if folder_name not in seen_folders:
                    seen_folders.add(folder_name)
                    result.append(FolderMetadata(name=folder_name))
            else:
                result.append(FileMetadata(
                    name=obj.object_name,
                    type=os.path.splitext(obj.object_name)[1].lstrip('.').lower(),
                    size=obj.size,
                    last_modified=obj.last_modified
                ))

        return result
    
    def search_files(self, bucket_name: str, query: str):
        bucket_name = self.sanitize_bucket_name(bucket_name)

        all_objects = self.client.list_objects(bucket_name, recursive=True)

        matching_objects = [
            FileMetadata(
                name=obj.object_name,
                type=os.path.splitext(obj.object_name)[1].lstrip('.').lower(),
                size=obj.size,
                last_modified=obj.last_modified
            )
            for obj in all_objects
            if query.lower() in os.path.basename(obj.object_name).lower()
        ]

        return matching_objects
    

    
    def download_file(
            self,
            bucket_name: str,
            object_name: str,
    ) -> BufferedReader:
        bucket_name = self.sanitize_bucket_name(bucket_name)

        return self.client.get_object(bucket_name, object_name)
    
    def move_file(
            self,
            bucket_name: str,
            source_path: str,
            destination_path: str
    ):
        bucket_name = self.sanitize_bucket_name(bucket_name)

        source = CopySource(bucket_name=bucket_name, object_name=source_path)

        self.client.copy_object(
            bucket_name=bucket_name,
            object_name=destination_path,
            source=source
        )

        self.client.remove_object(bucket_name, source_path)

        print(f"Moved {source_path} -> {destination_path} in bucket {bucket_name}")

    
    def delete_folder(self, bucket_name, folder_path):
        bucket_name = self.sanitize_bucket_name(bucket_name)
        objects_to_delete = self.client.list_objects(bucket_name, prefix=folder_path, recursive=True)

        for obj in objects_to_delete:
            self.client.remove_object(bucket_name, obj.object_name)
    

    def delete_file(self, bucket_name, object_name):
        bucket_name = self.sanitize_bucket_name(bucket_name)
        self.client.remove_object(bucket_name, object_name)
        print(f"{object_name} deleted from bucket {bucket_name}")

    
