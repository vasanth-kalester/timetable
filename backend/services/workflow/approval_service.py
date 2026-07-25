from sqlalchemy.orm import Session as DBSession
from typing import Dict, Any, List
import uuid
from datetime import datetime

class ApprovalService:
    def __init__(self, db: DBSession):
        self.db = db
        
    def create_request(self, requester_id: str, request_type: str, details: Dict[str, Any], required_role: str) -> Dict[str, Any]:
        """
        Creates a new approval request.
        """
        # In a real implementation, this would save to the ApprovalRequest model.
        request_id = str(uuid.uuid4())
        
        return {
            "id": request_id,
            "requesterId": requester_id,
            "type": request_type,
            "details": details,
            "status": "pending",
            "requiredRole": required_role,
            "createdAt": datetime.utcnow().isoformat()
        }
        
    def process_request(self, request_id: str, approver_id: str, action: str, comments: str = None) -> Dict[str, Any]:
        """
        Approves or rejects a request.
        """
        # In a real implementation, this would update the ApprovalRequest model.
        if action not in ["approve", "reject"]:
            raise ValueError("Action must be 'approve' or 'reject'")
            
        return {
            "id": request_id,
            "status": "approved" if action == "approve" else "rejected",
            "approverId": approver_id,
            "comments": comments,
            "processedAt": datetime.utcnow().isoformat()
        }
