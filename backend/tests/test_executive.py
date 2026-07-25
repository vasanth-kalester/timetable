import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from core.database import Base
from services.executive.kpi_service import KPIService
from services.executive.forecast_service import ForecastService
from services.executive.semester_replay import SemesterReplayEngine

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

def test_kpi_service(db_session):
    service = KPIService(db_session)
    kpis = service.get_institutional_kpis()
    
    assert "academic" in kpis
    assert "administrative" in kpis
    assert "infrastructure" in kpis
    assert "healthScore" in kpis
    assert kpis["academic"]["averageClassroomUtilization"] == 78.5

def test_forecast_service(db_session):
    service = ForecastService(db_session)
    forecast = service.generate_resource_forecast("2027-2028", 15.0)
    
    assert forecast["targetYear"] == "2027-2028"
    assert forecast["projectedIntakeGrowth"] == 15.0
    assert "additionalClassroomsRequired" in forecast["forecasts"]

def test_semester_replay_engine(db_session):
    engine = SemesterReplayEngine(db_session)
    replay = engine.reconstruct_semester("2025-2026", "Odd Semester")
    
    assert replay["academicYear"] == "2025-2026"
    assert replay["semester"] == "Odd Semester"
    assert "reconstruction" in replay
    assert "operationalEvents" in replay["reconstruction"]
