from sqlalchemy.orm import Session as DBSession
from typing import List, Dict, Any
from datetime import datetime

from models.infrastructure import Classroom
from models.timetable import TimetableEntry, Timetable
from models.session import Session

class RoomReallocationEngine:
    def __init__(self, db: DBSession):
        self.db = db
        
    def recommend_alternative_rooms(self, room_id: str, day_of_week: int, period: int, duration: int = 1) -> List[Dict[str, Any]]:
        """
        Recommends alternative rooms when a room becomes unavailable.
        """
        # Find the room to get its capacity and type
        original_room = self.db.query(Classroom).filter(Classroom.id == room_id).first()
        if not original_room:
            return []
            
        # Find active timetable
        active_timetable = self.db.query(Timetable).filter(Timetable.status == "published").first()
        if not active_timetable:
            active_timetable = self.db.query(Timetable).filter(Timetable.status == "draft").first()
            
        if not active_timetable:
            return []
            
        # Find all rooms of the same type (theory vs lab)
        # Assuming Classroom model has a 'type' or we infer from name for now
        all_rooms = self.db.query(Classroom).filter(Classroom.id != room_id).all()
        
        # Find rooms that are busy during the required periods
        busy_room_ids = set()
        for i in range(duration):
            busy_entries = self.db.query(TimetableEntry).filter(
                TimetableEntry.timetableId == active_timetable.id,
                TimetableEntry.dayOfWeek == day_of_week,
                TimetableEntry.period == period + i
            ).all()
            for entry in busy_entries:
                if entry.roomId:
                    busy_room_ids.add(entry.roomId)
                    
        recommendations = []
        for room in all_rooms:
            if room.id in busy_room_ids:
                continue
                
            # Calculate score based on capacity match and building proximity
            score = 50
            
            # Capacity check
            if room.capacity >= original_room.capacity:
                score += 30
            else:
                # Penalty for being smaller
                score -= (original_room.capacity - room.capacity)
                
            # Building check (prefer same building)
            if room.buildingId == original_room.buildingId:
                score += 20
                
            if score > 0:
                recommendations.append({
                    "roomId": room.id,
                    "roomName": room.name,
                    "buildingId": room.buildingId,
                    "capacity": room.capacity,
                    "score": min(100, score)
                })
                
        # Sort by score descending
        recommendations.sort(key=lambda x: x["score"], reverse=True)
        return recommendations
