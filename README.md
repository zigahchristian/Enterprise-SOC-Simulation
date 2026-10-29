# 🛡️ Enterprise SOC Simulation (Capstone Project)

## 📌 Portfolio-Worthy & Employer-Approved

Demonstrates mastery across:
**Linux · SQL · Python · Networking · SIEM · IDS/IPS · Incident Response · Risk Management · Security Auditing**

---

## ⭐ Overview

**Project Title:** Enterprise Security Monitoring and Incident Response Simulation  
**Role:** Tier 1 SOC Analyst  
**Frameworks:** NIST · MITRE ATT&CK  
**Duration:** 4–6 Weeks  


---

## 📋 Executive Summary

This project simulates the real-world responsibilities of a **Tier 1 Security Operations Center (SOC) Analyst** protecting a medium-sized enterprise.

### Incident Response Lifecycle

- Preparation
- Detection
- Analysis
- Containment
- Eradication
- Recovery
- Lessons Learned

---

## 🏛️ Company Background

**Organization:** ABC Technologies Ltd.  
**Industry:** Information Technology Services  
**Employees:** 250

### Locations
- Head Office: Accra, Ghana
- Branch: Kumasi

### Critical Assets
- Employee Database
- Payroll System
- Company Website
- Email Server
- Financial Records
- Customer Database

---

## ⚠️ Business Problem

The organization has experienced:

- Failed login attempts
- Malware detections
- Suspicious outbound traffic
- Unauthorized USB devices
- Possible data exfiltration

Management has requested a full security investigation.

---

## 🎯 Project Objectives

- Build a Virtual SOC
- Collect logs
- Monitor attacks
- Investigate incidents
- Analyze packets
- Perform threat hunting
- Produce executive reports

---

## 📚 Learning Outcomes

- Linux Administration
- SIEM Operations
- Network Analysis
- Threat Hunting
- Python Automation
- SQL Investigation
- Risk Assessment
- Incident Response
- Professional Documentation

---

## 🧰 Technologies

- Ubuntu Server
- Kali Linux
- Windows 11
- VmWare
- Pfsense Router
- Splunk Enterprise Free
- Suricata
- Wireshark
- Nmap
- Hydra
- Python
- MySQL
- Git & GitHub
- VSCode
- Markdown

---

## 🏗️ Virtual Lab Architecture

```text
                               Internet
                                  |
                                  |
                          pfSense (Router)
                                  |
                                  |
              ---------------------------------------
              |                   |                 |
              |                   |                 |    
              |                 (SOC)               |
          Kali Linux         Ubuntu Server      Windows 10
          (Attacker)         (Splunk Server)     (Victim)
                                  |
                             Suricata IDS
```

---

## 📌 Project Phases

This project is organized into **14 phases**, following a complete security operations lifecycle:

### Phase 1: Project Planning
- Project Charter, Scope, Objectives, Timeline, Risk Register

### Phase 2: Environment Setup
- Install Ubuntu, Windows, Kali, Splunk, Suricata, Wireshark, Git, Python
- Verify network communication between VMs
- Documentation: Installation Guide, Screenshots, Network Diagram

### Phase 3: Asset Inventory
- Create inventory with Owner & Criticality classification

| Asset | Owner | Criticality |
|-------|-------|-------------|
| Payroll Server | Finance | 🔴 High |
| SQL Database | HR | 🔴 High |
| Website | IT | 🟡 Medium |
| Email Server | IT | 🔴 High |

### Phase 4: Risk Assessment
- Evaluate: Asset, Threat, Vulnerability, Likelihood, Impact, Risk Rating

| Asset | Threat | Risk |
|-------|--------|------|
| Payroll | Ransomware | 🔴 High |
| Email | Phishing | 🔴 High |
| Website | SQL Injection | 🟡 Medium |

### Phase 5: Log Collection
- Authentication logs, System logs, Windows Event Logs, Network logs, IDS alerts, Firewall logs

### Phase 6: Attack Simulation (Kali)
- **Hydra**: Brute Force Attacks
- **Nmap**: Port Scanning
- **EICAR**: Malware Detection
- **Ping Sweep**: Network Discovery
- **SSH**: Login Attempts

### Phase 7: SIEM Monitoring (Splunk)
- **Dashboards** for:
  - Authentication failures
  - Successful logins
  - Network traffic
  - Malware alerts
  - Top IPs
  - User activity

### Phase 8: Packet Analysis (Wireshark)
- Analysis of: TCP, UDP, HTTP, HTTPS, DNS, ICMP
- Identify scanning, data transfer, suspicious traffic, credentials

