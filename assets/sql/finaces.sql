-- ============================================================
-- ABC TECHNOLOGIES - FINANCIAL RECORDS DATABASE
-- SQLite schema for accounting, invoicing, and financial tracking
-- Part of the Enterprise SOC Simulation Capstone Project
-- ============================================================

-- Enable foreign key constraints (SQLite)
PRAGMA foreign_keys = ON;

-- ============================================================
-- 1. CHART OF ACCOUNTS
-- ============================================================
CREATE TABLE chart_of_accounts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    account_code TEXT NOT NULL UNIQUE,
    account_name TEXT NOT NULL,
    account_type TEXT CHECK(account_type IN ('Asset', 'Liability', 'Equity', 'Revenue', 'Expense')),
    parent_account_id INTEGER,
    is_active BOOLEAN DEFAULT 1,
    FOREIGN KEY (parent_account_id) REFERENCES chart_of_accounts(id)
);

INSERT INTO chart_of_accounts (account_code, account_name, account_type, parent_account_id) VALUES
('1000', 'Assets', 'Asset', NULL),
('1100', 'Cash & Cash Equivalents', 'Asset', 1),
('1110', 'Cash on Hand', 'Asset', 2),
('1120', 'Bank Account - Main', 'Asset', 2),
('1130', 'Bank Account - Savings', 'Asset', 2),
('1200', 'Accounts Receivable', 'Asset', 1),
('1300', 'Property & Equipment', 'Asset', 1),
('2000', 'Liabilities', 'Liability', NULL),
('2100', 'Accounts Payable', 'Liability', 8),
('2200', 'Payroll Liabilities', 'Liability', 8),
('3000', 'Equity', 'Equity', NULL),
('3100', 'Retained Earnings', 'Equity', 11),
('4000', 'Revenue', 'Revenue', NULL),
('4100', 'Service Revenue', 'Revenue', 13),
('4200', 'Consulting Revenue', 'Revenue', 13),
('5000', 'Expenses', 'Expense', NULL),
('5100', 'Salaries & Wages', 'Expense', 16),
('5200', 'Rent & Utilities', 'Expense', 16),
('5300', 'IT & Software', 'Expense', 16),
('5400', 'Office Supplies', 'Expense', 16),
('5500', 'Professional Services', 'Expense', 16);

-- ============================================================
-- 2. FINANCIAL TRANSACTIONS
-- ============================================================
CREATE TABLE financial_transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    transaction_date DATE NOT NULL,
    description TEXT,
    reference_number TEXT,
    debit_account_id INTEGER,
    credit_account_id INTEGER,
    amount DECIMAL(12,2) NOT NULL,
    transaction_type TEXT CHECK(transaction_type IN ('Invoice', 'Payment', 'Expense', 'Transfer', 'Payroll', 'Adjustment')),
    category TEXT,
    status TEXT CHECK(status IN ('Pending', 'Posted', 'Reversed', 'Void')) DEFAULT 'Pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    posted_at DATETIME,
    created_by TEXT,
    notes TEXT,
    FOREIGN KEY (debit_account_id) REFERENCES chart_of_accounts(id),
    FOREIGN KEY (credit_account_id) REFERENCES chart_of_accounts(id)
);

-- Sample transactions for July 2026
INSERT INTO financial_transactions (transaction_date, description, reference_number, debit_account_id, credit_account_id, amount, transaction_type, category, status, created_by, notes) VALUES
('2026-07-01', 'Opening balance - Main Bank Account', 'OPEN-001', 3, 11, 250000.00, 'Adjustment', 'Opening Balance', 'Posted', 'ADMIN', 'July 2026 opening balance'),
('2026-07-01', 'Opening balance - Savings Account', 'OPEN-002', 4, 11, 50000.00, 'Adjustment', 'Opening Balance', 'Posted', 'ADMIN', 'July 2026 opening balance'),

