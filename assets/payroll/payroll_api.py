#!/usr/bin/env python3
"""
Payroll REST API - ABC Technologies
FastAPI application with full request logging.
"""
import os
import logging
import time
from datetime import datetime
from typing import Optional, List
from decimal import Decimal
from fastapi import FastAPI, HTTPException, Depends, UploadFile, File, Form, Query, Request
from fastapi.security import APIKeyHeader
from fastapi.responses import HTMLResponse, JSONResponse
from pydantic import BaseModel, Field, validator
import uvicorn

from payroll_system import PayrollSystem

# ---------- Logging Configuration ----------
LOG_DIR = os.getenv("PAYROLL_LOG_DIR", "logs")
os.makedirs(LOG_DIR, exist_ok=True)

# Main logger for all requests
request_logger = logging.getLogger("payroll_requests")
request_logger.setLevel(logging.INFO)
request_handler = logging.FileHandler(os.path.join(LOG_DIR, "payroll.log"))
request_handler.setFormatter(
    logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
)
request_logger.addHandler(request_handler)

# Error logger for errors
error_logger = logging.getLogger("payroll_errors")
error_logger.setLevel(logging.ERROR)
error_handler = logging.FileHandler(os.path.join(LOG_DIR, "payroll_errors.log"))
error_handler.setFormatter(
    logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
)
error_logger.addHandler(error_handler)

# Also log to console for development
console = logging.StreamHandler()
console.setLevel(logging.INFO)
console.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
request_logger.addHandler(console)
error_logger.addHandler(console)

# ---------- Configuration ----------
API_KEY = os.getenv("PAYROLL_API_KEY", "your-secret-key")
API_KEY_HEADER = APIKeyHeader(name="X-API-Key", auto_error=False)

# ---------- Pydantic Models ----------
class SalaryStructureCreate(BaseModel):
    employee_id: int
    salary_type: str = Field(..., pattern="^(Annual|Hourly)$")
    annual_salary: Optional[float] = None
    hourly_rate: Optional[float] = None
    overtime_rate: float = 0.0
    effective_date: Optional[str] = None

    @validator('annual_salary')
    def validate_annual(cls, v, values):
        if values.get('salary_type') == 'Annual' and v is None:
            raise ValueError('Annual salary required for Annual type')
        return v

    @validator('hourly_rate')
    def validate_hourly(cls, v, values):
        if values.get('salary_type') == 'Hourly' and v is None:
            raise ValueError('Hourly rate required for Hourly type')
        return v

class PayrollProcessRequest(BaseModel):
    employee_id: int
    pay_period_start: str
    pay_period_end: str
    bonus: float = 0.0

class PayslipResponse(BaseModel):
    payroll_id: int
    employee_id: int
    pay_period_start: str
    pay_period_end: str
    gross_pay: float
    net_pay: float
    tax_withheld: float
    pension_contribution: float
    health_insurance: float

# ---------- FastAPI App ----------
app = FastAPI(
    title="ABC Technologies Payroll API",
    version="1.0.0",
    description="REST API for employee payroll management with full request logging",
    docs_url="/docs",
    redoc_url="/redoc"
)

# ---------- Request Logging Middleware ----------
@app.middleware("http")
async def log_requests(request: Request, call_next):
    """Log every request with method, path, status, duration, client IP."""
    start_time = time.time()
    
    # Get client IP
    client_ip = request.client.host if request.client else "unknown"
    forwarded = request.headers.get("X-Forwarded-For")
    if forwarded:
        client_ip = forwarded.split(",")[0].strip()
    
    # Prepare log details
    method = request.method
    path = request.url.path
    query = str(request.url.query)
    full_path = f"{path}?{query}" if query else path
    
    # Process request
    try:
        response = await call_next(request)
        status_code = response.status_code
    except Exception as e:
        # Log error and re-raise
        error_logger.error(f"Request failed: {method} {full_path} - {str(e)}")
        raise
    
    # Calculate duration
    duration_ms = (time.time() - start_time) * 1000
    
    # Log the request
    log_msg = (
        f"{client_ip} - {method} {full_path} - "
        f"{status_code} - {duration_ms:.2f}ms"
    )
    request_logger.info(log_msg)
    
    # Also log errors separately
    if status_code >= 400:
        error_logger.error(
            f"{client_ip} - {method} {full_path} - "
            f"{status_code} - {duration_ms:.2f}ms"
        )
    
    return response

# ---------- Global Dependencies ----------
payroll_system = None

def get_payroll_system():
    global payroll_system
    if payroll_system is None:
        payroll_system = PayrollSystem()
    return payroll_system

def verify_api_key(api_key: str = Depends(API_KEY_HEADER)):
    if api_key is None:
        raise HTTPException(status_code=401, detail="API Key required")
    if api_key != API_KEY:
        raise HTTPException(status_code=403, detail="Invalid API Key")
    return api_key

# ---------- Startup / Shutdown ----------
@app.on_event("startup")
async def startup_event():
    global payroll_system
    payroll_system = PayrollSystem()
    request_logger.info("Payroll system initialized")

@app.on_event("shutdown")
async def shutdown_event():
    if payroll_system:
        payroll_system.close()
        request_logger.info("Payroll system closed")

# ---------- Serve Web Interface ----------
@app.get("/", response_class=HTMLResponse)
async def serve_web_interface():
    """Serve the payroll management web interface."""
    try:
        with open("web/payroll.html", "r", encoding="utf-8") as f:
            return f.read()
    except FileNotFoundError:
        return HTMLResponse("<h1>Payroll Interface</h1><p>web/payroll.html not found.</p>")

