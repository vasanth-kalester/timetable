from typing import Dict, Any
from .base import BaseConstraint, ConstraintResult
from .registry import ConstraintRegistry

@ConstraintRegistry.register
class PreferredDayOffConstraint(BaseConstraint):
    CODE = "SC_PREFERRED_DAY_OFF"
    
    def __init__(self, **kwargs):
        super().__init__(code=self.CODE, name="Preferred Day Off", is_hard=False, **kwargs)

    def evaluate(self, session: Any, candidate_slot: Any, context: Dict[str, Any]) -> ConstraintResult:
        # context['faculty_preferences'] should map facultyId -> preferred day off
        faculty_preferences = context.get('faculty_preferences', {})
        preferred_day_off = faculty_preferences.get(session.facultyId)
        
        if preferred_day_off and candidate_slot['dayOfWeek'] == preferred_day_off:
            return ConstraintResult(is_valid=True, penalty=self.weight * 10, message="Scheduled on preferred day off")
            
        return ConstraintResult(is_valid=True, penalty=0)

@ConstraintRegistry.register
class AvoidFirstHourConstraint(BaseConstraint):
    CODE = "SC_AVOID_FIRST_HOUR"
    
    def __init__(self, **kwargs):
        super().__init__(code=self.CODE, name="Avoid First Hour", is_hard=False, **kwargs)

    def evaluate(self, session: Any, candidate_slot: Any, context: Dict[str, Any]) -> ConstraintResult:
        first_period = context.get('first_period', 1)
        
        if candidate_slot['period'] == first_period:
            return ConstraintResult(is_valid=True, penalty=self.weight * 5, message="Scheduled in the first hour")
            
        return ConstraintResult(is_valid=True, penalty=0)

@ConstraintRegistry.register
class AvoidLastHourConstraint(BaseConstraint):
    CODE = "SC_AVOID_LAST_HOUR"
    
    def __init__(self, **kwargs):
        super().__init__(code=self.CODE, name="Avoid Last Hour", is_hard=False, **kwargs)

    def evaluate(self, session: Any, candidate_slot: Any, context: Dict[str, Any]) -> ConstraintResult:
        last_period = context.get('last_period', 8)
        
        if candidate_slot['period'] + session.duration - 1 == last_period:
            return ConstraintResult(is_valid=True, penalty=self.weight * 5, message="Scheduled in the last hour")
            
        return ConstraintResult(is_valid=True, penalty=0)

@ConstraintRegistry.register
class MinimizeBuildingChangesConstraint(BaseConstraint):
    CODE = "SC_MINIMIZE_BUILDING_CHANGES"
    
    def __init__(self, **kwargs):
        super().__init__(code=self.CODE, name="Minimize Building Changes", is_hard=False, **kwargs)

    def evaluate(self, session: Any, candidate_slot: Any, context: Dict[str, Any]) -> ConstraintResult:
        existing_slots = context.get('existing_slots', [])
        room_id = candidate_slot.get('roomId')
        
        if not room_id:
            return ConstraintResult(is_valid=True, penalty=0)
            
        # context['room_buildings'] maps roomId -> buildingId
        room_buildings = context.get('room_buildings', {})
        proposed_building = room_buildings.get(room_id)
        
        if not proposed_building:
            return ConstraintResult(is_valid=True, penalty=0)
            
        # Check if faculty has a class in a different building right before or after
        for slot in existing_slots:
            if slot.dayOfWeek == candidate_slot['dayOfWeek'] and slot.facultyId == session.facultyId:
                if slot.period == candidate_slot['period'] - 1 or slot.period == candidate_slot['period'] + session.duration:
                    slot_building = room_buildings.get(slot.roomId)
                    if slot_building and slot_building != proposed_building:
                        return ConstraintResult(is_valid=True, penalty=self.weight * 15, message="Requires building change between consecutive classes")
                        
        return ConstraintResult(is_valid=True, penalty=0)

@ConstraintRegistry.register
class SpreadWorkloadConstraint(BaseConstraint):
    CODE = "SC_SPREAD_WORKLOAD"
    
    def __init__(self, **kwargs):
        super().__init__(code=self.CODE, name="Spread Workload", is_hard=False, **kwargs)

    def evaluate(self, session: Any, candidate_slot: Any, context: Dict[str, Any]) -> ConstraintResult:
        existing_slots = context.get('existing_slots', [])
        max_classes_per_day = self.parameters.get('max_classes_per_day', 4)
        
        # Count classes for this faculty on the proposed day
        classes_on_day = 0
        for slot in existing_slots:
            if slot.dayOfWeek == candidate_slot['dayOfWeek'] and slot.facultyId == session.facultyId:
                classes_on_day += 1
                
        if classes_on_day >= max_classes_per_day:
            penalty = (classes_on_day - max_classes_per_day + 1) * self.weight * 10
            return ConstraintResult(is_valid=True, penalty=penalty, message=f"Exceeds preferred max classes per day ({max_classes_per_day})")
            
        return ConstraintResult(is_valid=True, penalty=0)
