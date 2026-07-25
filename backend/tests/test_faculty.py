import pytest
from fastapi import HTTPException
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from core.database import Base
from models.faculty import Faculty, SchedulingProfile
from schemas.faculty import FacultyCreate, SchedulingProfileCreate
from services.faculty_service import FacultyService

# Setup in-memory SQLite database for testing
SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

@pytest.fixture(scope="function")
def db():
    Base.metadata.create_all(bind=engine)
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()
        Base.metadata.drop_all(bind=engine)

def test_create_faculty_duplicate_employee_id(db):
    faculty_data = FacultyCreate(
        employeeId="EMP001",
        name="John Doe",
        email="john@example.com",
        departmentId="DEPT1"
    )
    
    # Create first faculty
    FacultyService.create_faculty(db, faculty_data)
    
    # Try creating second faculty with same employee ID
    faculty_data_2 = FacultyCreate(
        employeeId="EMP001",
        name="Jane Doe",
        email="jane@example.com",
        departmentId="DEPT1"
    )
    
    with pytest.raises(HTTPException) as excinfo:
        FacultyService.create_faculty(db, faculty_data_2)
        
    assert excinfo.value.status_code == 400
    assert "Employee ID already exists" in excinfo.value.detail

def test_create_scheduling_profile_invalid_workload(db):
    faculty_data = FacultyCreate(
        employeeId="EMP002",
        name="Alice",
        email="alice@example.com",
        departmentId="DEPT1"
    )
    faculty = FacultyService.create_faculty(db, faculty_data)
    
    profile_data = SchedulingProfileCreate(
        facultyId=faculty.id,
        maxPeriodsPerDay=20, # Invalid: daily > weekly
        maxPeriodsPerWeek=18
    )
    
    with pytest.raises(HTTPException) as excinfo:
        FacultyService.create_scheduling_profile(db, profile_data)
        
    assert excinfo.value.status_code == 400
    assert "Max daily periods cannot exceed max weekly periods" in excinfo.value.detail
