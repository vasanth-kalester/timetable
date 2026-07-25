from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from models.user import User, Profile, Department
from core.security import verify_password, create_access_token, create_refresh_token, decode_token
from schemas.auth import LoginRequest, TokenResponse, UserResponse
from services.permission_service import get_permissions_for_role
from jose import JWTError
import logging

logger = logging.getLogger(__name__)


def _build_user_response(user: User, profile, department) -> UserResponse:
    first_name = profile.firstName if profile else None
    last_name = profile.lastName if profile else None
    full_name = " ".join(filter(None, [first_name, last_name])) or user.email.split("@")[0]

    return UserResponse(
        id=user.id,
        email=user.email,
        role=user.role,
        first_name=first_name,
        last_name=last_name,
        full_name=full_name,
        approval_status=user.approvalStatus,
        college_id=profile.collegeId if profile else None,
        department_id=profile.departmentId if profile else None,
        permissions=get_permissions_for_role(user.role),
    )


def login(request: LoginRequest, db: Session) -> TokenResponse:
    identifier = request.identifier.strip().lower()
    user = db.query(User).filter(User.email == identifier).first()

    if user is None:
        logger.warning(f"Login attempt with unknown identifier: {identifier}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="No account found with this email or ID.",
        )

    if not verify_password(request.password, user.passwordHash):
        logger.warning(f"Failed login attempt for: {user.email}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect password. Please try again.",
        )

    if user.approvalStatus == "rejected":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Your account has been rejected. Contact the administrator.",
        )

    profile = db.query(Profile).filter(Profile.userId == user.id).first()
    department = None
    if profile and profile.departmentId:
        department = db.query(Department).filter(Department.id == profile.departmentId).first()

    token_data = {"sub": user.id, "role": user.role}
    access_token = create_access_token(token_data)
    refresh_token = create_refresh_token(token_data)

    logger.info(f"Successful login: {user.email} ({user.role})")
    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        user=_build_user_response(user, profile, department),
    )


def refresh_access_token(refresh_token: str, db: Session) -> TokenResponse:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Invalid or expired refresh token.",
    )
    try:
        payload = decode_token(refresh_token)
        if payload.get("type") != "refresh":
            raise credentials_exception
        user_id: str = payload.get("sub")
    except JWTError:
        raise credentials_exception

    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise credentials_exception

    profile = db.query(Profile).filter(Profile.userId == user.id).first()
    department = None
    if profile and profile.departmentId:
        department = db.query(Department).filter(Department.id == profile.departmentId).first()

    token_data = {"sub": user.id, "role": user.role}
    new_access = create_access_token(token_data)
    new_refresh = create_refresh_token(token_data)

    return TokenResponse(
        access_token=new_access,
        refresh_token=new_refresh,
        user=_build_user_response(user, profile, department),
    )


def get_me(user: User, db: Session) -> UserResponse:
    profile = db.query(Profile).filter(Profile.userId == user.id).first()
    department = None
    if profile and profile.departmentId:
        department = db.query(Department).filter(Department.id == profile.departmentId).first()
    return _build_user_response(user, profile, department)
