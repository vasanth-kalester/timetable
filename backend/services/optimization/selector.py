from typing import List, Dict, Any, Optional
from models.candidate_slot import CandidateSlot
from models.session import Session

class CandidateSelector:
    """
    Stage 2 & 3: Candidate Selection and Resource Reservation.
    """
    
    def __init__(self):
        # Resource reservation maps
        self.reserved_faculty: Dict[str, set] = {} # facultyId -> set of (day, period)
        self.reserved_rooms: Dict[str, set] = {} # roomId -> set of (day, period)
        self.reserved_sections: Dict[str, set] = {} # sectionId -> set of (day, period)
        
    def select_best_slot(self, session: Session, candidates: List[CandidateSlot]) -> Optional[CandidateSlot]:
        """
        Selects the best available candidate slot that doesn't conflict with current reservations.
        Assumes candidates are already sorted by priority (best first).
        """
        for candidate in candidates:
            if self._is_slot_available(session, candidate):
                self._reserve_resources(session, candidate)
                return candidate
        return None
        
    def _is_slot_available(self, session: Session, slot: CandidateSlot) -> bool:
        day_period = (slot.dayOfWeek, slot.period)
        
        # Check Faculty
        if day_period in self.reserved_faculty.get(session.facultyId, set()):
            return False
            
        # Check Section
        if day_period in self.reserved_sections.get(session.sectionId, set()):
            return False
            
        # Check Room (if assigned)
        if slot.roomId and day_period in self.reserved_rooms.get(slot.roomId, set()):
            return False
            
        # For multi-period sessions (like labs), check all periods
        if session.duration > 1:
            for i in range(1, session.duration):
                dp = (slot.dayOfWeek, slot.period + i)
                if dp in self.reserved_faculty.get(session.facultyId, set()): return False
                if dp in self.reserved_sections.get(session.sectionId, set()): return False
                if slot.roomId and dp in self.reserved_rooms.get(slot.roomId, set()): return False
                
        return True
        
    def _reserve_resources(self, session: Session, slot: CandidateSlot):
        for i in range(session.duration):
            dp = (slot.dayOfWeek, slot.period + i)
            
            if session.facultyId not in self.reserved_faculty:
                self.reserved_faculty[session.facultyId] = set()
            self.reserved_faculty[session.facultyId].add(dp)
            
            if session.sectionId not in self.reserved_sections:
                self.reserved_sections[session.sectionId] = set()
            self.reserved_sections[session.sectionId].add(dp)
            
            if slot.roomId:
                if slot.roomId not in self.reserved_rooms:
                    self.reserved_rooms[slot.roomId] = set()
                self.reserved_rooms[slot.roomId].add(dp)
                
    def release_resources(self, session: Session, slot: CandidateSlot):
        """Used during backtracking to free up resources."""
        for i in range(session.duration):
            dp = (slot.dayOfWeek, slot.period + i)
            
            if session.facultyId in self.reserved_faculty:
                self.reserved_faculty[session.facultyId].discard(dp)
                
            if session.sectionId in self.reserved_sections:
                self.reserved_sections[session.sectionId].discard(dp)
                
            if slot.roomId and slot.roomId in self.reserved_rooms:
                self.reserved_rooms[slot.roomId].discard(dp)
