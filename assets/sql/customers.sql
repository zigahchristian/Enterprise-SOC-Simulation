-- ============================================================
-- ABC TECHNOLOGIES - CUSTOMER DATABASE
-- SQLite schema for customer management and support
-- Part of the Enterprise SOC Simulation Capstone Project
-- ============================================================

-- Enable foreign key constraints (SQLite)
PRAGMA foreign_keys = ON;

-- ============================================================
-- 1. CUSTOMERS
-- ============================================================
CREATE TABLE customers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    company_name TEXT NOT NULL UNIQUE,
    industry TEXT,
    headquarters_location TEXT,
    country TEXT,
    contact_email TEXT,
    contact_phone TEXT,
    customer_since DATE,
    status TEXT CHECK(status IN ('Active', 'Inactive', 'Pending')) DEFAULT 'Active',
    monthly_revenue DECIMAL(10,2)
);

INSERT INTO customers (company_name, industry, headquarters_location, country, contact_email, contact_phone, customer_since, status, monthly_revenue) VALUES
('Ghana National Bank', 'Banking & Finance', 'Accra, Ghana', 'Ghana', 'security@gnb.gh', '+233 30 222 1000', '2023-01-15', 'Active', 15000.00),
('West African Energy', 'Energy & Utilities', 'Tema, Ghana', 'Ghana', 'it@waenergy.com', '+233 30 333 2000', '2023-06-01', 'Active', 12000.00),
('Accra City Hospital', 'Healthcare', 'Accra, Ghana', 'Ghana', 'admin@accracityhospital.gh', '+233 30 444 3000', '2023-09-20', 'Active', 8000.00),
('Kumasi Manufacturing', 'Manufacturing', 'Kumasi, Ghana', 'Ghana', 'info@kumasimfg.gh', '+233 32 555 4000', '2024-01-10', 'Active', 9500.00),
('E-Learning Academy', 'Education', 'Accra, Ghana', 'Ghana', 'support@elearn.gh', '+233 30 666 5000', '2024-03-01', 'Active', 5000.00),
('Lagos FinTech Ltd', 'Financial Technology', 'Lagos, Nigeria', 'Nigeria', 'security@lagosfintech.ng', '+234 1 777 6000', '2023-11-05', 'Active', 18000.00),
('Abidjan Telecom', 'Telecommunications', 'Abidjan, Côte d''Ivoire', 'Côte d''Ivoire', 'noc@abidjantelecom.ci', '+225 20 888 7000', '2024-02-15', 'Active', 13000.00),
('Dakar Logistics', 'Logistics & Supply Chain', 'Dakar, Senegal', 'Senegal', 'it@dakarlogistics.sn', '+221 33 999 8000', '2023-07-10', 'Active', 7000.00),
('Nairobi Insurance', 'Insurance', 'Nairobi, Kenya', 'Kenya', 'security@nairobiinsurance.ke', '+254 20 111 9000', '2023-12-01', 'Active', 11000.00),
('Cairo Digital', 'Media & Entertainment', 'Cairo, Egypt', 'Egypt', 'tech@cairodigital.eg', '+20 2 222 1234', '2024-04-01', 'Pending', 6000.00);

-- ============================================================
-- 2. CUSTOMER CONTACTS
-- ============================================================
CREATE TABLE customer_contacts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    role TEXT CHECK(role IN ('Primary', 'Technical', 'Billing', 'Executive')),
    is_primary BOOLEAN DEFAULT 0,
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

