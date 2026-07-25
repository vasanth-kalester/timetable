from sqlalchemy import Column, String, Integer, Float, ForeignKey, JSON
from core.database import Base
import time

class ValidationReport(Base):
    __tablename__ = "ValidationReport"

    id = Column(String, primary_key=True, index=True)
    academicYearId = Column("academicYearId", String, nullable=False)
    institutionReadiness = Column("institutionReadiness", Float, default=0.0)
    departmentReadiness = Column("departmentReadiness", Float, default=0.0)
    sectionReadiness = Column("sectionReadiness", Float, default=0.0)
    sessionReadiness = Column("sessionReadiness", Float, default=0.0)
    overallReadiness = Column("overallReadiness", Float, default=0.0)
    status = Column(String, default="failed") # passed, failed, warnings
    createdAt = Column("createdAt", Integer, default=lambda: int(time.time() * 1000))

class ValidationResult(Base):
    __tablename__ = "ValidationResult"

    id = Column(String, primary_key=True, index=True)
    reportId = Column("reportId", String, ForeignKey("ValidationReport.id"), nullable=False)
    category = Column(String, nullable=False) # institution, department, section, subject, faculty, laboratory
    entityId = Column("entityId", String, nullable=True)
    entityName = Column("entityName", String, nullable=True)
    status = Column(String, nullable=False) # passed, warning, error, critical
    message = Column(String, nullable=False)
    suggestion = Column(String, nullable=True)
    severity = Column(String, nullable=False) # info, warning, error, critical
    createdAt = Column("createdAt", Integer, default=lambda: int(time.time() * 1000))
