from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from core.database import get_db
from services.validation_engine import ValidationEngine
from schemas.validation import ValidationReportResponse
from models.validation import ValidationReport, ValidationResult

router = APIRouter(
    prefix="/api/v1/validation",
    tags=["Validation"]
)

@router.post("/run", response_model=ValidationReportResponse)
def run_validation(db: Session = Depends(get_db)):
    """
    Run the validation engine to check institution readiness for scheduling.
    """
    engine = ValidationEngine(db)
    report = engine.run_validation()
    
    # Fetch results to include in response
    results = db.query(ValidationResult).filter(ValidationResult.reportId == report.id).all()
    
    # Create response object
    response = ValidationReportResponse.model_validate(report)
    response.results = results
    
    return response

@router.get("/reports/latest", response_model=ValidationReportResponse)
def get_latest_report(db: Session = Depends(get_db)):
    """
    Get the latest validation report.
    """
    report = db.query(ValidationReport).order_by(ValidationReport.createdAt.desc()).first()
    if not report:
        raise HTTPException(status_code=404, detail="No validation reports found")
        
    results = db.query(ValidationResult).filter(ValidationResult.reportId == report.id).all()
    
    response = ValidationReportResponse.model_validate(report)
    response.results = results
    
    return response
