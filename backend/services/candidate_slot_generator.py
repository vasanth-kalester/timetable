from sqlalchemy.orm import Session as DBSession
from typing import List, Dict, Any
import uuid

from models.session import Session
from models.candidate_slot import CandidateSlot
from models.constraint import ConstraintConfiguration
from services.constraints.engine import ConstraintEngine
from services.constraints.registry import ConstraintRegistry
# Import constraints to register them
import services.constraints.hard_constraints
import services.constraints.soft_constraints

class CandidateSlotGenerator:
    def __init__(self, db: DBSession):
        self.db = db
        self.engine = self._initialize_engine()

    def _initialize_engine(self) -> ConstraintEngine:
        # Load active constraints from DB
        configs = self.db.query(ConstraintConfiguration).filter(ConstraintConfiguration.isActive == True).all()
        
        active_constraints = []
        for config in configs:
            constraint_class = ConstraintRegistry.get_constraint(config.code)
            if constraint_class:
                import json
                parameters = json.loads(config.parameters) if config.parameters else {}
                constraint_instance = constraint_class(
                    name=config.name,
                    is_hard=(config.type == "hard"),
                    weight=config.weight,
                    parameters=parameters
                )
                active_constraints.append(constraint_instance)
                
        # If DB is empty, load defaults from registry
        if not active_constraints:
            for code, constraint_class in ConstraintRegistry.get_all_constraints().items():
                active_constraints.append(constraint_class())
                
        return ConstraintEngine(active_constraints)

    def generate_for_session(self, session_id: str, context: Dict[str, Any]) -> List[CandidateSlot]:
        session = self.db.query(Session).filter(Session.id == session_id).first()
        if not session:
            raise ValueError(f"Session {session_id} not found")
            
        # Clear existing candidate slots for this session
        self.db.query(CandidateSlot).filter(CandidateSlot.sessionId == session_id).delete()
        
        # Generate candidates
        candidates_data = self.engine.get_all_candidate_slots(session, context)
        
        candidate_slots = []
        for data in candidates_data:
            slot = CandidateSlot(
                id=str(uuid.uuid4()),
                sessionId=data['sessionId'],
                dayOfWeek=data['dayOfWeek'],
                period=data['period'],
                roomId=data['roomId'],
                facultyId=data['facultyId'],
                sectionId=data['sectionId'],
                penaltyScore=data['penaltyScore'],
                satisfiedConstraints=data['satisfiedConstraints'],
                violatedConstraints=data['violatedConstraints'],
                priority=data['priority'],
                status=data['status']
            )
            candidate_slots.append(slot)
            self.db.add(slot)
            
        self.db.commit()
        return candidate_slots

    def generate_all(self, context: Dict[str, Any]) -> int:
        sessions = self.db.query(Session).filter(Session.status == "ready").all()
        total_generated = 0
        
        for session in sessions:
            slots = self.generate_for_session(session.id, context)
            total_generated += len(slots)
            
        return total_generated
