from pydantic import BaseModel, EmailStr
from typing import Optional, List


class LoginRequest(BaseModel):
    """Request body for /auth/login."""
    identifier: str   # email, employee ID, or student roll number
    password: str


class RefreshRequest(BaseModel):
    """Request body for /auth/refresh."""
    refresh_token: str


class ForgotPasswordRequest(BaseModel):
    """Request body for /auth/forgot-password."""
    email: str


class ResetPasswordRequest(BaseModel):
    """Request body for /auth/reset-password."""
    email: str
    otp: str
    new_password: str


class UserResponse(BaseModel):
    """User data returned in login responses and /users/me."""
    id: str
    email: str
    role: str
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    full_name: str
    approval_status: str
    college_id: Optional[str] = None
    department_id: Optional[str] = None
    permissions: List[str] = []

    class Config:
        from_attributes = True


class TokenResponse(BaseModel):
    """Token response returned after successful authentication."""
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user: UserResponse


class ProfileUpdateRequest(BaseModel):
    """Request body for PATCH /users/me."""
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    phone: Optional[str] = None
