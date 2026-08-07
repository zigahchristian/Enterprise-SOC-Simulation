-- ============================================================
-- ABC TECHNOLOGIES - CAPSTONE PROJECT DATABASE
-- SQLite schema for Enterprise SOC Simulation
-- Includes employee directory, authentication, alerts, and logs
-- ============================================================

-- Enable foreign key constraints (SQLite)
PRAGMA foreign_keys = ON;

-- ============================================================
-- 1. DEPARTMENTS
-- ============================================================
CREATE TABLE departments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    location TEXT
);

INSERT INTO departments (name, location) VALUES
('Human Resources', 'Accra'),
('Finance', 'Accra'),
('Sales', 'Kumasi'),
('IT', 'Accra'),
('Customer Support', 'Kumasi');

-- ============================================================
-- 2. EMPLOYEES
-- ============================================================
CREATE TABLE employees (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    department_id INTEGER NOT NULL,
    job_title TEXT,
    hire_date DATE,
    is_active BOOLEAN DEFAULT 1,
    FOREIGN KEY (department_id) REFERENCES departments(id)
);

-- Insert 15 sample employees (mix of departments)
INSERT INTO employees (first_name, last_name, email, department_id, job_title, hire_date) VALUES
('John', 'Doe', 'john.doe@abctechnologies.gh', 4, 'Tier 1 SOC Analyst', '2024-01-15'),
('Jane', 'Smith', 'jane.smith@abctechnologies.gh', 4, 'Security Engineer', '2023-06-01'),
('Michael', 'Johnson', 'michael.johnson@abctechnologies.gh', 2, 'Finance Manager', '2020-03-10'),
('Emily', 'Brown', 'emily.brown@abctechnologies.gh', 1, 'HR Director', '2019-11-20'),
('David', 'Wilson', 'david.wilson@abctechnologies.gh', 3, 'Sales Executive', '2022-08-05'),
('Sarah', 'Martinez', 'sarah.martinez@abctechnologies.gh', 5, 'Support Lead', '2021-02-14'),
('James', 'Anderson', 'james.anderson@abctechnologies.gh', 4, 'Network Admin', '2023-09-01'),
('Linda', 'Thomas', 'linda.thomas@abctechnologies.gh', 1, 'Recruiter', '2024-02-01'),
('Robert', 'Jackson', 'robert.jackson@abctechnologies.gh', 2, 'Accountant', '2020-07-15'),
('Maria', 'White', 'maria.white@abctechnologies.gh', 3, 'Sales Manager', '2021-05-20'),
('William', 'Harris', 'william.harris@abctechnologies.gh', 5, 'Support Analyst', '2023-11-01'),
('Elizabeth', 'Martin', 'elizabeth.martin@abctechnologies.gh', 4, 'DevOps Engineer', '2022-12-01'),
('Richard', 'Thompson', 'richard.thompson@abctechnologies.gh', 2, 'Financial Analyst', '2021-09-10'),
('Jennifer', 'Garcia', 'jennifer.garcia@abctechnologies.gh', 1, 'HR Coordinator', '2024-03-01'),
('Charles', 'Martinez', 'charles.martinez@abctechnologies.gh', 3, 'Sales Representative', '2023-06-15');

-- ============================================================
-- 3. USERS (for authentication / login)
-- ============================================================
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_id INTEGER NOT NULL,
    username TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,  -- In production, store bcrypt hashes; plaintext for demo
    last_login DATETIME,
    is_locked BOOLEAN DEFAULT 0,
    failed_attempts INTEGER DEFAULT 0,
    FOREIGN KEY (employee_id) REFERENCES employees(id)
);

-- Demo passwords: 'password123' (hashed with simple SHA-256 for illustration, but using plaintext for demo)
-- In a real project, use bcrypt or similar; we'll store plaintext for testing.
INSERT INTO users (employee_id, username, password_hash, last_login) VALUES
(1, 'jdoe', 'password123', '2026-07-26 09:15:00'),
(2, 'jsmith', 'password123', '2026-07-25 16:20:00'),
(3, 'mjohnson', 'password123', '2026-07-24 11:00:00'),
(4, 'ebrown', 'password123', '2026-07-23 08:45:00'),
(5, 'dwilson', 'password123', '2026-07-26 10:30:00'),
(6, 'smartinez', 'password123', '2026-07-25 14:10:00'),
(7, 'janderson', 'password123', '2026-07-26 08:00:00');