-- Revenue / Invoices
('2026-07-05', 'Ghana National Bank - Monthly SOC Services', 'INV-2026-001', 2, 14, 15000.00, 'Invoice', 'Managed SOC', 'Posted', 'ADMIN', 'July 2026 managed SOC services'),
('2026-07-05', 'West African Energy - Threat Intelligence', 'INV-2026-002', 2, 14, 12000.00, 'Invoice', 'Threat Intelligence', 'Posted', 'ADMIN', 'July 2026 threat intelligence feed'),
('2026-07-10', 'Accra City Hospital - Security Audit', 'INV-2026-003', 2, 14, 8000.00, 'Invoice', 'Security Audit', 'Posted', 'ADMIN', 'Annual security audit Q3 2026'),
('2026-07-10', 'Kumasi Manufacturing - Managed SOC', 'INV-2026-004', 2, 14, 9500.00, 'Invoice', 'Managed SOC', 'Posted', 'ADMIN', 'July 2026 managed SOC services'),
('2026-07-15', 'Lagos FinTech Ltd - Managed SOC', 'INV-2026-005', 2, 14, 18000.00, 'Invoice', 'Managed SOC', 'Posted', 'ADMIN', 'July 2026 managed SOC services'),
('2026-07-15', 'Abidjan Telecom - Threat Intelligence', 'INV-2026-006', 2, 14, 13000.00, 'Invoice', 'Threat Intelligence', 'Pending', 'ADMIN', 'July 2026 threat intelligence feed'),
('2026-07-20', 'Dakar Logistics - Managed SOC', 'INV-2026-007', 2, 14, 7000.00, 'Invoice', 'Managed SOC', 'Pending', 'ADMIN', 'July 2026 managed SOC services'),
('2026-07-20', 'Nairobi Insurance - Incident Response', 'INV-2026-008', 2, 14, 11000.00, 'Invoice', 'Incident Response', 'Pending', 'ADMIN', 'Q3 2026 incident response retainer'),

-- Customer Payments Received
('2026-07-08', 'Payment received - Ghana National Bank', 'PAY-2026-001', 3, 2, 15000.00, 'Payment', 'Accounts Receivable', 'Posted', 'ADMIN', 'Payment for INV-2026-001'),
('2026-07-12', 'Payment received - West African Energy', 'PAY-2026-002', 3, 2, 12000.00, 'Payment', 'Accounts Receivable', 'Posted', 'ADMIN', 'Payment for INV-2026-002'),
('2026-07-15', 'Payment received - Accra City Hospital', 'PAY-2026-003', 3, 2, 8000.00, 'Payment', 'Accounts Receivable', 'Posted', 'ADMIN', 'Payment for INV-2026-003'),
('2026-07-18', 'Payment received - Kumasi Manufacturing', 'PAY-2026-004', 3, 2, 9500.00, 'Payment', 'Accounts Receivable', 'Posted', 'ADMIN', 'Payment for INV-2026-004'),
('2026-07-25', 'Payment received - Lagos FinTech Ltd', 'PAY-2026-005', 3, 2, 18000.00, 'Payment', 'Accounts Receivable', 'Posted', 'ADMIN', 'Payment for INV-2026-005'),

-- Expenses
('2026-07-03', 'Office Rent - July 2026', 'EXP-2026-001', 19, 3, 12000.00, 'Expense', 'Rent & Utilities', 'Posted', 'ADMIN', 'Monthly office rent - Accra head office'),
('2026-07-05', 'Electricity & Utilities', 'EXP-2026-002', 19, 3, 3500.00, 'Expense', 'Rent & Utilities', 'Posted', 'ADMIN', 'July 2026 utilities'),
('2026-07-08', 'Splunk Enterprise License Renewal', 'EXP-2026-003', 20, 3, 8500.00, 'Expense', 'IT & Software', 'Posted', 'ADMIN', 'Annual Splunk license (pro-rated)'),
('2026-07-10', 'Suricata IDS Subscription', 'EXP-2026-004', 20, 3, 2500.00, 'Expense', 'IT & Software', 'Posted', 'ADMIN', 'Emerging Threats OSS subscription'),
('2026-07-12', 'Office Supplies - Stationery', 'EXP-2026-005', 21, 3, 1500.00, 'Expense', 'Office Supplies', 'Posted', 'ADMIN', 'Monthly office supplies'),
('2026-07-15', 'External Security Consultant - Pen Test', 'EXP-2026-006', 22, 3, 5000.00, 'Expense', 'Professional Services', 'Posted', 'ADMIN', 'External penetration test for ABC infrastructure'),
('2026-07-20', 'Legal Services - Contract Review', 'EXP-2026-007', 22, 3, 3000.00, 'Expense', 'Professional Services', 'Posted', 'ADMIN', 'Legal review of customer contracts'),
('2026-07-25', 'Cloud Infrastructure (AWS) Hosting', 'EXP-2026-008', 20, 3, 4200.00, 'Expense', 'IT & Software', 'Posted', 'ADMIN', 'AWS hosting for SOC infrastructure'),
('2026-07-28', 'Employee Training - Cybersecurity Certifications', 'EXP-2026-009', 22, 3, 2000.00, 'Expense', 'Professional Services', 'Posted', 'ADMIN', 'Certification exam fees for SOC team'),

