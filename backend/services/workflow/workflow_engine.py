from sqlalchemy.orm import Session as DBSession
from typing import Dict, Any
from .rule_engine import RuleEngine

class WorkflowEngine:
    def __init__(self, db: DBSession):
        self.db = db
        self.rule_engine = RuleEngine(db)
        
    def trigger_event(self, event_type: str, context: Dict[str, Any]) -> Dict[str, Any]:
        """
        Triggers an event, evaluates rules, and orchestrates actions.
        """
        # 1. Evaluate rules
        actions = self.rule_engine.evaluate_rules(event_type, context)
        
        # 2. Execute actions
        results = []
        for action in actions:
            action_type = action.get("action")
            
            if action_type == "require_approval":
                # Route to approval service
                results.append(f"Routed approval to {action.get('role')}")
                
            elif action_type == "reject":
                # Reject the operation
                results.append(f"Rejected: {action.get('reason')}")
                
            elif action_type == "lock_teaching_assignments":
                # Lock assignments
                results.append("Teaching assignments locked")
                
            elif action_type == "disable_timetable_editing":
                # Disable editing
                results.append("Timetable editing disabled")
                
        return {
            "event": event_type,
            "actions_taken": results,
            "status": "processed"
        }