-- ============================================================
-- 4. ALERTS (SIEM alerts from Splunk / Suricata)
-- ============================================================
CREATE TABLE alerts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    severity TEXT CHECK(severity IN ('Low', 'Medium', 'High', 'Critical')),
    source TEXT,
    description TEXT,
    event_type TEXT,
    assigned_to INTEGER,  -- employee_id
    status TEXT CHECK(status IN ('Open', 'Investigating', 'Contained', 'Resolved', 'False Positive')),
    resolution_notes TEXT,
    FOREIGN KEY (assigned_to) REFERENCES employees(id)
);

INSERT INTO alerts (timestamp, severity, source, description, event_type, assigned_to, status) VALUES
('2026-07-26 14:32:00', 'Medium', '10.0.1.45', 'Failed SSH login attempts (×5) from IP 10.0.1.45', 'Authentication', 1, 'Investigating'),
('2026-07-26 13:15:00', 'High', '10.0.2.12', 'Port scan detected against subnet 10.0.0.0/24', 'Network Scan', 7, 'Resolved'),
('2026-07-26 11:02:00', 'Critical', 'endpoint-07', 'EICAR test file detected on workstation endpoint-07', 'Malware', 2, 'Contained'),
('2026-07-25 22:10:00', 'High', '10.0.1.88', 'Suspicious outbound traffic to known malicious IP (185.xxx.xxx.xxx)', 'Data Exfiltration', 2, 'Open'),
('2026-07-25 08:30:00', 'Low', '10.0.3.5', 'Unauthorized USB device connected to workstation', 'Policy Violation', 1, 'Resolved'),
('2026-07-24 16:45:00', 'Medium', '10.0.1.22', 'Multiple failed login attempts to payroll server', 'Authentication', 3, 'Investigating'),
('2026-07-24 09:10:00', 'Critical', '10.0.2.99', 'Ransomware file detected (WannaCry variant) - blocked by AV', 'Malware', 2, 'Contained'),
('2026-07-23 14:20:00', 'High', '10.0.1.56', 'Privilege escalation attempt detected (sudo abuse)', 'Privilege Escalation', 7, 'Resolved');

-- ============================================================
-- 5. LOGS (System, Authentication, Network, etc.)
-- ============================================================
CREATE TABLE logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    event_type TEXT CHECK(event_type IN ('Auth', 'System', 'Network', 'Application', 'Security')),
    source_ip TEXT,
    username TEXT,   -- could be employee username
    details TEXT,
    raw_log TEXT   -- store full log line for reference
);

-- Insert sample logs (failed logins, successful logins, system events)
INSERT INTO logs (timestamp, event_type, source_ip, username, details, raw_log) VALUES
('2026-07-26 14:31:55', 'Auth', '10.0.1.45', 'jdoe', 'Failed password for jdoe from 10.0.1.45 port 22 ssh2', 'sshd[1234]: Failed password for invalid user jdoe from 10.0.1.45 port 22 ssh2'),
('2026-07-26 14:32:01', 'Auth', '10.0.1.45', 'jdoe', 'Failed password for jdoe from 10.0.1.45 port 22 ssh2', 'sshd[1235]: Failed password for invalid user jdoe from 10.0.1.45 port 22 ssh2'),
('2026-07-26 14:32:05', 'Auth', '10.0.1.45', 'jdoe', 'Failed password for jdoe from 10.0.1.45 port 22 ssh2', 'sshd[1236]: Failed password for invalid user jdoe from 10.0.1.45 port 22 ssh2'),
('2026-07-26 14:32:09', 'Auth', '10.0.1.45', 'jdoe', 'Failed password for jdoe from 10.0.1.45 port 22 ssh2', 'sshd[1237]: Failed password for invalid user jdoe from 10.0.1.45 port 22 ssh2'),
('2026-07-26 14:32:13', 'Auth', '10.0.1.45', 'jdoe', 'Failed password for jdoe from 10.0.1.45 port 22 ssh2', 'sshd[1238]: Failed password for invalid user jdoe from 10.0.1.45 port 22 ssh2'),
('2026-07-26 13:15:02', 'Network', '10.0.2.12', NULL, 'Nmap scan detected on port 22, 80, 443, 3389', 'suricata[567]: Nmap scan from 10.0.2.12 targeting 10.0.0.0/24'),
('2026-07-26 11:02:00', 'Security', 'endpoint-07', 'jdoe', 'EICAR test file saved to Downloads folder', 'Windows Defender: Threat detected EICAR-Test-File'),
('2026-07-25 22:10:00', 'Network', '10.0.1.88', NULL, 'Outbound connection to 185.xxx.xxx.xxx port 4444', 'Suricata: ET TROJAN Known malicious IP communication'),
('2026-07-25 22:10:05', 'Network', '10.0.1.88', NULL, 'Outbound connection to 185.xxx.xxx.xxx port 4444', 'Suricata: ET TROJAN Known malicious IP communication'),
('2026-07-25 08:30:00', 'Security', '10.0.3.5', 'dwilson', 'USB device (Kingston 8GB) inserted without authorization', 'Windows Event 2003: USB device plugged in'),
('2026-07-24 16:45:00', 'Auth', '10.0.1.22', 'mjohnson', 'Failed password for mjohnson from 10.0.1.22 port 22 ssh2', 'sshd[4321]: Failed password for mjohnson from 10.0.1.22 port 22 ssh2'),
('2026-07-24 16:45:12', 'Auth', '10.0.1.22', 'mjohnson', 'Failed password for mjohnson from 10.0.1.22 port 22 ssh2', 'sshd[4322]: Failed password for mjohnson from 10.0.1.22 port 22 ssh2'),
('2026-07-24 09:10:00', 'Security', '10.0.2.99', NULL, 'WannaCry ransomware variant detected and blocked', 'Windows Defender: Ransomware:WannaCry blocked');

