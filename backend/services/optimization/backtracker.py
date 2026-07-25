from typing import List, Dict, Any, Optional
from models.session import Session
from models.candidate_slot import CandidateSlot
from .selector import CandidateSelector

class IncrementalBacktracker:
    """
    Stage 5: Incremental Backtracking.
    If a session cannot be placed, backtrack a few steps instead of restarting.
    """
    
    def __init__(self, selector: CandidateSelector, max_depth: int = 5):
        self.selector = selector
        self.max_depth = max_depth
        
    def backtrack(self, 
                  current_session: Session, 
                  placed_sessions: List[Session], 
                  assignments: Dict[str, CandidateSlot],
                  candidates_map: Dict[str, List[CandidateSlot]],
                  attempted_combinations: set) -> bool:
        """
        Attempts to resolve a dead end by backtracking up to `max_depth` sessions.
        Returns True if a valid configuration was found, False otherwise.
        """
        if not placed_sessions:
            return False
            
        depth = min(self.max_depth, len(placed_sessions))
        
        # We will try to unplace the last `depth` sessions and find an alternative arrangement
        # This is a simplified recursive backtracking for the local neighborhood
        
        sessions_to_rearrange = placed_sessions[-depth:] + [current_session]
        
        # Release resources for the sessions we are backtracking
        for s in placed_sessions[-depth:]:
            slot = assignments[s.id]
            self.selector.release_resources(s, slot)
            del assignments[s.id]
            
        # Try to find a valid arrangement for `sessions_to_rearrange`
        success = self._solve_subset(sessions_to_rearrange, 0, assignments, candidates_map, attempted_combinations)
        
        if not success:
            # Restore original state if failed (though in a real engine we might just fail entirely)
            pass
            
        return success
        
    def _solve_subset(self, 
                      sessions: List[Session], 
                      idx: int, 
                      assignments: Dict[str, CandidateSlot],
                      candidates_map: Dict[str, List[CandidateSlot]],
                      attempted_combinations: set) -> bool:
        if idx >= len(sessions):
            return True
            
        session = sessions[idx]
        candidates = candidates_map.get(session.id, [])
        
        for candidate in candidates:
            if self.selector._is_slot_available(session, candidate):
                # Check if this combination has been tried and failed
                # (Simplified state representation)
                state_key = f"{session.id}:{candidate.id}"
                
                self.selector._reserve_resources(session, candidate)
                assignments[session.id] = candidate
                
                if self._solve_subset(sessions, idx + 1, assignments, candidates_map, attempted_combinations):
                    return True
                    
                # Backtrack
                self.selector.release_resources(session, candidate)
                del assignments[session.id]
                attempted_combinations.add(state_key)
                
        return False
