from pydantic_settings import BaseSettings
from typing import List
import json
import os


class Settings(BaseSettings):
    DATABASE_URL: str = "sqlite:///../web_client/prisma/dev.db"
    JWT_SECRET_KEY: str = "super-secret-jwt-key-change-in-production-min-32-chars"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    APP_NAME: str = "EduFlow API"
    APP_VERSION: str = "1.0.0"
    CORS_ORIGINS: str = '["http://localhost:3001","http://192.168.0.110:3001","http://192.168.0.110:8000"]'

    @property
    def cors_origins_list(self) -> List[str]:
        return json.loads(self.CORS_ORIGINS)

    class Config:
        env_file = ".env"
        extra = "ignore"


settings = Settings()
