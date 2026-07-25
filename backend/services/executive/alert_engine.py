from sqlalchemy.orm import Session as DBSession
from typing import Dict, Any, List

class AlertEngine:
    def __init__(self, db: DBSession):
        self.db = db
        
    def get_active_alerts(self) -> List[Dict[str, Any]]:
        """
        Retrieves active executive alerts based on configured thresholds.
        """
        # Mock data
        return [
            {
                "id": "alert1",
                "severity": "high",
                "message": "Faculty workload in CS department exceeds AICTE limits.",
                "metric": "faculty_workload",
                "value": 22,
                "threshold": 20
            },
            {
                "id": "alert2",
                "severity": "medium",
                "message": "Engineering Block classroom utilization is above 95%.",
                "metric": "classroom_utilization",
                "value": 96,
                "threshold": 95
            }
        ]
