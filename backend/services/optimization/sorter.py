from typing import List
from models.session import Session

class SessionSorter:
    """
    Stage 1: Sorts sessions by scheduling difficulty.
    Hardest sessions are placed first.
    """
    
    @staticmethod
    def sort_sessions(sessions: List[Session]) -> List[Session]:
        def get_difficulty_score(session: Session) -> int:
            score = 0
            
            # 1. Long Labs (Highest Priority)
            if session.sessionType == "lab":
                score += 1000
                score += (session.duration * 100) # Longer labs are harder
                
            # 2. Shared Faculty (Simulated here by a flag or checking cross-department, assuming priority is pre-calculated)
            # We can use the existing schedulingPriority field which was calculated in Phase 5
            score += (session.schedulingPriority * 10)
            
            # 3. High-hour Theory
            if session.sessionType == "theory":
                score += (session.weeklyOccurrence * 5)
                
            # 4. Tutorials
            if session.sessionType == "tutorial":
                score += 10
                
            return score
            
        # Sort descending (highest score first)
        return sorted(sessions, key=get_difficulty_score, reverse=True)
