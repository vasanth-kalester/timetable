from pydantic import BaseModel
from typing import Optional

class ConstraintConfigurationBase(BaseModel):
    code: str
    name: str
    description: Optional[str] = None
    type: str = "hard"
    isActive: bool = True
    weight: int = 1
    parameters: Optional[str] = None

class ConstraintConfigurationCreate(ConstraintConfigurationBase):
    pass

class ConstraintConfigurationUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    isActive: Optional[bool] = None
    weight: Optional[int] = None
    parameters: Optional[str] = None

class ConstraintConfigurationResponse(ConstraintConfigurationBase):
    id: str
    createdAt: Optional[int] = None
    updatedAt: Optional[int] = None

    class Config:
        from_attributes = True
