import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from core.database import Base
from services.workflow.rule_engine import RuleEngine
from services.workflow.workflow_engine import WorkflowEngine
from services.workflow.approval_service import ApprovalService

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

def test_rule_engine_faculty_leave(db_session):
    engine = RuleEngine(db_session)
    
    # Test leave > 2 days
    actions = engine.evaluate_rules("faculty_leave_request", {"leave_days": 3})
    assert len(actions) == 1
    assert actions[0]["action"] == "require_approval"
    assert actions[0]["role"] == "principal"
    
    # Test leave <= 2 days
    actions = engine.evaluate_rules("faculty_leave_request", {"leave_days": 2})
    assert len(actions) == 1
    assert actions[0]["action"] == "require_approval"
    assert actions[0]["role"] == "hod"

def test_rule_engine_room_allocation(db_session):
    engine = RuleEngine(db_session)
    
    # Test capacity < strength
    actions = engine.evaluate_rules("room_allocation", {"room_capacity": 50, "section_strength": 60})
    assert len(actions) == 1
    assert actions[0]["action"] == "reject"
    
    # Test capacity >= strength
    actions = engine.evaluate_rules("room_allocation", {"room_capacity": 60, "section_strength": 60})
    assert len(actions) == 0

def test_workflow_engine_trigger(db_session):
    engine = WorkflowEngine(db_session)
    
    result = engine.trigger_event("faculty_leave_request", {"leave_days": 3})
    assert result["event"] == "faculty_leave_request"
    assert result["status"] == "processed"
    assert len(result["actions_taken"]) == 1
    assert "Routed approval to principal" in result["actions_taken"][0]

def test_approval_service(db_session):
    service = ApprovalService(db_session)
    
    request = service.create_request("fac1", "Faculty Leave", {"days": 3}, "principal")
    assert request["status"] == "pending"
    assert request["requiredRole"] == "principal"
    
    processed = service.process_request(request["id"], "prin1", "approve", "Approved")
    assert processed["status"] == "approved"
    assert processed["approverId"] == "prin1"
    assert processed["comments"] == "Approved"
