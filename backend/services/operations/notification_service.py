from sqlalchemy.orm import Session as DBSession
from typing import List, Dict, Any
import uuid

from models.operations import Notification

class NotificationService:
    def __init__(self, db: DBSession):
        self.db = db
        
    def send_notification(self, user_id: str, title: str, message: str, type: str = "info") -> Notification:
        """
        Sends a targeted notification to a user.
        """
        notification = Notification(
            id=str(uuid.uuid4()),
            userId=user_id,
            title=title,
            message=message,
            type=type,
            isRead=False
        )
        self.db.add(notification)
        self.db.commit()
        self.db.refresh(notification)
        return notification
        
    def get_user_notifications(self, user_id: str, unread_only: bool = False) -> List[Notification]:
        """
        Retrieves notifications for a user.
        """
        query = self.db.query(Notification).filter(Notification.userId == user_id)
        if unread_only:
            query = query.filter(Notification.isRead == False)
            
        return query.order_by(Notification.createdAt.desc()).all()
        
    def mark_as_read(self, notification_id: str) -> bool:
        """
        Marks a notification as read.
        """
        notification = self.db.query(Notification).filter(Notification.id == notification_id).first()
        if notification:
            notification.isRead = True
            self.db.commit()
            return True
        return False
        
    def notify_substitution(self, original_faculty_id: str, substitute_faculty_id: str, session_code: str, date: str):
        """
        Helper to send substitution notifications.
        """
        self.send_notification(
            user_id=original_faculty_id,
            title="Substitution Approved",
            message=f"Your substitution request for {session_code} on {date} has been approved.",
            type="substitution"
        )
        
        self.send_notification(
            user_id=substitute_faculty_id,
            title="New Substitution Assignment",
            message=f"You have been assigned as a substitute for {session_code} on {date}.",
            type="substitution"
        )
        
    def notify_room_change(self, faculty_id: str, session_code: str, old_room: str, new_room: str, date: str):
        """
        Helper to send room change notifications.
        """
        self.send_notification(
            user_id=faculty_id,
            title="Room Change Alert",
            message=f"Your class {session_code} on {date} has been moved from {old_room} to {new_room}.",
            type="change"
        )
