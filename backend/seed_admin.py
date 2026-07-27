import sys
import os
import time

# Ensure the backend directory is in sys.path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from core.database import SessionLocal
from core.security import hash_password
from models.user import User, Profile
import uuid

def seed_super_admin():
    db = SessionLocal()
    try:
        # Check if admin already exists
        admin_email = "admin@eduflow.com"
        existing_admin = db.query(User).filter(User.email == admin_email).first()
        
        if existing_admin:
            print(f"Super admin already exists with email: {admin_email}")
            return

        # Create new admin
        print("Creating super admin...")
        admin_id = str(uuid.uuid4())
        current_time = int(time.time())
        
        new_admin = User(
            id=admin_id,
            email=admin_email,
            passwordHash=hash_password("admin123"), # Default password
            role="admin", # Super admin role
            approvalStatus="approved",
            createdAt=current_time,
            updatedAt=current_time
        )
        
        db.add(new_admin)
        
        # Create profile for admin
        new_profile = Profile(
            id=str(uuid.uuid4()),
            userId=admin_id,
            firstName="Super",
            lastName="Admin",
            createdAt=current_time,
            updatedAt=current_time
        )
        
        db.add(new_profile)
        
        db.commit()
        print(f"Successfully created super admin!")
        print(f"Email: {admin_email}")
        print(f"Password: admin123")
        
    except Exception as e:
        print(f"Error creating super admin: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    seed_super_admin()
