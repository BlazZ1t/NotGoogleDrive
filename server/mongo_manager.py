import os
import hashlib
from dotenv import load_dotenv
from typing import Optional

from pymongo import MongoClient
from pymongo.collection import Collection
from pymongo.database import Database
from pymongo.errors import PyMongoError

from passlib.context import CryptContext

class MongoManager:
    def __init__(self):
        load_dotenv()
        self.pwd_context = CryptContext(schemes=['bcrypt'])
        mongo_host = os.getenv("MONGO_HOST", "mongodb")
        mongo_port = os.getenv("MONGO_PORT", "27017")
        mongo_dbname = os.getenv("MONGO_DBNAME", "app_db")

        uri = f"mongodb://{mongo_host}:{mongo_port}/"

        self.client: MongoClient = MongoClient(uri)
        self.db: Database = self.client[mongo_dbname]
        self.users: Collection = self.db["users"]

        try:
            self.client.admin.command('ping')
        except PyMongoError as e:
            raise ConnectionError(f"MongoDB connection failed: {e}")

        self.users.create_index("username", unique=True)

    def hash_username(self, username: str) -> str:
        return hashlib.sha256(username.encode()).hexdigest()[:32]

    
    def create_user(self, username: str, password: str) -> bool:
        print(f"Got a request to register user {username} with password {password}")
        if self.users.find_one({"username": username}):
            return False
        hashed_pw = self.pwd_context.hash(password)
        bucket_name = self.hash_username(username)
        self.users.insert_one({
            "username": username,
            "password": hashed_pw,
            "bucket": bucket_name
            })
        return True
    

    
    def verify_user(self, username: str, password: str) -> Optional[dict]:
        user = self.get_user(username)
        if user and self.pwd_context.verify(password, user["password"]):
            return user
    
    def get_user(self, username: str) -> Optional[dict]:
        return self.users.find_one({"username": username})
    
    def get_bucket_name(self, username: str) -> Optional[str]:
        user = self.get_user(username)
        return user.get("bucket") if user else None
    
    def user_exists(self, username: str) -> bool:
        return self.users.count_documents({"username": username}, limit=1) > 0
    
    def add_refresh_token(self, username: str, token: str):
        self.users.update_one({"username": username}, {"$addToSet": {"refresh_tokens": token}})

    def remove_refresh_token(self, username: str, token: str):
        self.users.update_one({"username": username}, {"$pull": {"refresh_tokens": token}})

    def is_refresh_token_valid(self, username: str, token: str) -> bool:
        user = self.get_user(username)
        return token in user.get("refresh_tokens", []) if user else False

