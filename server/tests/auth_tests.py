from fastapi import HTTPException
from fastapi.testclient import TestClient
from app import app
from models.schemas import UserCreate
from initialize import service_connections

client = TestClient(app)

async def test_register_success(mocker):
    mock_mongo = mocker.MagicMock()
    mock_minio = mocker.MagicMock()

    mock_mongo.user_exists.return_value = False
    mock_mongo.get_bucket_name.return_value = "test-bucket"

    app.dependency_overrides[service_connections.get_mongo] = lambda: mock_mongo
    app.dependency_overrides[service_connections.get_minio] = lambda: mock_minio

    response = await client.post("/register", json={"username": "testuser", "password": "testpass"})

    assert response == {"message": "User registered"}
    mock_mongo.user_exists.assert_called_once_with("testuser")
    mock_mongo.create_user.assert_called_once_with("testuser", "password123")
    mock_mongo.get_bucket_name.assert_called_once_with("testuser")
    mock_minio.create_bucket.assert_called_once_with("test-bucket")

# @pytest.mark.asyncio
# async def test_register_username_exists(mocker):
#     mock_mongo = mocker.MagicMock()
#     mock_minio = mocker.MagicMock()
#     mock_mongo.user_exists.return_value = True

#     user = UserCreate(username="existinguser", password="password123")

#     with pytest.raises(HTTPException) as exc_info:
#         await register(user=user, mongo=mock_mongo, minio=mock_minio)

#     assert exc_info.value.status_code == 409
#     assert exc_info.value.detail == "Username already exists"
#     mock_mongo.user_exists.assert_called_once_with("existinguser")
#     mock_mongo.create_user.assert_not_called()
#     mock_minio.create_bucket.assert_not_called()