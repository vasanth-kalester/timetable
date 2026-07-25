from sqlalchemy.orm import Session as DBSession
from typing import Dict, Any, List

class BenchmarkingService:
    def __init__(self, db: DBSession):
        self.db = db
        
    def get_department_benchmarks(self) -> List[Dict[str, Any]]:
        """
        Compares departments across various metrics.
        """
        # Mock data
        return [
            {
                "departmentId": "dept1",
                "departmentName": "Computer Science",
                "metrics": {
                    "facultyWorkload": 85.0,
                    "resourceUtilization": 90.0,
                    "teachingHours": 1200,
                    "classroomOccupancy": 88.0,
                    "laboratoryOccupancy": 95.0,
                    "schedulingEfficiency": 92.0
                }
            },
            {
                "departmentId": "dept2",
                "departmentName": "Mechanical Engineering",
                "metrics": {
                    "facultyWorkload": 75.0,
                    "resourceUtilization": 70.0,
                    "teachingHours": 950,
                    "classroomOccupancy": 72.0,
                    "laboratoryOccupancy": 80.0,
                    "schedulingEfficiency": 85.0
                }
            }
        ]
