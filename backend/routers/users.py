from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from core.database import get_db
from core.dependencies import get_current_user
from schemas.auth import UserResponse, ProfileUpdateRequest
from services import auth_service
from models.user import User, Profile
import logging

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/users", tags=["Users"])


@router.get("/me", response_model=UserResponse, summary="Get own profile")
def get_me(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return auth_service.get_me(current_user, db)


@router.patch("/me", response_model=UserResponse, summary="Update own profile")
def update_me(
    update: ProfileUpdateRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    profile = db.query(Profile).filter(Profile.userId == current_user.id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found.")

    if update.first_name is not None:
        profile.firstName = update.first_name.strip()
    if update.last_name is not None:
        profile.lastName = update.last_name.strip()

    db.commit()
    db.refresh(profile)
    logger.info(f"Profile updated for: {current_user.email}")
    return auth_service.get_me(current_user, db)
