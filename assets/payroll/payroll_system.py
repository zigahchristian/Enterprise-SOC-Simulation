#!/usr/bin/env python3
"""
Payroll System - ABC Technologies
Core business logic for employee salary management, timesheets, and payroll processing.
"""
import sqlite3
import csv
import datetime
import os
from decimal import Decimal, ROUND_HALF_UP
from typing import Optional, List, Dict, Any, Tuple
from io import StringIO

# Configuration
DB_PATH = os.getenv('DB_FILE', 'db/payroll.db')
TAX_RATE = 0.15
PENSION_RATE = 0.05
HEALTH_INSURANCE_EMPLOYEE = Decimal('150.00')


class PayrollSystem:
    def __init__(self, db_path: str = DB_PATH):
        self.db_path = db_path
        self.conn = sqlite3.connect(db_path)
        self.conn.row_factory = sqlite3.Row
        self._create_tables_if_not_exist()

    def _create_tables_if_not_exist(self):
        """Create all payroll tables if they don't exist."""
        cur = self.conn.cursor()
        cur.executescript("""
            CREATE TABLE IF NOT EXISTS employees (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            first_name TEXT NOT NULL,
            last_name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            department_id INTEGER NOT NULL,
            job_title TEXT,
            hire_date DATE,
            is_active BOOLEAN DEFAULT 1
            );

            
            CREATE TABLE IF NOT EXISTS salary_structures (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                employee_id INTEGER NOT NULL,
                salary_type TEXT CHECK(salary_type IN ('Annual', 'Hourly')) NOT NULL,
                annual_salary DECIMAL(10,2),
                hourly_rate DECIMAL(8,2),
                overtime_rate DECIMAL(8,2) DEFAULT 0.0,
                effective_date DATE NOT NULL,
                is_current BOOLEAN DEFAULT 1
            );

            CREATE TABLE IF NOT EXISTS payroll (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                employee_id INTEGER NOT NULL,
                pay_period_start DATE NOT NULL,
                pay_period_end DATE NOT NULL,
                hours_worked DECIMAL(8,2) DEFAULT 0,
                overtime_hours DECIMAL(8,2) DEFAULT 0,
                bonus DECIMAL(10,2) DEFAULT 0,
                gross_pay DECIMAL(10,2) NOT NULL,
                tax_withheld DECIMAL(10,2) NOT NULL,
                pension_contribution DECIMAL(10,2) NOT NULL,
                health_insurance DECIMAL(10,2) DEFAULT 0,
                net_pay DECIMAL(10,2) NOT NULL,
                processed_date DATETIME DEFAULT CURRENT_TIMESTAMP,
                payslip_generated BOOLEAN DEFAULT 0
            );

            CREATE TABLE IF NOT EXISTS timesheets (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                employee_id INTEGER NOT NULL,
                date DATE NOT NULL,
                hours DECIMAL(4,2) NOT NULL,
                is_overtime BOOLEAN DEFAULT 0
            );

            CREATE TABLE IF NOT EXISTS payroll_audit (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                action TEXT NOT NULL,
                employee_id INTEGER,
                details TEXT,
                changed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                performed_by TEXT
            );
        """)
        self.conn.commit()

    def _log_audit(self, action: str, employee_id: Optional[int] = None, 
                   details: str = "", performed_by: str = "SYSTEM"):
        """Log payroll actions to audit table."""
        cur = self.conn.cursor()
        cur.execute(
            "INSERT INTO payroll_audit (action, employee_id, details, performed_by) VALUES (?, ?, ?, ?)",
            (action, employee_id, details, performed_by)
        )
        self.conn.commit()

    # ---------- Employee Methods ----------
    def get_employees(self) -> List[Dict[str, Any]]:
        """Get all employees from the database."""
        cur = self.conn.cursor()
        cur.execute("SELECT id, first_name, last_name, email, job_title, department_id FROM employees ORDER BY last_name")
        rows = cur.fetchall()
        return [dict(row) for row in rows]

    def get_employee(self, employee_id: int) -> Optional[Dict[str, Any]]:
        """Get a single employee by ID."""
        cur = self.conn.cursor()
        cur.execute("SELECT id, first_name, last_name, email, job_title, department_id FROM employees WHERE id = ?", (employee_id,))
        row = cur.fetchone()
        return dict(row) if row else None

    # ---------- Salary Structure ----------
    def set_salary_structure(self, employee_id: int, salary_type: str,
                         annual_salary: Optional[Decimal] = None,
                         hourly_rate: Optional[Decimal] = None,
                         overtime_rate: Decimal = Decimal('0.0'),
                         effective_date: Optional[str] = None):
        """Set or update salary structure for an employee."""
        if salary_type not in ('Annual', 'Hourly'):
            raise ValueError("salary_type must be 'Annual' or 'Hourly'")
        if salary_type == 'Annual' and annual_salary is None:
            raise ValueError("Annual salary required for salary_type 'Annual'")
        if salary_type == 'Hourly' and hourly_rate is None:
            raise ValueError("Hourly rate required for salary_type 'Hourly'")

        if effective_date is None or effective_date == "":
            effective_date = datetime.date.today().isoformat()

        cur = self.conn.cursor()
        # Deactivate current structure
        cur.execute(
            "UPDATE salary_structures SET is_current = 0 WHERE employee_id = ? AND is_current = 1",
            (employee_id,)
        )
        
        # Convert Decimal to float for SQLite binding
        annual = float(annual_salary) if annual_salary is not None else None
        hourly = float(hourly_rate) if hourly_rate is not None else None
        overtime = float(overtime_rate) if overtime_rate is not None else 0.0
        
        # Insert new structure
        cur.execute("""
            INSERT INTO salary_structures
            (employee_id, salary_type, annual_salary, hourly_rate, overtime_rate, effective_date, is_current)
            VALUES (?, ?, ?, ?, ?, ?, 1)
        """, (employee_id, salary_type, annual, hourly, overtime, effective_date))
        self.conn.commit()
        self._log_audit("SET_SALARY", employee_id, f"{salary_type} structure set", "ADMIN")
        return {"message": "Salary structure updated"}



    def get_salary_structure(self, employee_id: int) -> Optional[Dict[str, Any]]:
        """Get current salary structure for an employee."""
        cur = self.conn.cursor()
        cur.execute("""
            SELECT salary_type, annual_salary, hourly_rate, overtime_rate, effective_date
            FROM salary_structures
            WHERE employee_id = ? AND is_current = 1
        """, (employee_id,))
        row = cur.fetchone()
        if row:
            return {
                "salary_type": row['salary_type'],
                "annual_salary": float(row['annual_salary']) if row['annual_salary'] is not None else None,
                "hourly_rate": float(row['hourly_rate']) if row['hourly_rate'] is not None else None,
                "overtime_rate": float(row['overtime_rate']) if row['overtime_rate'] is not None else 0.0,
                "effective_date": row['effective_date']
            }
        return None

    # ---------- Timesheets ----------
    def import_timesheet_csv(self, csv_content: str, employee_id: int) -> Dict[str, Any]:
        """
        Import timesheet data from CSV string.
        Expected format: date,hours,is_overtime
        """
        cur = self.conn.cursor()
        reader = csv.DictReader(StringIO(csv_content))
        count = 0
        for row in reader:
            date = row['date']
            hours = Decimal(row['hours'])
            is_overtime = int(row.get('is_overtime', 0))
            cur.execute(
                "INSERT INTO timesheets (employee_id, date, hours, is_overtime) VALUES (?, ?, ?, ?)",
                (employee_id, date, hours, is_overtime)
            )
            count += 1
        self.conn.commit()
        self._log_audit("IMPORT_TIMESHEET", employee_id, f"Imported {count} records", "ADMIN")
        return {"message": f"Imported {count} timesheet records"}

    def get_timesheets(self, employee_id: int, start_date: str, end_date: str) -> List[Dict[str, Any]]:
        """Get timesheets for an employee within a date range."""
        cur = self.conn.cursor()
        cur.execute("""
            SELECT date, hours, is_overtime
            FROM timesheets
            WHERE employee_id = ? AND date BETWEEN ? AND ?
            ORDER BY date
        """, (employee_id, start_date, end_date))
        rows = cur.fetchall()
        return [dict(row) for row in rows]

    # ---------- Payroll Processing ----------
    def calculate_payroll(self, employee_id: int, pay_period_start: str, 
                          pay_period_end: str, bonus: Decimal = Decimal('0')) -> Dict[str, Any]:
        """
        Calculate and record payroll for a single employee.
        Returns payroll record ID and details.
        """
        cur = self.conn.cursor()

        # Get salary structure
        cur.execute("""
            SELECT salary_type, annual_salary, hourly_rate, overtime_rate
            FROM salary_structures
            WHERE employee_id = ? AND is_current = 1
        """, (employee_id,))
        struct = cur.fetchone()
        if not struct:
            raise ValueError(f"No active salary structure for employee {employee_id}")

        salary_type = struct['salary_type']
        annual_salary = struct['annual_salary'] or Decimal('0')
        hourly_rate = struct['hourly_rate'] or Decimal('0')
        overtime_rate = struct['overtime_rate'] or Decimal('0')

        # Get total hours from timesheets in period
        cur.execute("""
            SELECT 
                SUM(hours) as total_hours,
                SUM(CASE WHEN is_overtime THEN hours ELSE 0 END) as overtime_hours
            FROM timesheets
            WHERE employee_id = ? AND date BETWEEN ? AND ?
        """, (employee_id, pay_period_start, pay_period_end))
        time_data = cur.fetchone()
        hours_worked = Decimal(str(time_data['total_hours'] or 0))
        overtime_hours = Decimal(str(time_data['overtime_hours'] or 0))

        # Calculate gross pay
        if salary_type == 'Annual':
            monthly_salary = (annual_salary / Decimal('12')).quantize(Decimal('0.01'), rounding=ROUND_HALF_UP)
            gross = monthly_salary + bonus
            hours_worked = Decimal('0')
            overtime_hours = Decimal('0')
        else:
            regular_hours = hours_worked - overtime_hours
            gross = (regular_hours * hourly_rate) + (overtime_hours * overtime_rate) + bonus

        # Calculate deductions
        tax = (gross * Decimal(TAX_RATE)).quantize(Decimal('0.01'), rounding=ROUND_HALF_UP)
        pension = (gross * Decimal(PENSION_RATE)).quantize(Decimal('0.01'), rounding=ROUND_HALF_UP)
        health = HEALTH_INSURANCE_EMPLOYEE
        net = gross - tax - pension - health

        # Insert payroll record
        cur.execute("""
            INSERT INTO payroll
            (employee_id, pay_period_start, pay_period_end, hours_worked, overtime_hours,
             bonus, gross_pay, tax_withheld, pension_contribution, health_insurance, net_pay)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (employee_id, pay_period_start, pay_period_end, float(hours_worked), float(overtime_hours),
              float(bonus), float(gross), float(tax), float(pension), float(health), float(net)))
        self.conn.commit()
        payroll_id = cur.lastrowid
        self._log_audit("PROCESS_PAYROLL", employee_id, f"Payroll ID {payroll_id}, Net: {net}", "ADMIN")

        return {
            "payroll_id": payroll_id,
            "employee_id": employee_id,
            "gross_pay": float(gross),
            "net_pay": float(net),
            "tax_withheld": float(tax),
            "pension_contribution": float(pension),
            "health_insurance": float(health)
        }

    # ---------- Payslip ----------
    def get_payslip(self, employee_id: int, payroll_id: int) -> Dict[str, Any]:
        """Get complete payslip details for a payroll record."""
        cur = self.conn.cursor()
        cur.execute("""
            SELECT 
                p.id,
                p.employee_id,
                p.pay_period_start,
                p.pay_period_end,
                p.hours_worked,
                p.overtime_hours,
                p.bonus,
                p.gross_pay,
                p.tax_withheld,
                p.pension_contribution,
                p.health_insurance,
                p.net_pay,
                p.processed_date,
                e.first_name,
                e.last_name,
                e.email,
                e.job_title
            FROM payroll p
            JOIN employees e ON p.employee_id = e.id
            WHERE p.id = ? AND p.employee_id = ?
        """, (payroll_id, employee_id))
        row = cur.fetchone()
        if not row:
            raise ValueError("Payroll record not found")
        return dict(row)

    # ---------- Reports ----------
    def generate_payroll_report(self, pay_period_start: str, pay_period_end: str) -> List[Dict[str, Any]]:
        """Generate payroll report for a period."""
        cur = self.conn.cursor()
        cur.execute("""
            SELECT 
                e.id AS employee_id,
                e.first_name,
                e.last_name,
                p.pay_period_start,
                p.pay_period_end,
                p.hours_worked,
                p.overtime_hours,
                p.gross_pay,
                p.tax_withheld,
                p.pension_contribution,
                p.health_insurance,
                p.net_pay
            FROM payroll p
            JOIN employees e ON p.employee_id = e.id
            WHERE p.pay_period_start = ? AND p.pay_period_end = ?
            ORDER BY e.last_name
        """, (pay_period_start, pay_period_end))
        rows = cur.fetchall()
        return [dict(row) for row in rows]

    def get_payroll_summary(self, employee_id: int, year: int, month: int) -> Dict[str, Any]:
        """Get monthly payroll summary for an employee."""
        cur = self.conn.cursor()
        cur.execute("""
            SELECT 
                COUNT(*) as count,
                SUM(gross_pay) as total_gross,
                SUM(net_pay) as total_net,
                SUM(tax_withheld) as total_tax,
                SUM(pension_contribution) as total_pension
            FROM payroll
            WHERE employee_id = ?
                AND strftime('%Y', pay_period_start) = ?
                AND strftime('%m', pay_period_start) = ?
        """, (employee_id, str(year), str(month).zfill(2)))
        row = cur.fetchone()
        return dict(row) if row else {"count": 0, "total_gross": 0, "total_net": 0, "total_tax": 0, "total_pension": 0}

    # ---------- Cleanup ----------
    def close(self):
        """Close database connection."""
        self.conn.close()

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()