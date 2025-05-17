import os
import pytest
from fastapi.testclient import TestClient
import mongomock
from app import app
from initialize import service_connections
import mongo_manager, minio_manager

@pytest.fixture(scope="session", autouse=True)
def env_vars():
    # Creatins tetsting values of enviroment 
    os.environ["MONGO_URI"] = "mongodb://localhost:27017"
    os.environ["MONGO_DB"] = "test_db"
    os.environ["MINIO_ENDPOINT"] = "localhost:9000"
    os.environ["MINIO_ACCESS_KEY"] = "test"
    os.environ["MINIO_SECRET_KEY"] = "test"
    yield

@pytest.fixture(scope="session", autouse=True)
def mock_services(monkeypatch):
    # Mock the MongoDB client with mongomock
    mock_client = mongomock.MongoClient()
    monkeypatch.setattr(mongo_manager, "client", mock_client)
    monkeypatch.setattr(mongo_manager, "db", mock_client[test_db := os.getenv("MONGO_DB")])
    # Mock MinIO on the free stub-object
    class DummyMinIO:
        def __init__(self, *args, **kwargs): pass
        def fput_object(self, *args, **kwargs): return None
        def get_object(self, *args, **kwargs): return b""
        def list_objects(self, *args, **kwargs): return []
    monkeypatch.setattr(minio_manager, "client", DummyMinIO())

    # Services initialisation
    service_connections()
    yield

@pytest.fixture()
def client():
    return TestClient(app)
