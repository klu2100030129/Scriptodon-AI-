from pydantic_settings import BaseSettings
from typing import List
import os

class Settings(BaseSettings):
    # Database
    DATABASE_URL: str = "sqlite:///./scritodon.db"
    
    # OpenRouter API Configuration
    OPENROUTER_API_KEY: str = "your_openrouter_api_key_here"
    OPENROUTER_SITE_URL: str = "http://13.232.134.97:8000"
    OPENROUTER_SITE_NAME: str = "Scriptodon Test Automation Platform"
    
    # Jira Configuration
    JIRA_SERVER_URL: str = "your_jira_server_url_here"
    JIRA_USERNAME: str = "your_jira_username_here"
    JIRA_API_TOKEN: str = "your_jira_api_token_here"
    
    # File Upload
    UPLOAD_DIR: str = "uploads"
    MAX_FILE_SIZE: int = 10485760  # 10MB in bytes
    
    # CORS Configuration
    BACKEND_CORS_ORIGINS: List[str] = [
        "http://13.232.134.97",
        "http://13.232.134.97:3000",
        "http://13.232.134.97:80",
        "http://13.232.134.97:8000"
    ]
    
    class Config:
        env_file = ".env"
        extra = "ignore"  # Allow extra fields to be ignored
        alias_generator = lambda string: string.lower()  # Map uppercase to lowercase

settings = Settings() 