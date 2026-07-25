import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from core.database import Base
from services.operations.version_manager import VersionManager
from models.timetable import Timetable, TimetableEntry
from models.operations import TimetableVersion, TimetableChange

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

def test_version_creation_and_rollback(db_session):
    # Initial setup
    timetable = Timetable(id="t1", academicYearId="ay1", name="Test", status="published")
    db_session.add(timetable)
    
    entry = TimetableEntry(id="e1", timetableId="t1", sessionId="s1", dayOfWeek=1, period=1, roomId="room1", facultyId="fac1", sectionId="sec1")
    db_session.add(entry)
    db_session.commit()
    
    manager = VersionManager(db_session)
    
    # Create Version 1
    v1 = manager.create_version("t1", "admin", "Initial Publication")
    assert v1.versionNumber == 1
    assert v1.isActive == True
    
    # Make a change and create Version 2
    # Move from Monday P1 to Tuesday P2
    old_data = {'dayOfWeek': 1, 'period': 1, 'roomId': 'room1', 'facultyId': 'fac1'}
    new_data = {'dayOfWeek': 2, 'period': 2, 'roomId': 'room2', 'facultyId': 'fac2'}
    
    # Update actual entry
    entry.dayOfWeek = 2
    entry.period = 2
    entry.roomId = "room2"
    entry.facultyId = "fac2"
    db_session.commit()
    
    v2 = manager.create_version("t1", "admin", "Faculty Substitution")
    assert v2.versionNumber == 2
    assert v2.isActive == True
    
    # Check v1 is inactive
    db_session.refresh(v1)
    assert v1.isActive == False
    
    # Log the change in v2
    manager.log_change(v2.id, "s1", "admin", "substitution", "Faculty Leave", old_data, new_data)
    
    # Now rollback to Version 1
    success = manager.rollback_to_version("t1", v1.id)
    assert success == True
    
    # Check entry is reverted
    db_session.refresh(entry)
    assert entry.dayOfWeek == 1
    assert entry.period == 1
    assert entry.roomId == "room1"
    assert entry.facultyId == "fac1"
    
    # Check version statuses
    db_session.refresh(v1)
    db_session.refresh(v2)
    assert v1.isActive == True
    assert v2.isActive == False
