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

def test_get_room_utilization():
    response = client.get("/api/v1/analytics/rooms/utilization")
    assert response.status_code == 200
    assert isinstance(response.json(), list)

def test_get_faculty_utilization():
    response = client.get("/api/v1/analytics/faculty/utilization")
    assert response.status_code == 200
    assert isinstance(response.json(), list)

def test_get_quality_score():
    response = client.get("/api/v1/analytics/quality-score")
    assert response.status_code == 200
    assert isinstance(response.json(), dict)

def test_simulate_capacity():
    response = client.get("/api/v1/planning/simulate-capacity?newSections=2&studentsPerSection=60")
    assert response.status_code == 200
    assert "simulation" in response.json()

def test_forecast_demand():
    response = client.get("/api/v1/planning/forecast-demand?growthRate=0.15")
    assert response.status_code == 200
    assert "forecastedPeriods" in response.json()
