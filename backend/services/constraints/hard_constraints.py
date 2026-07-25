from typing import Dict, Any
from .base import BaseConstraint, ConstraintResult
from .registry import ConstraintRegistry

@ConstraintRegistry.register
class FacultyConflictConstraint(BaseConstraint):
    CODE = "HC_FACULTY_CONFLICT"
    
    def __init__(self, **kwargs):
        super().__init__(code=self.CODE, name="Faculty Conflict", is_hard=True, **kwargs)

    def evaluate(self, session: Any, candidate_slot: Any, context: Dict[str, Any]) -> ConstraintResult:
        # context['existing_slots'] should be a list of already scheduled slots
        existing_slots = context.get('existing_slots', [])
        
        for slot in existing_slots:
            if (slot.dayOfWeek == candidate_slot['dayOfWeek'] and 
                slot.period == candidate_slot['period'] and 
                slot.facultyId == session.facultyId):
                return ConstraintResult(is_valid=False, message="Faculty is already scheduled for this period")
                
        return ConstraintResult(is_valid=True)

@ConstraintRegistry.register
class ClassroomConflictConstraint(BaseConstraint):
    CODE = "HC_CLASSROOM_CONFLICT"
    
    def __init__(self, **kwargs):
        super().__init__(code=self.CODE, name="Classroom Conflict", is_hard=True, **kwargs)

    def evaluate(self, session: Any, candidate_slot: Any, context: Dict[str, Any]) -> ConstraintResult:
        existing_slots = context.get('existing_slots', [])
        room_id = candidate_slot.get('roomId')
        
        if not room_id:
            return ConstraintResult(is_valid=True) # No room assigned yet, or not applicable
            
        for slot in existing_slots:
            if (slot.dayOfWeek == candidate_slot['dayOfWeek'] and 
                slot.period == candidate_slot['period'] and 
                slot.roomId == room_id):
                return ConstraintResult(is_valid=False, message="Classroom is already occupied for this period")
                
        return ConstraintResult(is_valid=True)

@ConstraintRegistry.register
class SectionConflictConstraint(BaseConstraint):
    CODE = "HC_SECTION_CONFLICT"
    
    def __init__(self, **kwargs):
        super().__init__(code=self.CODE, name="Section Conflict", is_hard=True, **kwargs)

    def evaluate(self, session: Any, candidate_slot: Any, context: Dict[str, Any]) -> ConstraintResult:
        existing_slots = context.get('existing_slots', [])
        
        for slot in existing_slots:
            if (slot.dayOfWeek == candidate_slot['dayOfWeek'] and 
                slot.period == candidate_slot['period'] and 
                slot.sectionId == session.sectionId):
                return ConstraintResult(is_valid=False, message="Section already has a class scheduled for this period")
                
        return ConstraintResult(is_valid=True)

@ConstraintRegistry.register
class FacultyAvailabilityConstraint(BaseConstraint):
    CODE = "HC_FACULTY_AVAILABILITY"
    
    def __init__(self, **kwargs):
        super().__init__(code=self.CODE, name="Faculty Availability", is_hard=True, **kwargs)

    def evaluate(self, session: Any, candidate_slot: Any, context: Dict[str, Any]) -> ConstraintResult:
        # context['faculty_availability'] should be a dict mapping day -> list of unavailable periods
        faculty_availability = context.get('faculty_availability', {})
        day = candidate_slot['dayOfWeek']
        period = candidate_slot['period']
        
        unavailable_periods = faculty_availability.get(day, [])
        if period in unavailable_periods:
            return ConstraintResult(is_valid=False, message="Faculty is unavailable during this period")
            
        return ConstraintResult(is_valid=True)

@ConstraintRegistry.register
class WorkingDayConstraint(BaseConstraint):
    CODE = "HC_WORKING_DAY"
    
    def __init__(self, **kwargs):
        super().__init__(code=self.CODE, name="Working Day", is_hard=True, **kwargs)

    def evaluate(self, session: Any, candidate_slot: Any, context: Dict[str, Any]) -> ConstraintResult:
        # context['working_days'] should be a list of valid days (e.g., [1, 2, 3, 4, 5])
        working_days = context.get('working_days', [1, 2, 3, 4, 5])
        day = candidate_slot['dayOfWeek']
        
        if day not in working_days:
            return ConstraintResult(is_valid=False, message="Proposed day is not a working day")
            
        return ConstraintResult(is_valid=True)

@ConstraintRegistry.register
class PeriodConstraint(BaseConstraint):
    CODE = "HC_PERIOD"
    
    def __init__(self, **kwargs):
        super().__init__(code=self.CODE, name="Period Validity", is_hard=True, **kwargs)

    def evaluate(self, session: Any, candidate_slot: Any, context: Dict[str, Any]) -> ConstraintResult:
        # context['valid_periods'] should be a list of valid periods (e.g., [1, 2, 3, 4, 5, 6, 7, 8])
        # context['break_periods'] should be a list of break periods (e.g., [5])
        valid_periods = context.get('valid_periods', [1, 2, 3, 4, 5, 6, 7, 8])
        break_periods = context.get('break_periods', [])
        period = candidate_slot['period']
        
        if period not in valid_periods:
            return ConstraintResult(is_valid=False, message="Proposed period is invalid")
            
        if period in break_periods:
            return ConstraintResult(is_valid=False, message="Proposed period is a break/lunch period")
            
        return ConstraintResult(is_valid=True)

@ConstraintRegistry.register
class ContinuousLabConstraint(BaseConstraint):
    CODE = "HC_CONTINUOUS_LAB"
    
    def __init__(self, **kwargs):
        super().__init__(code=self.CODE, name="Continuous Lab", is_hard=True, **kwargs)

    def evaluate(self, session: Any, candidate_slot: Any, context: Dict[str, Any]) -> ConstraintResult:
        if session.sessionType != "lab":
            return ConstraintResult(is_valid=True)
            
        duration = session.duration
        if duration <= 1:
            return ConstraintResult(is_valid=True)
            
        # Check if the proposed period allows for the full duration without hitting a break or end of day
        valid_periods = context.get('valid_periods', [1, 2, 3, 4, 5, 6, 7, 8])
        break_periods = context.get('break_periods', [])
        start_period = candidate_slot['period']
        
        for i in range(duration):
            current_period = start_period + i
            if current_period not in valid_periods:
                return ConstraintResult(is_valid=False, message=f"Lab duration exceeds valid periods (hits period {current_period})")
            if current_period in break_periods:
                return ConstraintResult(is_valid=False, message=f"Lab duration overlaps with a break (period {current_period})")
                
        return ConstraintResult(is_valid=True)
