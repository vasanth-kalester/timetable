import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from core.database import Base
from services.analytics.utilization_engine import ResourceUtilizationEngine
from services.planning.capacity_simulator import CapacitySimulator
from models.timetable import Timetable, TimetableEntry
from models.infrastructure import Classroom
from models.session import Session

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

def test_resource_utilization_engine(db_session):
    # Setup mock data
    timetable = Timetable(id="t1", academicYearId="ay1", name="Test", status="published")
    db_session.add(timetable)
    
    room = Classroom(id="room1", name="Room 101", capacity=60, buildingId="b1", floor=1, roomType="theory")
    db_session.add(room)
    
    # Add 10 entries for room1
    for i in range(10):
        entry = TimetableEntry(id=f"e{i}", timetableId="t1", sessionId=f"s{i}", dayOfWeek=1, period=i, roomId="room1", facultyId="fac1", sectionId="sec1")
        db_session.add(entry)
        
    db_session.commit()
    
    engine = ResourceUtilizationEngine(db_session)
    utilization = engine.calculate_room_utilization("t1")
    
    assert len(utilization) == 1
    assert utilization[0]["roomId"] == "room1"
    assert utilization[0]["totalUsedPeriods"] == 10
    # 10 / 40 = 25%
    assert utilization[0]["weeklyUtilization"] == 25.0
    assert utilization[0]["idleHours"] == 30

def test_capacity_simulator(db_session):
    # Setup mock data
    timetable = Timetable(id="t1", academicYearId="ay1", name="Test", status="published")
    db_session.add(timetable)
    
    # Add 2 rooms
    room1 = Classroom(id="room1", name="Room 101", capacity=60, buildingId="b1", floor=1, roomType="theory")
    room2 = Classroom(id="room2", name="Room 102", capacity=60, buildingId="b1", floor=1, roomType="theory")
    db_session.add_all([room1, room2])
    
    # Fill room1 completely (40 periods)
    for i in range(40):
        entry = TimetableEntry(id=f"e{i}", timetableId="t1", sessionId=f"s{i}", dayOfWeek=1, period=1, roomId="room1", facultyId="fac1", sectionId="sec1")
        db_session.add(entry)
        
    db_session.commit()
    
    simulator = CapacitySimulator(db_session)
    
    # Simulate adding 1 new section (approx 40 periods)
    result = simulator.simulate_capacity_change(new_sections=1, students_per_section=60)
    
    # Current usage: 40 periods. Total capacity: 80 periods. Current util: 50%
    assert result["baseline"]["totalRooms"] == 2
    assert result["baseline"]["currentUtilization"] == 50.0
    
    # New periods: 40. Total used: 80. Total capacity: 80. New util: 100%
    # 100% > 85%, so it should warn and suggest more rooms
    assert result["simulation"]["projectedUtilization"] == 100.0
    assert result["simulation"]["status"] == "Warning"
    assert result["simulation"]["additionalRoomsNeeded"] > 0
