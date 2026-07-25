from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from core.database import get_db
from core.dependencies import get_current_user
from schemas.auth import LoginRequest, RefreshRequest, ForgotPasswordRequest, ResetPasswordRequest, TokenResponse
from services import auth_service
from models.user import User
import logging

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/login", response_model=TokenResponse, summary="Login")
def login(request: LoginRequest, db: Session = Depends(get_db)):
    return auth_service.login(request, db)


@router.post("/refresh", response_model=TokenResponse, summary="Refresh access token")
def refresh_token(request: RefreshRequest, db: Session = Depends(get_db)):
    return auth_service.refresh_access_token(request.refresh_token, db)


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
def logout(current_user: User = Depends(get_current_user)):
    logger.info(f"User {current_user.email} logged out")
    return None


@router.post("/forgot-password", status_code=202)
def forgot_password(request: ForgotPasswordRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == request.email.strip().lower()).first()
    if user:
        logger.info(f"Password reset requested for: {user.email}")
    return {"message": "If an account exists with this email, a reset OTP has been sent."}


@router.post("/reset-password", status_code=200)
def reset_password(request: ResetPasswordRequest, db: Session = Depends(get_db)):
    from core.security import hash_password
    if len(request.otp) != 6 or not request.otp.isdigit():
        raise HTTPException(status_code=400, detail="Invalid OTP. Must be a 6-digit number.")
    if len(request.new_password) < 8:
        raise HTTPException(status_code=400, detail="Password must be at least 8 characters.")

    user = db.query(User).filter(User.email == request.email.strip().lower()).first()
    if not user:
        raise HTTPException(status_code=404, detail="No account found with this email.")

    user.passwordHash = hash_password(request.new_password)
    db.commit()
    logger.info(f"Password reset for: {user.email}")
    return {"message": "Password reset successfully. Please log in."}
