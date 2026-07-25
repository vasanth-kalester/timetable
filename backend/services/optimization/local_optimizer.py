from typing import Dict, List
from models.session import Session
from models.candidate_slot import CandidateSlot
from .selector import CandidateSelector

class LocalOptimizer:
    """
    Stage 6: Local Optimization.
    Improves the quality of a valid timetable by making local swaps that reduce penalties.
    """
    
    def __init__(self, selector: CandidateSelector):
        self.selector = selector
        
    def optimize(self, 
                 sessions: List[Session], 
                 assignments: Dict[str, CandidateSlot],
                 candidates_map: Dict[str, List[CandidateSlot]],
                 max_iterations: int = 100) -> Dict[str, CandidateSlot]:
        """
        Attempts to improve the overall penalty score by swapping sessions to better slots.
        """
        current_assignments = assignments.copy()
        improved = True
        iterations = 0
        
        while improved and iterations < max_iterations:
            improved = False
            iterations += 1
            
            for session in sessions:
                current_slot = current_assignments[session.id]
                candidates = candidates_map.get(session.id, [])
                
                # Try to find a better slot
                for candidate in candidates:
                    if candidate.penaltyScore < current_slot.penaltyScore:
                        # Temporarily release current slot
                        self.selector.release_resources(session, current_slot)
                        
                        if self.selector._is_slot_available(session, candidate):
                            # Found a better slot!
                            self.selector._reserve_resources(session, candidate)
                            current_assignments[session.id] = candidate
                            improved = True
                            break # Move to next session
                            
                        # Re-reserve current slot if candidate wasn't available
                        self.selector._reserve_resources(session, current_slot)
                        
        return current_assignments