-- Payroll Expenses (July 2026)
('2026-07-31', 'Salaries - IT Department', 'PAY-2026-006', 18, 9, 45000.00, 'Payroll', 'Salaries & Wages', 'Posted', 'ADMIN', 'IT department salaries - July 2026'),
('2026-07-31', 'Salaries - HR & Admin', 'PAY-2026-007', 18, 9, 18000.00, 'Payroll', 'Salaries & Wages', 'Posted', 'ADMIN', 'HR & Admin salaries - July 2026'),
('2026-07-31', 'Salaries - Sales & Marketing', 'PAY-2026-008', 18, 9, 25000.00, 'Payroll', 'Salaries & Wages', 'Posted', 'ADMIN', 'Sales & Marketing salaries - July 2026'),
('2026-07-31', 'Salaries - Finance Department', 'PAY-2026-009', 18, 9, 20000.00, 'Payroll', 'Salaries & Wages', 'Posted', 'ADMIN', 'Finance department salaries - July 2026'),
('2026-07-31', 'Salaries - Customer Support', 'PAY-2026-010', 18, 9, 15000.00, 'Payroll', 'Salaries & Wages', 'Posted', 'ADMIN', 'Customer Support salaries - July 2026'),

-- Payroll Tax & Benefit Contributions
('2026-07-31', 'Payroll Taxes - SSNIT Contributions', 'PAY-2026-011', 18, 9, 15000.00, 'Payroll', 'Salaries & Wages', 'Posted', 'ADMIN', 'Employer SSNIT contributions - July 2026'),
('2026-07-31', 'Health Insurance - Employee Benefits', 'PAY-2026-012', 18, 9, 4500.00, 'Payroll', 'Salaries & Wages', 'Posted', 'ADMIN', 'Health insurance premiums - July 2026');

