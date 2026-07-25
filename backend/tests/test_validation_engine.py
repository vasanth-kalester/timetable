import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from core.database import Base
from services.validation_engine import ValidationEngine
from models.academic import AcademicYear
from models.infrastructure import Building

# Setup in-memory SQLite for testing
SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

@pytest.fixture()
def db_session():
    Base.metadata.create_all(bind=engine)
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()
        Base.metadata.drop_all(bind=engine)

def test_validation_engine_no_academic_year(db_session):
    engine = ValidationEngine(db_session)
    report = engine.run_validation()
    
    assert report.status == "failed"
    assert report.institutionReadiness == 0.0
    
    # Check that the critical error was logged
    critical_errors = [r for r in engine.results if r.severity == "critical" and r.category == "Institution"]
    assert len(critical_errors) > 0
    assert critical_errors[0].message == "No frozen academic year found"

def test_validation_engine_with_academic_year_no_buildings(db_session):
    # Add a frozen academic year
    ay = AcademicYear(id="ay1", name="2026-2027", startDate=1, endDate=2, status="frozen")
    db_session.add(ay)
    db_session.commit()
    
    engine = ValidationEngine(db_session)
    report = engine.run_validation()
    
    assert report.status == "failed"
    assert report.institutionReadiness == 0.0
    
    # Check that the critical error for buildings was logged
    critical_errors = [r for r in engine.results if r.severity == "critical" and r.category == "Institution"]
    assert len(critical_errors) > 0
    assert critical_errors[0].message == "No buildings configured"

def test_validation_engine_institution_ready(db_session):
    # Add a frozen academic year and a building
    ay = AcademicYear(id="ay1", name="2026-2027", startDate=1, endDate=2, status="frozen")
    building = Building(id="b1", name="Main Block", code="MB", type="academic")
    db_session.add(ay)
    db_session.add(building)
    db_session.commit()
    
    engine = ValidationEngine(db_session)
    report = engine.run_validation()
    
    # Institution should pass, but overall might fail due to missing departments/subjects
    assert report.institutionReadiness == 100.0
    
    passed_checks = [r for r in engine.results if r.status == "passed" and r.category == "Institution"]
    assert len(passed_checks) > 0
    assert passed_checks[0].message == "Institution is ready for scheduling"