-- Insert contacts (2-3 per customer)
INSERT INTO customer_contacts (customer_id, first_name, last_name, email, phone, role, is_primary) VALUES
(1, 'Kwame', 'Mensah', 'kwame.mensah@gnb.gh', '+233 30 222 1001', 'Primary', 1),
(1, 'Ama', 'Osei', 'ama.osei@gnb.gh', '+233 30 222 1002', 'Technical', 0),
(2, 'Yaw', 'Asante', 'yaw.asante@waenergy.com', '+233 30 333 2001', 'Primary', 1),
(2, 'Adwoa', 'Adjei', 'adwoa.adjei@waenergy.com', '+233 30 333 2002', 'Technical', 0),
(3, 'Dr. Kofi', 'Appiah', 'kofi.appiah@accracityhospital.gh', '+233 30 444 3001', 'Primary', 1),
(3, 'Esi', 'Boateng', 'esi.boateng@accracityhospital.gh', '+233 30 444 3002', 'Technical', 0),
(4, 'Kweku', 'Amponsah', 'kweku.amponsah@kumasimfg.gh', '+233 32 555 4001', 'Primary', 1),
(4, 'Akua', 'Asare', 'akua.asare@kumasimfg.gh', '+233 32 555 4002', 'Technical', 0),
(5, 'John', 'Doe (E-Learning)', 'john.doe@elearn.gh', '+233 30 666 5001', 'Primary', 1),
(5, 'Mary', 'Smith', 'mary.smith@elearn.gh', '+233 30 666 5002', 'Technical', 0),
(6, 'Olu', 'Adeyemi', 'olu.adeyemi@lagosfintech.ng', '+234 1 777 6001', 'Primary', 1),
(6, 'Chidi', 'Okafor', 'chidi.okafor@lagosfintech.ng', '+234 1 777 6002', 'Technical', 0),
(7, 'Jean', 'Kouadio', 'jean.kouadio@abidjantelecom.ci', '+225 20 888 7001', 'Primary', 1),
(7, 'Marie', 'Yao', 'marie.yao@abidjantelecom.ci', '+225 20 888 7002', 'Technical', 0),
(8, 'Ousmane', 'Sy', 'ousmane.sy@dakarlogistics.sn', '+221 33 999 8001', 'Primary', 1),
(8, 'Fatou', 'Ndiaye', 'fatou.ndiaye@dakarlogistics.sn', '+221 33 999 8002', 'Technical', 0),
(9, 'Grace', 'Wanjiru', 'grace.wanjiru@nairobiinsurance.ke', '+254 20 111 9001', 'Primary', 1),
(9, 'Peter', 'Kariuki', 'peter.kariuki@nairobiinsurance.ke', '+254 20 111 9002', 'Technical', 0),
(10, 'Ahmed', 'Hassan', 'ahmed.hassan@cairodigital.eg', '+20 2 222 1235', 'Primary', 1);

-- ============================================================
-- 3. CONTRACTS
-- ============================================================
CREATE TABLE contracts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL,
    contract_type TEXT CHECK(contract_type IN ('Managed SOC', 'Threat Intelligence', 'Security Audit', 'Incident Response', 'Penetration Testing', 'Security Training')),
    start_date DATE NOT NULL,
    end_date DATE,
    monthly_fee DECIMAL(10,2),
    status TEXT CHECK(status IN ('Active', 'Expired', 'Pending Renewal', 'Terminated')),
    sales_rep_employee_id INTEGER,  -- references employees table from employee database
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (sales_rep_employee_id) REFERENCES employees(id)
);

INSERT INTO contracts (customer_id, contract_type, start_date, end_date, monthly_fee, status, sales_rep_employee_id) VALUES
(1, 'Managed SOC', '2023-01-15', '2024-01-14', 15000.00, 'Active', 5),  -- david.wilson
(1, 'Incident Response', '2023-06-01', '2024-05-31', 3000.00, 'Active', 5),
(2, 'Threat Intelligence', '2023-06-01', '2024-05-31', 12000.00, 'Active', 5),
(3, 'Security Audit', '2023-09-20', '2024-09-19', 8000.00, 'Active', 10), -- maria.white
(4, 'Managed SOC', '2024-01-10', '2025-01-09', 9500.00, 'Active', 10),
(5, 'Security Training', '2024-03-01', '2025-02-28', 5000.00, 'Active', 5),
(6, 'Managed SOC', '2023-11-05', '2024-11-04', 18000.00, 'Active', 10),
(6, 'Penetration Testing', '2024-02-01', '2024-07-31', 4000.00, 'Active', 10),
(7, 'Threat Intelligence', '2024-02-15', '2025-02-14', 13000.00, 'Active', 5),
(8, 'Managed SOC', '2023-07-10', '2024-07-09', 7000.00, 'Active', 10),
(9, 'Incident Response', '2023-12-01', '2024-11-30', 11000.00, 'Active', 5),
(9, 'Security Audit', '2024-03-01', '2024-08-31', 3000.00, 'Active', 5),
(10, 'Managed SOC', '2024-04-01', '2025-03-31', 6000.00, 'Pending', 10);

-- ============================================================
-- 4. SUPPORT TICKETS
-- ============================================================
CREATE TABLE support_tickets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL,
    subject TEXT NOT NULL,
    description TEXT,
    severity TEXT CHECK(severity IN ('Low', 'Medium', 'High', 'Critical')),
    status TEXT CHECK(status IN ('Open', 'In Progress', 'Resolved', 'Closed')),
    opened_by_contact_id INTEGER,  -- reference to customer_contacts
    assigned_to_employee_id INTEGER,  -- reference to employees
    opened_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    closed_date DATETIME,
    resolution_notes TEXT,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (opened_by_contact_id) REFERENCES customer_contacts(id),
    FOREIGN KEY (assigned_to_employee_id) REFERENCES employees(id)
);