-- ============================================================
-- 3. ACCOUNTS RECEIVABLE (Invoices by Customer)
-- ============================================================
CREATE TABLE accounts_receivable (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL,
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    invoice_number TEXT NOT NULL UNIQUE,
    description TEXT,
    amount DECIMAL(12,2) NOT NULL,
    amount_paid DECIMAL(12,2) DEFAULT 0,
    status TEXT CHECK(status IN ('Draft', 'Sent', 'Partially Paid', 'Paid', 'Overdue', 'Written Off')),
    notes TEXT,
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

INSERT INTO accounts_receivable (customer_id, invoice_date, due_date, invoice_number, description, amount, amount_paid, status) VALUES
(1, '2026-07-01', '2026-07-30', 'INV-2026-001', 'July 2026 Managed SOC Services - Ghana National Bank', 15000.00, 15000.00, 'Paid'),
(2, '2026-07-01', '2026-07-30', 'INV-2026-002', 'July 2026 Threat Intelligence - West African Energy', 12000.00, 12000.00, 'Paid'),
(3, '2026-07-01', '2026-07-30', 'INV-2026-003', 'Q3 2026 Security Audit - Accra City Hospital', 8000.00, 8000.00, 'Paid'),
(4, '2026-07-01', '2026-07-30', 'INV-2026-004', 'July 2026 Managed SOC - Kumasi Manufacturing', 9500.00, 9500.00, 'Paid'),
(5, '2026-07-01', '2026-07-30', 'INV-2026-005', 'E-Learning Academy - Security Training Package', 5000.00, 0.00, 'Sent'),
(6, '2026-07-01', '2026-07-30', 'INV-2026-006', 'July 2026 Managed SOC - Lagos FinTech Ltd', 18000.00, 18000.00, 'Paid'),
(7, '2026-07-01', '2026-07-30', 'INV-2026-007', 'July 2026 Threat Intelligence - Abidjan Telecom', 13000.00, 0.00, 'Sent'),
(8, '2026-07-01', '2026-07-30', 'INV-2026-008', 'July 2026 Managed SOC - Dakar Logistics', 7000.00, 0.00, 'Overdue'),
(9, '2026-07-01', '2026-07-30', 'INV-2026-009', 'Q3 2026 Incident Response Retainer - Nairobi Insurance', 11000.00, 0.00, 'Sent'),
(10, '2026-07-01', '2026-07-30', 'INV-2026-010', 'July 2026 Managed SOC - Cairo Digital', 6000.00, 0.00, 'Sent');

-- ============================================================
-- 4. ACCOUNTS PAYABLE (Bills to Vendors)
-- ============================================================
CREATE TABLE accounts_payable (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    vendor_name TEXT NOT NULL,
    bill_date DATE NOT NULL,
    due_date DATE NOT NULL,
    bill_number TEXT NOT NULL UNIQUE,
    description TEXT,
    amount DECIMAL(12,2) NOT NULL,
    amount_paid DECIMAL(12,2) DEFAULT 0,
    status TEXT CHECK(status IN ('Received', 'Approved', 'Partially Paid', 'Paid', 'Overdue')),
    category TEXT,
    notes TEXT
);

INSERT INTO accounts_payable (vendor_name, bill_date, due_date, bill_number, description, amount, amount_paid, status, category) VALUES
('Accra Landlord Ltd', '2026-07-01', '2026-07-15', 'BILL-2026-001', 'July 2026 Office Rent - Head Office', 12000.00, 12000.00, 'Paid', 'Rent'),
('ECG Ghana', '2026-07-05', '2026-07-25', 'BILL-2026-002', 'July 2026 Electricity Utility', 3500.00, 0.00, 'Approved', 'Utilities'),
('Splunk Inc', '2026-07-08', '2026-07-30', 'BILL-2026-003', 'Annual Splunk Enterprise License', 8500.00, 0.00, 'Received', 'Software'),
('Emerging Threats', '2026-07-10', '2026-07-31', 'BILL-2026-004', 'Suricata OSS Subscription - Q3 2026', 2500.00, 0.00, 'Received', 'Software'),
('Amazon Web Services', '2026-07-20', '2026-07-30', 'BILL-2026-005', 'AWS Cloud Infrastructure - July 2026', 4200.00, 0.00, 'Received', 'Cloud Services'),
('PenTest Partners Ltd', '2026-07-15', '2026-07-30', 'BILL-2026-006', 'External Penetration Test Services', 5000.00, 0.00, 'Approved', 'Professional Services');

-- ============================================================
-- 5. BANK ACCOUNTS
-- ============================================================
CREATE TABLE bank_accounts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    account_name TEXT NOT NULL,
    bank_name TEXT NOT NULL,
    account_number TEXT NOT NULL UNIQUE,
    account_type TEXT CHECK(account_type IN ('Checking', 'Savings', 'Money Market')),
    current_balance DECIMAL(12,2) DEFAULT 0,
    last_reconciled_date DATE,
    is_active BOOLEAN DEFAULT 1
);

INSERT INTO bank_accounts (account_name, bank_name, account_number, account_type, current_balance, last_reconciled_date) VALUES
('ABC Technologies - Main Operating Account', 'GCB Bank Ghana', '1001234567890', 'Checking', 187300.00, '2026-07-31'),
('ABC Technologies - Savings/Reserve', 'GCB Bank Ghana', '1001234567891', 'Savings', 50000.00, '2026-07-31');

-- ============================================================
-- 6. BUDGET TRACKING
-- ============================================================
CREATE TABLE budget (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    fiscal_year INTEGER NOT NULL,
    month INTEGER NOT NULL CHECK(month BETWEEN 1 AND 12),
    account_id INTEGER NOT NULL,
    budgeted_amount DECIMAL(12,2) NOT NULL,
    actual_amount DECIMAL(12,2) DEFAULT 0,
    variance DECIMAL(12,2) DEFAULT 0,
    notes TEXT,
    FOREIGN KEY (account_id) REFERENCES chart_of_accounts(id),
    UNIQUE(fiscal_year, month, account_id)
);

-- Insert July 2026 budget
INSERT INTO budget (fiscal_year, month, account_id, budgeted_amount, actual_amount, notes) VALUES
(2026, 7, 14, 100000.00, 93500.00, 'July 2026 Revenue Budget (Service Revenue)'),
(2026, 7, 15, 15000.00, 12000.00, 'July 2026 Revenue Budget (Consulting Revenue)'),
(2026, 7, 18, 130000.00, 123000.00, 'July 2026 Salary Budget'),
(2026, 7, 19, 20000.00, 15500.00, 'July 2026 Rent & Utilities'),
(2026, 7, 20, 25000.00, 15200.00, 'July 2026 IT & Software'),
(2026, 7, 21, 3000.00, 1500.00, 'July 2026 Office Supplies'),
(2026, 7, 22, 12000.00, 10000.00, 'July 2026 Professional Services');

