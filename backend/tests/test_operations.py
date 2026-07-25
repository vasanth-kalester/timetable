import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from core.database import Base
from services.operations.leave_impact import LeaveImpactAnalyzer
from services.operations.substitution_engine import SubstitutionEngine
from models.timetable import Timetable, TimetableEntry
from models.session import Session
from models.faculty import Faculty
import time

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

def test_leave_impact_analyzer(db_session):
    # Setup mock data
    timetable = Timetable(id="t1", academicYearId="ay1", name="Test", status="published")
    db_session.add(timetable)
    
    session = Session(id="s1", code="CS301", facultyId="fac1", sectionId="sec1", sessionType="theory", duration=1, schedulingPriority=0, departmentId="dept1")
    db_session.add(session)
    
    # Monday is dayOfWeek 1
    entry = TimetableEntry(id="e1", timetableId="t1", sessionId="s1", dayOfWeek=1, period=1, roomId="room1", facultyId="fac1", sectionId="sec1")
    db_session.add(entry)
    db_session.commit()
    
    analyzer = LeaveImpactAnalyzer(db_session)
    
    # Test with a Monday date (e.g., 2026-10-12 is a Monday)
    # 2026-10-12 00:00:00 UTC = 1791763200000 ms
    impact = analyzer.analyze_impact("fac1", 1791763200000)
    
    assert impact["facultyId"] == "fac1"
    assert impact["total_affected"] == 1
    assert impact["affected_sessions"][0]["sessionId"] == "s1"
    assert "room1" in impact["freed_rooms"]

def test_substitution_engine(db_session):
    # Setup mock data
    timetable = Timetable(id="t1", academicYearId="ay1", name="Test", status="published")
    db_session.add(timetable)
    
    session = Session(id="s1", code="CS301", facultyId="fac1", sectionId="sec1", sessionType="theory", duration=1, schedulingPriority=0, departmentId="dept1")
    db_session.add(session)
    
    fac1 = Faculty(id="fac1", firstName="Original", lastName="Faculty", departmentId="dept1", email="fac1@test.com", status="active")
    fac2 = Faculty(id="fac2", firstName="Substitute", lastName="One", departmentId="dept1", email="fac2@test.com", status="active")
    fac3 = Faculty(id="fac3", firstName="Busy", lastName="Faculty", departmentId="dept1", email="fac3@test.com", status="active")
    db_session.add_all([fac1, fac2, fac3])
    
    # fac3 is busy on Monday Period 1
    entry_busy = TimetableEntry(id="e2", timetableId="t1", sessionId="s2", dayOfWeek=1, period=1, roomId="room2", facultyId="fac3", sectionId="sec2")
    db_session.add(entry_busy)
    db_session.commit()
    
    engine = SubstitutionEngine(db_session)
    
    # Ask for substitute for s1 on Monday Period 1
    recommendations = engine.recommend_substitutes("s1", 1, 1)
    
    # Should only recommend fac2 because fac3 is busy and fac1 is the original
    assert len(recommendations) == 1
    assert recommendations[0]["facultyId"] == "fac2"
    assert recommendations[0]["score"] > 0