### Phase 9: Threat Hunting
- Repeated login failures
- Known malicious IPs
- Unusual processes
- Suspicious PowerShell
- Large downloads
- Unknown executables

### Phase 10: Python Automation
- Failed Login Analyzer
- Log Parser
- IOC Extractor
- CSV Report Generator
- Email Alert Generator

### Phase 11: SQL Investigation
- Create SQLite database: Alerts, Logs, Users
- Query example:
```sql
SELECT * FROM alerts WHERE severity='High';
```

### Phase 12: Incident Response (NIST Framework)
- Preparation
- Detection
- Analysis
- Containment
- Eradication
- Recovery
- Lessons Learned

### Phase 13: MITRE ATT&CK Mapping
- Attack	Technique
- Password Attack	T1110
- Port Scan	Discovery
- Malware	T1204
- Credential Access	T1003

### Phase 14: Security Recommendations
- Enable MFA
- Strong 
---

## 📦 Technical Deliverables

- Virtual Lab
- Splunk Configuration
- Suricata Rules
- Python Scripts
- SQL Database
- PCAP Files
- Network Diagram
- Screenshots

---

## 📄 Documentation

- Project Proposal
- Requirements Specification
- Risk Assessment
- Asset Inventory
- Threat Model
- Incident Report
- Threat Hunting Report
- Packet Analysis Report
- Deployment Guide
- Executive Summary

---

## 🐙 Repository Structure

```text
Enterprise-SOC-Simulation/
│   .gitignore
│   index.html
│   LICENSE
│   README.md
│   
├───assets
│   ├───payroll
│   │   │   payroll_api.py
│   │   │   payroll_system.py
│   │   │   requirements.txt
│   │   │   
│   │   ├───db
│   │   │       payroll.db
│   │   │       
│   │   ├───logs
│   │   │       payroll.log
│   │   │       payroll_errors.log
│   │   │       
│   │   └───web
│   │           payroll.html
│   │           
│   ├───sql
│   │       abc.db
│   │       customers.sql
│   │       employees.sql
│   │       finaces.sql
│   │       
│   └───web
│       │   .env
│       │   package-lock.json
│       │   package.json
│       │   server.js
│       │   
│       ├───db
│       │       error.log
│       │       server.log
│       │       
│       ├───middleware
│       │       auth.js
│       │       
│       ├───prisma
│       │   │   schema.prisma
│       │   │   
│       │   └───db
│       │           abc.db
│       │           
│       ├───public
│       │       dashboard.html
│       │       index.html
│       │       login.html
│       │       
│       ├───routes
│       │       auth.js
│       │       protected.js
│       │       
│       └───utils
│               logger.js
│               prisma.js
│               prismaSessionStore.js
│               
├───diagrams
├───documentation
├───logs
├───pcap
├───presentation
├───python
├───reports
└───screenshots
    ├───assets
    │       employee_login.jpg
    │       error_login.jpg
    │       hompage.jpg
    │       payroll.jpg
    │       payroll2.jpg
    │       payroll3.jpg
    │       success_login.jpg
    │       
    ├───linux
    ├───splunk
    ├───suricata
    └───wireshark
```

---

## 🧪 Testing Plan

| Test | Expected Result |
|------|-----------------|
| Failed SSH Login | Alert Generated |
| Port Scan | IDS Detects |
| Malware (EICAR) | Alert Generated |
| SQL Query | Returns High Alerts |
| Python Parser | Generates Report |

---

## 🖥️ Final Presentation

- Background
- Objectives
- Architecture
- Methodology
- Attack Simulation
- Splunk Dashboard
- Wireshark Analysis
- Threat Hunting
- Incident Response
- Results
- Recommendations
- Lessons Learned

---

## ✨ Portfolio Highlights

- SOC Monitoring & Alert Triage
- Splunk Dashboard Development
- Suricata IDS Configuration
- Wireshark Packet Inspection
- Threat Hunting
- MITRE ATT&CK Mapping
- Python Log Automation
- SQL Investigations
- Professional Documentation

---

## 🚀 Employer Value

This project closely mirrors the daily responsibilities of a:

- Junior SOC Analyst
- Cybersecurity Analyst
- Blue Team Analyst

It is an excellent portfolio project aligned with the **Google Cybersecurity Professional Certificate**.

---

## 📜 License

MIT License

---

## 👤 Author

**Christian Zigah**  
Cybersecurity & IT Professional  
Accra, Ghana
# Enterprise-SOC-Simulation