-- ============================================================
-- 7. FINANCIAL SUMMARY VIEWS
-- ============================================================

-- View: Monthly revenue by customer
CREATE VIEW monthly_revenue_by_customer AS
SELECT 
    c.company_name,
    SUM(ar.amount) as total_invoiced,
    SUM(ar.amount_paid) as total_paid,
    SUM(ar.amount - ar.amount_paid) as outstanding
FROM accounts_receivable ar
JOIN customers c ON ar.customer_id = c.id
WHERE strftime('%Y-%m', ar.invoice_date) = '2026-07'
GROUP BY c.id
ORDER BY total_invoiced DESC;

-- View: Expense summary by category
CREATE VIEW expense_summary AS
SELECT 
    ca.account_name as expense_category,
    SUM(ft.amount) as total_expense
FROM financial_transactions ft
JOIN chart_of_accounts ca ON ft.debit_account_id = ca.id
WHERE ft.transaction_type IN ('Expense', 'Payroll')
    AND ca.account_type = 'Expense'
    AND strftime('%Y-%m', ft.transaction_date) = '2026-07'
    AND ft.status = 'Posted'
GROUP BY ft.debit_account_id
ORDER BY total_expense DESC;

-- View: Profit & Loss (July 2026)
CREATE VIEW profit_loss_july_2026 AS
SELECT 
    'Revenue' as category,
    SUM(amount) as total,
    'Income' as type
FROM financial_transactions
WHERE transaction_type = 'Invoice'
    AND strftime('%Y-%m', transaction_date) = '2026-07'
    AND status = 'Posted'
UNION ALL
SELECT 
    'Expense' as category,
    SUM(amount) as total,
    'Expense' as type
FROM financial_transactions
WHERE transaction_type IN ('Expense', 'Payroll')
    AND strftime('%Y-%m', transaction_date) = '2026-07'
    AND status = 'Posted';

-- View: Cash flow statement (July 2026)
CREATE VIEW cash_flow_july_2026 AS
SELECT 
    'Operating Activities' as category,
    'Revenue' as type,
    SUM(CASE WHEN transaction_type = 'Payment' AND credit_account_id = 2 THEN amount ELSE 0 END) as inflow,
    SUM(CASE WHEN transaction_type IN ('Expense', 'Payroll') AND debit_account_id = 3 THEN amount ELSE 0 END) as outflow
FROM financial_transactions
WHERE strftime('%Y-%m', transaction_date) = '2026-07'
    AND status = 'Posted';

-- ============================================================
-- 8. SAMPLE ANALYTICAL QUERIES
-- ============================================================

-- 1. Total revenue for July 2026
SELECT 'Total Revenue (July 2026)' as metric, SUM(amount) as amount
FROM financial_transactions
WHERE transaction_type = 'Invoice' 
    AND strftime('%Y-%m', transaction_date) = '2026-07'
    AND status = 'Posted';

-- 2. Total expenses for July 2026
SELECT 'Total Expenses (July 2026)' as metric, SUM(amount) as amount
FROM financial_transactions
WHERE transaction_type IN ('Expense', 'Payroll')
    AND strftime('%Y-%m', transaction_date) = '2026-07'
    AND status = 'Posted';

-- 3. Net profit/loss for July 2026
WITH revenue AS (
    SELECT SUM(amount) as total_revenue
    FROM financial_transactions
    WHERE transaction_type = 'Invoice' 
        AND strftime('%Y-%m', transaction_date) = '2026-07'
        AND status = 'Posted'
),
expenses AS (
    SELECT SUM(amount) as total_expenses
    FROM financial_transactions
    WHERE transaction_type IN ('Expense', 'Payroll')
        AND strftime('%Y-%m', transaction_date) = '2026-07'
        AND status = 'Posted'
)
SELECT 
    'Net Profit' as metric,
    (SELECT total_revenue FROM revenue) - (SELECT total_expenses FROM expenses) as amount;

-- 4. Top 5 revenue customers
SELECT 
    c.company_name,
    SUM(ar.amount) as total_revenue,
    SUM(ar.amount_paid) as total_paid
FROM accounts_receivable ar
JOIN customers c ON ar.customer_id = c.id
WHERE ar.status = 'Paid'
GROUP BY c.id
ORDER BY total_revenue DESC
LIMIT 5;