-- ============================================================
-- 6. ADDITIONAL TABLES (optional)
-- ============================================================
-- Table for storing Indicators of Compromise (IOCs)
CREATE TABLE iocs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    indicator_type TEXT CHECK(indicator_type IN ('IP', 'Domain', 'URL', 'Hash', 'File')),
    value TEXT NOT NULL,
    threat_name TEXT,
    severity TEXT CHECK(severity IN ('Low', 'Medium', 'High', 'Critical')),
    first_seen DATETIME,
    last_seen DATETIME,
    status TEXT CHECK(status IN ('Active', 'Inactive', 'Suspicious'))
);

INSERT INTO iocs (indicator_type, value, threat_name, severity, first_seen, last_seen, status) VALUES
('IP', '185.xxx.xxx.xxx', 'C2 Server (Emotet)', 'High', '2026-07-25 22:10:00', '2026-07-26 14:00:00', 'Active'),
('IP', '10.0.1.45', 'Brute Force Source', 'Medium', '2026-07-26 14:31:55', '2026-07-26 14:32:13', 'Suspicious'),
('Hash', 'eicar_hash', 'EICAR Test File', 'Critical', '2026-07-26 11:02:00', '2026-07-26 11:02:00', 'Inactive');

-- ============================================================
-- 7. VIEWS FOR COMMON QUERIES
-- ============================================================
-- View: Open critical alerts
CREATE VIEW critical_open_alerts AS
SELECT * FROM alerts WHERE severity IN ('High', 'Critical') AND status != 'Resolved';

-- View: Recent failed logins from logs
CREATE VIEW recent_auth_failures AS
SELECT * FROM logs WHERE event_type = 'Auth' AND details LIKE '%Failed%' ORDER BY timestamp DESC LIMIT 50;

-- View: Employee contact info with department
CREATE VIEW employee_directory AS
SELECT e.id, e.first_name, e.last_name, e.email, d.name AS department, e.job_title
FROM employees e
JOIN departments d ON e.department_id = d.id;

-- ============================================================
-- 8. SAMPLE QUERIES (for demonstration)
-- ============================================================
-- Count alerts by severity
-- SELECT severity, COUNT(*) FROM alerts GROUP BY severity;

-- List all employees in IT department
-- SELECT * FROM employee_directory WHERE department = 'IT';

-- Show unresolved alerts assigned to specific analyst (e.g., John Doe)
-- SELECT * FROM alerts WHERE assigned_to = 1 AND status != 'Resolved';

-- Join alerts with employees to show analyst name
-- SELECT a.*, e.first_name || ' ' || e.last_name AS analyst
-- FROM alerts a
-- LEFT JOIN employees e ON a.assigned_to = e.id;

-- ============================================================
-- END OF SCRIPT
-- ============================================================