from typing import List, Dict, Tuple
from sqlalchemy.orm import Session as DBSession

from models.session import Session
from models.candidate_slot import CandidateSlot
from .sorter import SessionSorter
from .selector import CandidateSelector
from .backtracker import IncrementalBacktracker
from .local_optimizer import LocalOptimizer
import logging

logger = logging.getLogger(__name__)

class OptimizationEngine:
    """
    The main hybrid scheduling engine that coordinates all stages to generate a timetable.
    """
    
    def __init__(self, db: DBSession):
        self.db = db
        self.selector = CandidateSelector()
        self.backtracker = IncrementalBacktracker(self.selector)
        self.optimizer = LocalOptimizer(self.selector)
        
    def generate_timetable(self, sessions: List[Session], candidates_map: Dict[str, List[CandidateSlot]]) -> Tuple[bool, Dict[str, CandidateSlot]]:
        """
        Generates a complete timetable for the given sessions.
        Returns (success_flag, assignments_dict).
        """
        # Stage 1: Sort Sessions
        sorted_sessions = SessionSorter.sort_sessions(sessions)
        
        assignments: Dict[str, CandidateSlot] = {}
        placed_sessions: List[Session] = []
        attempted_combinations = set()
        
        # Stages 2-5: Candidate Selection, Reservation, Conflict Detection, Backtracking
        for session in sorted_sessions:
            candidates = candidates_map.get(session.id, [])
            
            # Try to place the session
            placed = False
            for candidate in candidates:
                state_key = f"{session.id}:{candidate.id}"
                if state_key in attempted_combinations:
                    continue
                    
                if self.selector._is_slot_available(session, candidate):
                    self.selector._reserve_resources(session, candidate)
                    assignments[session.id] = candidate
                    placed_sessions.append(session)
                    placed = True
                    break
                    
            if not placed:
                logger.warning(f"Failed to place session {session.id}. Initiating backtracking...")
                # Stage 5: Incremental Backtracking
                success = self.backtracker.backtrack(
                    session, placed_sessions, assignments, candidates_map, attempted_combinations
                )
                
                if not success:
                    logger.error(f"Backtracking failed for session {session.id}. Timetable generation failed.")
                    return False, assignments
                else:
                    # If backtrack succeeded, the session is now in placed_sessions (handled by backtracker)
                    placed_sessions.append(session)
                    
        # Stage 6: Local Optimization
        logger.info("Initial valid timetable generated. Starting local optimization...")
        optimized_assignments = self.optimizer.optimize(sorted_sessions, assignments, candidates_map)
        
        return True, optimized_assignments