-- 5. Accounts receivable aging report
SELECT 
    c.company_name,
    ar.invoice_number,
    ar.invoice_date,
    ar.due_date,
    ar.amount,
    ar.amount_paid,
    ar.amount - ar.amount_paid as outstanding,
    CASE 
        WHEN julianday('now') - julianday(ar.due_date) <= 0 THEN 'Current'
        WHEN julianday('now') - julianday(ar.due_date) <= 30 THEN '1-30 Days'
        WHEN julianday('now') - julianday(ar.due_date) <= 60 THEN '31-60 Days'
        ELSE 'Over 60 Days'
    END as aging_category
FROM accounts_receivable ar
JOIN customers c ON ar.customer_id = c.id
WHERE ar.status NOT IN ('Paid', 'Written Off')
ORDER BY outstanding DESC;

-- 6. Monthly revenue trend (last 6 months)
SELECT 
    strftime('%Y-%m', invoice_date) as month,
    SUM(amount) as revenue
FROM accounts_receivable
WHERE invoice_date >= date('now', '-6 months')
GROUP BY strftime('%Y-%m', invoice_date)
ORDER BY month;

-- 7. Expense breakdown by category
SELECT 
    ca.account_name as category,
    SUM(ft.amount) as total_spent
FROM financial_transactions ft
JOIN chart_of_accounts ca ON ft.debit_account_id = ca.id
WHERE ft.transaction_type IN ('Expense', 'Payroll')
    AND ft.status = 'Posted'
    AND strftime('%Y', ft.transaction_date) = '2026'
GROUP BY ft.debit_account_id
ORDER BY total_spent DESC;

-- 8. Bank account balance summary
SELECT 
    ba.account_name,
    ba.bank_name,
    ba.account_number,
    ba.current_balance,
    ba.last_reconciled_date
FROM bank_accounts ba
WHERE ba.is_active = 1;

-- 9. Budget vs actual variance
SELECT 
    ca.account_name,
    b.budgeted_amount,
    b.actual_amount,
    b.budgeted_amount - b.actual_amount as variance,
    ROUND(((b.budgeted_amount - b.actual_amount) / b.budgeted_amount) * 100, 2) as variance_percentage
FROM budget b
JOIN chart_of_accounts ca ON b.account_id = ca.id
WHERE b.fiscal_year = 2026 
    AND b.month = 7
ORDER BY variance DESC;

-- 10. Financial health checks
-- a) Current ratio (Current Assets / Current Liabilities)
WITH current_assets AS (
    SELECT SUM(amount) as total
    FROM financial_transactions
    WHERE debit_account_id IN (2, 3, 4)  -- AR, Cash accounts
        AND transaction_type = 'Invoice'
        AND status = 'Posted'
),
current_liabilities AS (
    SELECT SUM(amount) as total
    FROM accounts_payable
    WHERE status NOT IN ('Paid')
)
SELECT 
    'Current Ratio' as metric,
    (SELECT total FROM current_assets) / (SELECT total FROM current_liabilities) as ratio;

-- ============================================================
-- 9. TRIGGERS FOR AUTOMATIC UPDATES
-- ============================================================

-- Trigger: Auto-update bank balance when transaction is posted
CREATE TRIGGER update_bank_balance_after_transaction
AFTER UPDATE ON financial_transactions
WHEN NEW.status = 'Posted' AND OLD.status != 'Posted'
BEGIN
    -- For simplicity, we'll use a manual process instead of a trigger
    -- In production, you'd use a stored procedure or application logic
    SELECT 'Bank balance must be updated manually' as message;
END;

-- ============================================================
-- 10. SECURITY & AUDIT LOGS
-- ============================================================
CREATE TABLE financial_audit_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    action_type TEXT NOT NULL,
    table_name TEXT NOT NULL,
    record_id INTEGER,
    old_value TEXT,
    new_value TEXT,
    changed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    changed_by TEXT,
    ip_address TEXT,
    user_agent TEXT
);

-- Sample audit entries
INSERT INTO financial_audit_log (action_type, table_name, record_id, new_value, changed_by) VALUES
('INSERT', 'financial_transactions', 1, 'Added opening balance', 'ADMIN'),
('UPDATE', 'accounts_receivable', 1, 'Status updated to Paid', 'ADMIN'),
('INSERT', 'accounts_payable', 1, 'New vendor bill created', 'ADMIN');

-- ============================================================
-- END OF SCRIPT
-- ============================================================