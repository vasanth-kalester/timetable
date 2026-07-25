import pytest
from services.optimization.sorter import SessionSorter
from services.optimization.selector import CandidateSelector
from services.optimization.conflict_resolver import ConflictResolver
from models.session import Session
from models.candidate_slot import CandidateSlot

def test_session_sorter():
    s1 = Session(id="s1", sessionType="theory", duration=1, weeklyOccurrence=3, schedulingPriority=0)
    s2 = Session(id="s2", sessionType="lab", duration=3, weeklyOccurrence=1, schedulingPriority=0)
    s3 = Session(id="s3", sessionType="theory", duration=1, weeklyOccurrence=4, schedulingPriority=10)
    
    sessions = [s1, s2, s3]
    sorted_sessions = SessionSorter.sort_sessions(sessions)
    
    # Lab should be first (score 1300)
    assert sorted_sessions[0].id == "s2"
    # s3 has priority 10 (score 100) + weeklyOccurrence 4 (score 20) = 120
    assert sorted_sessions[1].id == "s3"
    # s1 has weeklyOccurrence 3 (score 15)
    assert sorted_sessions[2].id == "s1"

def test_candidate_selector_reservation():
    selector = CandidateSelector()
    session = Session(id="s1", facultyId="fac1", sectionId="sec1", duration=2)
    slot = CandidateSlot(id="c1", dayOfWeek=1, period=1, roomId="room1")
    
    # Check availability
    assert selector._is_slot_available(session, slot) == True
    
    # Reserve
    selector._reserve_resources(session, slot)
    
    # Check availability again
    assert selector._is_slot_available(session, slot) == False
    
    # Check period 2 (since duration is 2)
    slot2 = CandidateSlot(id="c2", dayOfWeek=1, period=2, roomId="room2")
    assert selector._is_slot_available(session, slot2) == False
    
    # Check release
    selector.release_resources(session, slot)
    assert selector._is_slot_available(session, slot) == True

def test_conflict_resolver():
    entries = [
        {'facultyId': 'fac1', 'sectionId': 'sec1', 'roomId': 'room1', 'dayOfWeek': 1, 'period': 1, 'duration': 1},
        {'facultyId': 'fac1', 'sectionId': 'sec2', 'roomId': 'room2', 'dayOfWeek': 1, 'period': 1, 'duration': 1}
    ]
    
    conflicts = ConflictResolver.detect_conflicts(entries)
    assert len(conflicts) == 1
    assert conflicts[0]['type'] == 'Faculty Conflict'
