import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from core.database import Base
from services.candidate_slot_generator import CandidateSlotGenerator
from models.session import Session
from models.constraint import ConstraintConfiguration

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

def test_candidate_slot_generator(db_session):
    # Add a mock session
    session = Session(
        id="sess1",
        code="CS301-T1",
        subjectId="sub1",
        facultyId="fac1",
        sectionId="sec1",
        sessionType="theory",
        duration=1,
        priority=10,
        status="ready"
    )
    db_session.add(session)
    
    # Add some active constraints
    c1 = ConstraintConfiguration(id="c1", code="HC_WORKING_DAY", name="Working Day", type="hard", isActive=True)
    c2 = ConstraintConfiguration(id="c2", code="HC_PERIOD", name="Period", type="hard", isActive=True)
    db_session.add(c1)
    db_session.add(c2)
    db_session.commit()
    
    generator = CandidateSlotGenerator(db_session)
    
    context = {
        'working_days': [1, 2], # Only Monday and Tuesday
        'valid_periods': [1, 2], # Only Period 1 and 2
        'break_periods': [],
        'available_rooms': [None],
        'existing_slots': []
    }
    
    # Should generate 2 days * 2 periods * 1 room = 4 slots
    slots = generator.generate_for_session("sess1", context)
    
    assert len(slots) == 4
    for slot in slots:
        assert slot.sessionId == "sess1"
        assert slot.dayOfWeek in [1, 2]
        assert slot.period in [1, 2]
        assert slot.status == "valid"
