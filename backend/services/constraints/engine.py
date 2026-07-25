from typing import Dict, Any, List, Tuple
import json
from .registry import ConstraintRegistry
from .base import BaseConstraint, ConstraintResult
import logging

logger = logging.getLogger(__name__)

class ConstraintEngine:
    def __init__(self, active_constraints: List[BaseConstraint]):
        self.constraints = active_constraints
        self.hard_constraints = [c for c in self.constraints if c.is_hard]
        self.soft_constraints = [c for c in self.constraints if not c.is_hard]

    def evaluate_slot(self, session: Any, candidate_slot: Dict[str, Any], context: Dict[str, Any]) -> Tuple[bool, int, List[str], List[str]]:
        """
        Evaluates a single candidate slot against all constraints.
        
        Returns:
            Tuple containing:
            - is_valid (bool): True if all hard constraints pass.
            - penalty_score (int): Total penalty from soft constraints.
            - satisfied_constraints (List[str]): List of constraint codes that were satisfied.
            - violated_constraints (List[str]): List of soft constraint codes that were violated.
        """
        is_valid = True
        penalty_score = 0
        satisfied_constraints = []
        violated_constraints = []
        
        # 1. Evaluate Hard Constraints
        for constraint in self.hard_constraints:
            result = constraint.evaluate(session, candidate_slot, context)
            if not result.is_valid:
                is_valid = False
                violated_constraints.append(constraint.code)
                # We can fail fast on hard constraints
                return False, 0, satisfied_constraints, violated_constraints
            else:
                satisfied_constraints.append(constraint.code)
                
        # 2. Evaluate Soft Constraints
        for constraint in self.soft_constraints:
            result = constraint.evaluate(session, candidate_slot, context)
            if not result.is_valid or result.penalty > 0:
                penalty_score += result.penalty
                violated_constraints.append(constraint.code)
            else:
                satisfied_constraints.append(constraint.code)
                
        return is_valid, penalty_score, satisfied_constraints, violated_constraints

    def get_all_candidate_slots(self, session: Any, context: Dict[str, Any]) -> List[Dict[str, Any]]:
        """
        Generates all possible slots and evaluates them.
        """
        valid_days = context.get('working_days', [1, 2, 3, 4, 5])
        valid_periods = context.get('valid_periods', [1, 2, 3, 4, 5, 6, 7, 8])
        available_rooms = context.get('available_rooms', [None]) # None means no specific room required yet
        
        candidates = []
        
        for day in valid_days:
            for period in valid_periods:
                for room_id in available_rooms:
                    slot_proposal = {
                        'dayOfWeek': day,
                        'period': period,
                        'roomId': room_id
                    }
                    
                    is_valid, penalty, satisfied, violated = self.evaluate_slot(session, slot_proposal, context)
                    
                    if is_valid:
                        candidates.append({
                            'sessionId': session.id,
                            'dayOfWeek': day,
                            'period': period,
                            'roomId': room_id,
                            'facultyId': session.facultyId,
                            'sectionId': session.sectionId,
                            'penaltyScore': penalty,
                            'satisfiedConstraints': json.dumps(satisfied),
                            'violatedConstraints': json.dumps(violated),
                            'status': 'valid'
                        })
                        
        # Rank candidates by penalty score (lower is better)
        candidates.sort(key=lambda x: x['penaltyScore'])
        
        # Assign priority based on rank
        for i, candidate in enumerate(candidates):
            candidate['priority'] = i + 1
            
        return candidates