# ---------- API Routes ----------
@app.get("/api/employees", dependencies=[Depends(verify_api_key)])
async def get_employees(ps: PayrollSystem = Depends(get_payroll_system)):
    """Get list of all employees."""
    employees = ps.get_employees()
    return {"employees": employees}

@app.get("/api/employees/{employee_id}", dependencies=[Depends(verify_api_key)])
async def get_employee(employee_id: int, ps: PayrollSystem = Depends(get_payroll_system)):
    """Get a single employee by ID."""
    employee = ps.get_employee(employee_id)
    if not employee:
        raise HTTPException(status_code=404, detail="Employee not found")
    return employee

@app.get("/api/employees/{employee_id}/salary", dependencies=[Depends(verify_api_key)])
async def get_salary(employee_id: int, ps: PayrollSystem = Depends(get_payroll_system)):
    """Get current salary structure for an employee."""
    salary = ps.get_salary_structure(employee_id)
    if not salary:
        raise HTTPException(status_code=404, detail="Salary structure not found")
    return salary

@app.post("/api/salary", dependencies=[Depends(verify_api_key)])
async def set_salary_structure(data: SalaryStructureCreate, 
                              ps: PayrollSystem = Depends(get_payroll_system)):
    """Set or update salary structure for an employee."""
    try:
        result = ps.set_salary_structure(
            employee_id=data.employee_id,
            salary_type=data.salary_type,
            annual_salary=Decimal(data.annual_salary) if data.annual_salary else None,
            hourly_rate=Decimal(data.hourly_rate) if data.hourly_rate else None,
            overtime_rate=Decimal(data.overtime_rate),
            effective_date=data.effective_date
        )
        print(result)
        return result
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.post("/api/timesheet/import", dependencies=[Depends(verify_api_key)])
async def import_timesheet(
    employee_id: int = Form(...),
    file: UploadFile = File(...),
    ps: PayrollSystem = Depends(get_payroll_system)
):
    """Import timesheet CSV file for an employee."""
    assert file.filename is not None
    if not file.filename.endswith('.csv'):
        raise HTTPException(status_code=400, detail="Only CSV files are allowed")
    
    content = await file.read()
    csv_text = content.decode('utf-8')
    
    try:
        result = ps.import_timesheet_csv(csv_text, employee_id)
        return result
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/api/timesheet/{employee_id}", dependencies=[Depends(verify_api_key)])
async def get_timesheets(
    employee_id: int,
    start_date: str = Query(..., description="Start date (YYYY-MM-DD)"),
    end_date: str = Query(..., description="End date (YYYY-MM-DD)"),
    ps: PayrollSystem = Depends(get_payroll_system)
):
    """Get timesheets for an employee within a date range."""
    try:
        timesheets = ps.get_timesheets(employee_id, start_date, end_date)
        return {"employee_id": employee_id, "timesheets": timesheets}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.post("/api/payroll/process", dependencies=[Depends(verify_api_key)])
async def process_payroll(data: PayrollProcessRequest,
                         ps: PayrollSystem = Depends(get_payroll_system)):
    """Process payroll for a single employee for a given period."""
    try:
        result = ps.calculate_payroll(
            employee_id=data.employee_id,
            pay_period_start=data.pay_period_start,
            pay_period_end=data.pay_period_end,
            bonus=Decimal(data.bonus)
        )
        return {"payroll_id": result["payroll_id"], "details": result}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/api/payslip/{employee_id}/{payroll_id}", response_model=PayslipResponse, 
         dependencies=[Depends(verify_api_key)])
async def get_payslip(employee_id: int, payroll_id: int,
                     ps: PayrollSystem = Depends(get_payroll_system)):
    """Get payslip details for a specific payroll record."""
    try:
        payslip = ps.get_payslip(employee_id, payroll_id)
        return {
            "payroll_id": payslip['id'],
            "employee_id": payslip['employee_id'],
            "pay_period_start": payslip['pay_period_start'],
            "pay_period_end": payslip['pay_period_end'],
            "gross_pay": float(payslip['gross_pay']),
            "net_pay": float(payslip['net_pay']),
            "tax_withheld": float(payslip['tax_withheld']),
            "pension_contribution": float(payslip['pension_contribution']),
            "health_insurance": float(payslip['health_insurance'])
        }
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))

@app.get("/api/report", dependencies=[Depends(verify_api_key)])
async def generate_report(
    pay_period_start: str = Query(..., description="Start date (YYYY-MM-DD)"),
    pay_period_end: str = Query(..., description="End date (YYYY-MM-DD)"),
    ps: PayrollSystem = Depends(get_payroll_system)
):
    """Get payroll report for a period as JSON."""
    try:
        rows = ps.generate_payroll_report(pay_period_start, pay_period_end)
        return {"report": rows}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/api/summary/{employee_id}", dependencies=[Depends(verify_api_key)])
async def get_summary(
    employee_id: int,
    year: int = Query(default=datetime.now().year),
    month: int = Query(default=datetime.now().month, ge=1, le=12),
    ps: PayrollSystem = Depends(get_payroll_system)
):
    """Get monthly payroll summary for an employee."""
    try:
        summary = ps.get_payroll_summary(employee_id, year, month)
        return summary
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/api/health")
async def health_check():
    """Health check endpoint (no auth required)."""
    return {"status": "healthy", "timestamp": datetime.now().isoformat()}

# ---------- Main Entry Point ----------
if __name__ == "__main__":
    uvicorn.run(
        "payroll_api:app",
        host="0.0.0.0",
        port=8001,
        reload=True,
        log_level="info"
    )