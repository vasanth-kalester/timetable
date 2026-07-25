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

def test_trigger_event():
    response = client.post("/api/v1/workflow/trigger-event", json={
        "event_type": "faculty_leave_request",
        "context": {"leave_days": 3}
    })
    assert response.status_code == 200
    assert response.json()["event"] == "faculty_leave_request"
    assert len(response.json()["actions_taken"]) == 1

def test_process_approval():
    response = client.post("/api/v1/workflow/approvals/req123/process", json={
        "approver_id": "prin1",
        "action": "approve",
        "comments": "Looks good"
    })
    assert response.status_code == 200
    assert response.json()["status"] == "approved"

def test_publish_announcement():
    response = client.post("/api/v1/communication/announcements", json={
        "title": "Test Announcement",
        "content": "This is a test",
        "author_id": "prin1",
        "target_audience": "institution"
    })
    assert response.status_code == 200
    assert response.json()["title"] == "Test Announcement"

def test_get_notifications():
    response = client.get("/api/v1/communication/notifications/user1")
    assert response.status_code == 200
    assert isinstance(response.json(), list)

def test_get_unified_calendar():
    response = client.get("/api/v1/calendar/unified?user_id=user1&role=faculty&start_date=2026-10-01&end_date=2026-10-31")
    assert response.status_code == 200
    assert isinstance(response.json(), list)

def test_create_task():
    response = client.post("/api/v1/calendar/tasks", json={
        "title": "Test Task",
        "description": "Do something",
        "assignee_id": "user1",
        "due_date": "2026-10-15"
    })
    assert response.status_code == 200
    assert response.json()["title"] == "Test Task"
