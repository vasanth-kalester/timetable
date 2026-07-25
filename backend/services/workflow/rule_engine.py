from sqlalchemy.orm import Session as DBSession
from typing import Dict, Any, List

class RuleEngine:
    def __init__(self, db: DBSession):
        self.db = db
        
    def evaluate_rules(self, event_type: str, context: Dict[str, Any]) -> List[Dict[str, Any]]:
        """
        Evaluates active institution rules for a given event type.
        Returns a list of actions to take.
        """
        # In a real implementation, these rules would be fetched from the database (InstitutionRule model).
        # For demonstration, we use hardcoded rules based on the prompt.
        
        actions = []
        
        if event_type == "faculty_leave_request":
            days = context.get("leave_days", 0)
            if days > 2:
                actions.append({
                    "action": "require_approval",
                    "role": "principal",
                    "reason": "Leave exceeds 2 days"
                })
            else:
                actions.append({
                    "action": "require_approval",
                    "role": "hod",
                    "reason": "Standard leave approval"
                })
                
        elif event_type == "room_allocation":
            capacity = context.get("room_capacity", 0)
            strength = context.get("section_strength", 0)
            if capacity < strength:
                actions.append({
                    "action": "reject",
                    "reason": "Room capacity is less than section strength"
                })
                
        elif event_type == "timetable_published":
            actions.append({
                "action": "lock_teaching_assignments",
                "reason": "Timetable is published"
            })
            
        elif event_type == "internal_exam_week":
            actions.append({
                "action": "disable_timetable_editing",
                "reason": "Internal exam week is active"
            })
            
        return actions
