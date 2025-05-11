from minio_manager import MinioManager
from mongo_manager import MongoManager

class ServiceConnections:
    def __init__(self):
        self.mongo_manager = MongoManager()
        self.minio_manager = MinioManager()

    def get_mongo(self):
        return self.mongo_manager
    
    def get_minio(self):
        return self.minio_manager
    
service_connections = ServiceConnections()