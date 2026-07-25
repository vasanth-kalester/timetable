from typing import List, Dict, Any
from models.candidate_slot import CandidateSlot
from models.session import Session

class ConflictResolver:
    """
    Stage 4: Conflict Detection.
    While the Candidate Selector prevents conflicts during sequential placement,
    this resolver can be used to validate an entire timetable or handle manual edits.
    """
    
    @staticmethod
    def detect_conflicts(entries: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        conflicts = []
        
        # Maps to track usage: (day, period) -> list of entries
        faculty_usage = {}
        room_usage = {}
        section_usage = {}
        
        for entry in entries:
            day = entry['dayOfWeek']
            period = entry['period']
            duration = entry.get('duration', 1)
            
            for i in range(duration):
                dp = (day, period + i)
                
                # Check Faculty
                fac_id = entry['facultyId']
                if dp not in faculty_usage:
                    faculty_usage[dp] = {}
                if fac_id in faculty_usage[dp]:
                    conflicts.append({
                        'type': 'Faculty Conflict',
                        'message': f"Faculty {fac_id} scheduled multiple times on Day {day}, Period {period+i}",
                        'entries': [faculty_usage[dp][fac_id], entry]
                    })
                else:
                    faculty_usage[dp][fac_id] = entry
                    
                # Check Room
                room_id = entry.get('roomId')
                if room_id:
                    if dp not in room_usage:
                        room_usage[dp] = {}
                    if room_id in room_usage[dp]:
                        conflicts.append({
                            'type': 'Classroom Conflict',
                            'message': f"Room {room_id} scheduled multiple times on Day {day}, Period {period+i}",
                            'entries': [room_usage[dp][room_id], entry]
                        })
                    else:
                        room_usage[dp][room_id] = entry
                        
                # Check Section
                sec_id = entry['sectionId']
                if dp not in section_usage:
                    section_usage[dp] = {}
                if sec_id in section_usage[dp]:
                    conflicts.append({
                        'type': 'Section Conflict',
                        'message': f"Section {sec_id} scheduled multiple times on Day {day}, Period {period+i}",
                        'entries': [section_usage[dp][sec_id], entry]
                    })
                else:
                    section_usage[dp][sec_id] = entry
                    
        return conflicts
