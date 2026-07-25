from abc import ABC, abstractmethod
from typing import Dict, Any, Optional
from pydantic import BaseModel

class ConstraintResult(BaseModel):
    is_valid: bool
    penalty: int = 0
    message: Optional[str] = None

class BaseConstraint(ABC):
    def __init__(self, code: str, name: str, is_hard: bool = True, weight: int = 1, parameters: Dict[str, Any] = None):
        self.code = code
        self.name = name
        self.is_hard = is_hard
        self.weight = weight
        self.parameters = parameters or {}

    @abstractmethod
    def evaluate(self, session: Any, candidate_slot: Any, context: Dict[str, Any]) -> ConstraintResult:
        """
        Evaluate the constraint against a candidate slot for a session.
        
        Args:
            session: The Session object being scheduled.
            candidate_slot: A dictionary or object representing the proposed slot (day, period, room).
            context: Additional context needed for evaluation (e.g., existing assignments, faculty profiles).
            
        Returns:
            ConstraintResult indicating validity and penalty.
        """
        pass
