from sqlalchemy.orm import Session as DBSession
from typing import List, Dict, Any
import uuid

from models.operations import TimetableVersion, TimetableChange
from models.timetable import Timetable, TimetableEntry

class VersionManager:
    def __init__(self, db: DBSession):
        self.db = db
        
    def create_version(self, timetable_id: str, published_by: str, reason: str = None) -> TimetableVersion:
        """
        Creates a new version of the timetable.
        """
        # Get the latest version number
        latest_version = self.db.query(TimetableVersion).filter(
            TimetableVersion.timetableId == timetable_id
        ).order_by(TimetableVersion.versionNumber.desc()).first()
        
        version_number = (latest_version.versionNumber + 1) if latest_version else 1
        
        # Deactivate previous versions
        self.db.query(TimetableVersion).filter(
            TimetableVersion.timetableId == timetable_id
        ).update({"isActive": False})
        
        new_version = TimetableVersion(
            id=str(uuid.uuid4()),
            timetableId=timetable_id,
            versionNumber=version_number,
            publishedBy=published_by,
            reason=reason,
            isActive=True
        )
        self.db.add(new_version)
        self.db.commit()
        self.db.refresh(new_version)
        
        return new_version
        
    def log_change(self, version_id: str, session_id: str, changed_by: str, change_type: str, reason: str, old_data: dict, new_data: dict) -> TimetableChange:
        """
        Logs a change to the timetable in the current version.
        """
        change = TimetableChange(
            id=str(uuid.uuid4()),
            versionId=version_id,
            sessionId=session_id,
            changedBy=changed_by,
            changeType=change_type,
            reason=reason,
            oldDay=old_data.get('dayOfWeek'),
            oldPeriod=old_data.get('period'),
            oldRoomId=old_data.get('roomId'),
            oldFacultyId=old_data.get('facultyId'),
            newDay=new_data.get('dayOfWeek'),
            newPeriod=new_data.get('period'),
            newRoomId=new_data.get('roomId'),
            newFacultyId=new_data.get('facultyId')
        )
        self.db.add(change)
        self.db.commit()
        self.db.refresh(change)
        return change
        
    def rollback_to_version(self, timetable_id: str, target_version_id: str) -> bool:
        """
        Rolls back the timetable to a specific version.
        This is a complex operation that involves undoing changes.
        """
        target_version = self.db.query(TimetableVersion).filter(TimetableVersion.id == target_version_id).first()
        if not target_version:
            return False
            
        # Get all changes that happened AFTER the target version
        later_versions = self.db.query(TimetableVersion).filter(
            TimetableVersion.timetableId == timetable_id,
            TimetableVersion.versionNumber > target_version.versionNumber
        ).order_by(TimetableVersion.versionNumber.desc()).all()
        
        for version in later_versions:
            # Revert changes in reverse order
            changes = self.db.query(TimetableChange).filter(
                TimetableChange.versionId == version.id
            ).order_by(TimetableChange.createdAt.desc()).all()
            
            for change in changes:
                # Find the timetable entry and revert it
                entry = self.db.query(TimetableEntry).filter(
                    TimetableEntry.timetableId == timetable_id,
                    TimetableEntry.sessionId == change.sessionId
                ).first()
                
                if entry:
                    entry.dayOfWeek = change.oldDay
                    entry.period = change.oldPeriod
                    entry.roomId = change.oldRoomId
                    entry.facultyId = change.oldFacultyId
                    
            # Deactivate the reverted version
            version.isActive = False
            
        # Activate the target version
        target_version.isActive = True
        self.db.commit()
        return True
