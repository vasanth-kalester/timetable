import pytest
from fastapi.testclient import TestClient
from main import app
from core.database import get_db
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from core.database import Base

# Setup in-memory SQLite for testing
SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base.metadata.create_all(bind=engine)

def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db
client = TestClient(app)

def test_get_kpis():
    response = client.get("/api/v1/executive/kpis")
    assert response.status_code == 200
    assert "academic" in response.json()
    assert "healthScore" in response.json()

def test_get_benchmarks():
    response = client.get("/api/v1/executive/benchmarks")
    assert response.status_code == 200
    assert isinstance(response.json(), list)
    assert len(response.json()) > 0

def test_get_historical_trends():
    response = client.get("/api/v1/executive/historical/trends?metric=Classroom Utilization")
    assert response.status_code == 200
    assert response.json()["metric"] == "Classroom Utilization"
    assert "trends" in response.json()

def test_get_forecast():
    response = client.get("/api/v1/executive/forecast?target_year=2027-2028&growth_rate=15.0")
    assert response.status_code == 200
    assert response.json()["targetYear"] == "2027-2028"
    assert "forecasts" in response.json()

def test_replay_semester():
    response = client.get("/api/v1/executive/replay?academic_year_id=2025-2026&semester=Odd Semester")
    assert response.status_code == 200
    assert response.json()["academicYear"] == "2025-2026"
    assert "reconstruction" in response.json()

def test_get_accreditation_metrics():
    response = client.get("/api/v1/executive/accreditation/AICTE")
    assert response.status_code == 200
    assert response.json()["accreditationBody"] == "AICTE"
    assert "metrics" in response.json()

def test_generate_custom_report():
    response = client.post("/api/v1/executive/reports/custom?format=pdf", json={
        "report_type": "Faculty Workload",
        "academic_year": "2025-2026"
    })
    assert response.status_code == 200
    assert response.json()["status"] == "generated"
    assert response.json()["format"] == "pdf"

def test_get_active_alerts():
    response = client.get("/api/v1/executive/alerts")
    assert response.status_code == 200
    assert isinstance(response.json(), list)
