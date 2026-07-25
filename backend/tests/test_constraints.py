import pytest
from services.constraints.hard_constraints import FacultyConflictConstraint, ClassroomConflictConstraint
from services.constraints.soft_constraints import PreferredDayOffConstraint, AvoidFirstHourConstraint
from models.candidate_slot import CandidateSlot

class MockSession:
    def __init__(self, faculty_id="fac1", section_id="sec1", duration=1, session_type="theory"):
        self.facultyId = faculty_id
        self.sectionId = section_id
        self.duration = duration
        self.sessionType = session_type

def test_faculty_conflict_constraint():
    constraint = FacultyConflictConstraint()
    session = MockSession(faculty_id="fac1")
    
    # Slot 1: Monday, Period 1, fac1
    existing_slot = CandidateSlot(dayOfWeek=1, period=1, facultyId="fac1")
    context = {'existing_slots': [existing_slot]}
    
    # Proposed slot: Monday, Period 1
    candidate_slot = {'dayOfWeek': 1, 'period': 1, 'roomId': 'room1'}
    
    result = constraint.evaluate(session, candidate_slot, context)
    assert result.is_valid == False
    assert "already scheduled" in result.message
    
    # Proposed slot: Monday, Period 2
    candidate_slot2 = {'dayOfWeek': 1, 'period': 2, 'roomId': 'room1'}
    result2 = constraint.evaluate(session, candidate_slot2, context)
    assert result2.is_valid == True

def test_classroom_conflict_constraint():
    constraint = ClassroomConflictConstraint()
    session = MockSession()
    
    existing_slot = CandidateSlot(dayOfWeek=1, period=1, roomId="room1")
    context = {'existing_slots': [existing_slot]}
    
    # Proposed slot: Monday, Period 1, room1
    candidate_slot = {'dayOfWeek': 1, 'period': 1, 'roomId': 'room1'}
    
    result = constraint.evaluate(session, candidate_slot, context)
    assert result.is_valid == False
    assert "already occupied" in result.message

def test_preferred_day_off_constraint():
    constraint = PreferredDayOffConstraint(weight=10)
    session = MockSession(faculty_id="fac1")
    
    # Faculty prefers day 3 (Wednesday) off
    context = {'faculty_preferences': {'fac1': 3}}
    
    # Proposed slot: Wednesday
    candidate_slot = {'dayOfWeek': 3, 'period': 1}
    
    result = constraint.evaluate(session, candidate_slot, context)
    assert result.is_valid == True
    assert result.penalty == 10
    
    # Proposed slot: Tuesday
    candidate_slot2 = {'dayOfWeek': 2, 'period': 1}
    result2 = constraint.evaluate(session, candidate_slot2, context)
    assert result2.is_valid == True
    assert result2.penalty == 0

def test_avoid_first_hour_constraint():
    constraint = AvoidFirstHourConstraint(weight=5)
    session = MockSession()
    
    context = {'first_period': 1}
    
    # Proposed slot: Period 1
    candidate_slot = {'dayOfWeek': 1, 'period': 1}
    
    result = constraint.evaluate(session, candidate_slot, context)
    assert result.is_valid == True
    assert result.penalty == 5
    
    # Proposed slot: Period 2
    candidate_slot2 = {'dayOfWeek': 1, 'period': 2}
    result2 = constraint.evaluate(session, candidate_slot2, context)
    assert result2.is_valid == True
    assert result2.penalty == 0
