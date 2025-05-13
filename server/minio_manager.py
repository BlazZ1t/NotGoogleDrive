import os
import re
from dotenv import load_dotenv
from minio import Minio
from minio.error import S3Error
from io import BufferedReader
from typing import BinaryIO


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




    def list_user_objects(self, bucket_name):
        bucket_name = self.sanitize_bucket_name(bucket_name)
        return [obj.object_name for obj in self.client.list_objects(bucket_name)]
    

    
    def download_file(
            self,
            bucket_name: str,
            object_name: str,
    ) -> BufferedReader:
        bucket_name = self.sanitize_bucket_name(bucket_name)

        return self.client.get_object(bucket_name, object_name)
    

    def delete_file(self, bucket_name, object_name):
        bucket_name = self.sanitize_bucket_name(bucket_name)
        self.client.remove_object(bucket_name, object_name)
        print(f"{object_name} deleted from bucket {bucket_name}")

    
