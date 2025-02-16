import torch
from pydantic_settings import BaseSettings
from typing import Optional

class Settings(BaseSettings):
    # API Settings
    API_TITLE: str = "Zonos API"
    API_DESCRIPTION: str = "API for Zonos Text-to-Speech Model"
    API_VERSION: str = "0.1.0"
    
    # Server Settings
    PORT: int = 8012
    WORKERS: int = 4
    
    # Model Settings
    # Model Settings
    MODEL_TYPE: str = "Transformer"  # "Transformer" or "Hybrid"
    MODEL_NAMES: dict = {
        "Transformer": "Zyphra/Zonos-v0.1-transformer",
        "Hybrid": "Zyphra/Zonos-v0.1-hybrid"
    }
    DEVICE: str = "cuda" if torch.cuda.is_available() else "cpu"
    
    # Audio Settings
    SAMPLE_RATE: int = 44100
    MAX_TEXT_LENGTH: int = 1000
    MAX_NEW_TOKENS: int = 86 * 30
    
    # Cache Settings
    MODEL_CACHE_DIR: Optional[str] = None
    
    # Model Type Mapping for Model Loading
#    MODEL_TYPE_MAPPING: dict = {
 #       "Transformer": "transformer",
  #      "Hybrid": "hybrid"
   # }

    class Config:
        env_file = ".env"

settings = Settings()
