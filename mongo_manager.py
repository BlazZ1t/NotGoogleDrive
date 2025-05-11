import os
from dotenv import load_dotenv
from typing import Optional
from pymongo import MongoClient
from pymongo.collection import Collection
from pymongo.database import Database
from pymongo.errors import PyMongoError

class MongoManager:
    def __init__(self):
        load_dotenv()

        mongo_user = os.getenv('MONGO_USER')
        mongo_password = os.getenv('MONGO_PASSWORD')
        mongo_host = os.getenv("MONGO_HOST", "localhost")
        mongo_port = os.getenv("MONGO_PORT", "27017")
        mongo_dbname = os.getenv("MONGO_DBNAME", "app_db")

        uri = f"mongodb://{mongo_user}:{mongo_password}@{mongo_host}:{mongo_port}/"

        self.client: MongoClient = MongoClient(uri)
        self.db: Database = self.client[mongo_dbname]
        self.users: Collection = self.db["users"]

        try:
            self.client.admin.command('ping')
        except PyMongoError as e:
            raise ConnectionError(f"MongoDB connection failed: {e}")

        self.users.create_index("username", unique=True)

    
    def create_user(self, username: str, password: str) -> bool:

        if self.users.find_one({"username": username}):
            return False
        
        self.users.insert_one({"username": username, "password": password})
        return True
    
    def get_user(self, username: str) -> Optional[dict]:
        return self.users.find_one({"username": username})
    
    def user_exists(self, username: str) -> bool:
        return self.users.count_documents({"username": username}, limit=1) > 0

