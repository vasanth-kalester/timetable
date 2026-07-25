import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from core.database import Base
from services.timetable_manager import TimetableManager
from models.session import Session
from models.candidate_slot import CandidateSlot
from models.timetable import Timetable, TimetableEntry

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

def test_timetable_generation(db_session):
    # Add mock sessions
    s1 = Session(id="s1", code="CS301-T1", facultyId="fac1", sectionId="sec1", sessionType="theory", duration=1, schedulingPriority=0, status="ready")
    s2 = Session(id="s2", code="CS302-T2", facultyId="fac1", sectionId="sec2", sessionType="theory", duration=1, schedulingPriority=0, status="ready")
    db_session.add(s1)
    db_session.add(s2)
    
    # Add candidate slots
    # Both sessions want Monday Period 1 (conflict)
    c1_s1 = CandidateSlot(id="c1", sessionId="s1", dayOfWeek=1, period=1, roomId="room1", status="valid", penaltyScore=0)
    c2_s1 = CandidateSlot(id="c2", sessionId="s1", dayOfWeek=1, period=2, roomId="room1", status="valid", penaltyScore=5)
    
    c1_s2 = CandidateSlot(id="c3", sessionId="s2", dayOfWeek=1, period=1, roomId="room2", status="valid", penaltyScore=0)
    c2_s2 = CandidateSlot(id="c4", sessionId="s2", dayOfWeek=1, period=2, roomId="room2", status="valid", penaltyScore=5)
    
    db_session.add_all([c1_s1, c2_s1, c1_s2, c2_s2])
    db_session.commit()
    
    manager = TimetableManager(db_session)
    timetable = manager.generate_timetable("ay1", "Test Timetable")
    
    assert timetable is not None
    assert timetable.status == "draft"
    assert timetable.conflicts == 0
    
    # Verify entries
    entries = db_session.query(TimetableEntry).filter(TimetableEntry.timetableId == timetable.id).all()
    assert len(entries) == 2
    
    # They should not be scheduled at the same time since they share fac1
    times = [(e.dayOfWeek, e.period) for e in entries]
    assert len(set(times)) == 2 # Should be 2 unique times
