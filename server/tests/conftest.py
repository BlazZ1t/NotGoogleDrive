import os
import sys
import pytest
import mongomock
from passlib.context import CryptContext

# 0) Test packet search
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

# 1) Variables of enviroment for test
os.environ.update({
    "MONGO_HOST":       "localhost",
    "MONGO_PORT":       "27017",
    "MONGO_DBNAME":     "test_db",
    "MINIO_ENDPOINT":   "localhost:9000",
    "MINIO_ACCESS_KEY": "test",
    "MINIO_SECRET_KEY": "test",
    "MINIO_BUCKET":     "test_bucket",
    "JWT_KEY":          "testsecret",
})

# 2) Patching of MongoManager.__init__ and adding delete_user
import mongo_manager
def _dummy_mongo_init(self):
    self.pwd_context = CryptContext(schemes=['bcrypt'])
    client = mongomock.MongoClient()
    self.client = client
    self.db     = client[os.getenv("MONGO_DBNAME")]
    self.users  = self.db["users"]
    self.users.create_index("username", unique=True)
    self.delete_user = lambda username: self.users.delete_one({"username": username})
mongo_manager.MongoManager.__init__ = _dummy_mongo_init

# 3) Patch MinioManager - completely mute init, create_bucket, 
#    as well as upload_file and list_user_objects
import minio_manager
class _DummyMinioClient:
    def __init__(self, *args, **kwargs): pass
    def fput_object(self, *args, **kwargs): return None
    def get_object(self, *args, **kwargs):   return b""
    def list_objects(self, *args, **kwargs): return []

def _dummy_minio_init(self):
    self.client = _DummyMinioClient()
    self.bucket = os.getenv("MINIO_BUCKET", "test_bucket")

minio_manager.MinioManager.__init__ = _dummy_minio_init
minio_manager.MinioManager.create_bucket      = lambda self, name: None
minio_manager.MinioManager.upload_file        = lambda self, bucket_name, file_obj, object_name, content_type: None
minio_manager.MinioManager.list_user_objects  = lambda self, bucket_name, prefix="": []

# 4) Importing of the application and giving the client a fake
from fastapi.testclient import TestClient
from app import app

@pytest.fixture
def client():
    return TestClient(app)
