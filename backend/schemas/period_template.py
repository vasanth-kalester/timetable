from pydantic import BaseModel
from typing import Optional

class PeriodTemplateBase(BaseModel):
    name: str
    isActive: bool = False

class PeriodTemplateCreate(PeriodTemplateBase):
    pass

class PeriodTemplateUpdate(BaseModel):
    name: Optional[str] = None
    isActive: Optional[bool] = None

class PeriodTemplateResponse(PeriodTemplateBase):
    id: str
    createdAt: Optional[int] = None
    updatedAt: Optional[int] = None

    class Config:
        from_attributes = True