INSERT INTO support_tickets (customer_id, subject, description, severity, status, opened_by_contact_id, assigned_to_employee_id, opened_date, closed_date, resolution_notes) VALUES
(1, 'Suspicious login attempts', 'Multiple failed logins to core banking system from unknown IPs.', 'High', 'In Progress', 1, 1, '2026-07-26 09:15:00', NULL, 'Investigation ongoing. Blocked IPs and enabled MFA.'),
(2, 'Firewall misconfiguration', 'Customer reports intermittent connectivity to their internal applications.', 'Medium', 'Resolved', 3, 7, '2026-07-25 11:00:00', '2026-07-26 08:30:00', 'Corrected NAT rules and updated ACLs.'),
(3, 'Phishing attempt detected', 'Employees received suspicious emails with malicious links.', 'Critical', 'In Progress', 5, 2, '2026-07-26 13:45:00', NULL, 'Isolated affected workstations, analyzed emails.'),
(4, 'Ransomware alert', 'IDS flagged a ransomware variant on file server.', 'Critical', 'Open', 7, 2, '2026-07-26 10:00:00', NULL, 'Awaiting customer confirmation before containment.'),
(5, 'VPN connection failure', 'Users unable to connect to VPN from remote locations.', 'Low', 'Resolved', 9, 1, '2026-07-24 16:20:00', '2026-07-25 09:00:00', 'Reconfigured VPN gateway and updated client certificates.'),
(6, 'Data exfiltration suspicion', 'Unusual outbound traffic patterns detected by Splunk.', 'High', 'Open', 11, 7, '2026-07-26 08:00:00', NULL, 'Reviewing logs; engaging IR team.'),
(7, 'Compliance report requested', 'Customer needs a detailed security posture report for auditors.', 'Low', 'Resolved', 13, 2, '2026-07-22 14:00:00', '2026-07-25 12:00:00', 'Delivered comprehensive report via secure portal.'),
(8, 'Network outage', 'Branch office network went down; suspected DDoS.', 'High', 'Resolved', 15, 7, '2026-07-25 07:30:00', '2026-07-25 10:00:00', 'Mitigated DDoS via upstream provider; implemented rate limiting.'),
(9, 'New firewall rules', 'Request to open ports for new application.', 'Medium', 'In Progress', 17, 1, '2026-07-26 12:00:00', NULL, 'Change request logged; awaiting approval.');

-- ============================================================
-- 5. VIEWS FOR COMMON QUERIES
-- ============================================================
-- View: Active customers with contact details
CREATE VIEW active_customers_summary AS
SELECT 
    c.id,
    c.company_name,
    c.industry,
    c.country,
    cc.first_name || ' ' || cc.last_name AS primary_contact,
    cc.email,
    cc.phone,
    c.monthly_revenue
FROM customers c
JOIN customer_contacts cc ON c.id = cc.customer_id AND cc.is_primary = 1
WHERE c.status = 'Active';

-- View: Contract details with customer name and sales rep
CREATE VIEW contract_details AS
SELECT 
    ct.id AS contract_id,
    c.company_name,
    ct.contract_type,
    ct.start_date,
    ct.end_date,
    ct.monthly_fee,
    ct.status AS contract_status,
    e.first_name || ' ' || e.last_name AS sales_rep
FROM contracts ct
JOIN customers c ON ct.customer_id = c.id
LEFT JOIN employees e ON ct.sales_rep_employee_id = e.id;

-- View: Open support tickets with customer and assignee
CREATE VIEW open_tickets AS
SELECT 
    t.id AS ticket_id,
    c.company_name,
    t.subject,
    t.severity,
    t.status,
    t.opened_date,
    e.first_name || ' ' || e.last_name AS assigned_to
FROM support_tickets t
JOIN customers c ON t.customer_id = c.id
LEFT JOIN employees e ON t.assigned_to_employee_id = e.id
WHERE t.status NOT IN ('Resolved', 'Closed');

-- ============================================================
-- 6. SAMPLE ANALYTICAL QUERIES
-- ============================================================
-- List all customers with their primary contact
-- SELECT * FROM active_customers_summary;

-- Get total monthly revenue by country
-- SELECT country, SUM(monthly_revenue) FROM customers GROUP BY country;

-- Find contracts expiring in the next 30 days
-- SELECT * FROM contract_details WHERE end_date BETWEEN date('now') AND date('now', '+30 days');

-- Count tickets per severity
-- SELECT severity, COUNT(*) FROM support_tickets GROUP BY severity;

-- Join tickets with alerts (if you have a relation, but here we can just show a combined view)
-- Not directly linked, but could be done via description keyword search.

-- ============================================================
-- END OF SCRIPT
-- ============================================================