from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session as DBSession
from typing import List

from core.database import get_db
from models.constraint import ConstraintConfiguration
from schemas.constraint import ConstraintConfigurationResponse, ConstraintConfigurationUpdate

router = APIRouter(
    prefix="/api/v1/constraints",
    tags=["Constraints"]
)

@router.get("/", response_model=List[ConstraintConfigurationResponse])
def get_constraints(db: DBSession = Depends(get_db)):
    """
    Get all constraint configurations.
    """
    return db.query(ConstraintConfiguration).all()

@router.put("/{constraint_id}", response_model=ConstraintConfigurationResponse)
def update_constraint(constraint_id: str, update_data: ConstraintConfigurationUpdate, db: DBSession = Depends(get_db)):
    """
    Update a constraint configuration (e.g., toggle active, change weight, update parameters).
    """
    constraint = db.query(ConstraintConfiguration).filter(ConstraintConfiguration.id == constraint_id).first()
    if not constraint:
        raise HTTPException(status_code=404, detail="Constraint not found")
        
    update_dict = update_data.model_dump(exclude_unset=True)
    for key, value in update_dict.items():
        setattr(constraint, key, value)
        
    db.commit()
    db.refresh(constraint)
    return constraint
