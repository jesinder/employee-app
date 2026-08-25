-- ─────────────────────────────────────────────────────────────
-- Employee Management System - Database Initialization
-- Team: Jesinder (DevOps) & Menaka (Java)
-- ─────────────────────────────────────────────────────────────

CREATE DATABASE IF NOT EXISTS empdb;
USE empdb;

-- Create employees table
CREATE TABLE IF NOT EXISTS employees (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name  VARCHAR(100) NOT NULL,
    email      VARCHAR(150) NOT NULL UNIQUE,
    department VARCHAR(100),
    role       VARCHAR(100),
    salary     DECIMAL(12,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_department (department),
    INDEX idx_email      (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Seed Data ────────────────────────────────────────────────

-- Core Team Members
INSERT INTO employees (first_name, last_name, email, department, role, salary) VALUES
('Jesinder', 'Singh',  'jesinder@company.com', 'DevOps', 'DevOps Engineer',  900000.00),
('Menaka',   'Devi',   'menaka@company.com',   'Java',   'Java Developer',    850000.00);

-- Additional sample employees
INSERT INTO employees (first_name, last_name, email, department, role, salary) VALUES
('Arjun',   'Kumar',   'arjun@company.com',   'DevOps',     'Cloud Architect',       1100000.00),
('Priya',   'Sharma',  'priya@company.com',   'Java',       'Senior Java Developer', 980000.00),
('Ravi',    'Verma',   'ravi@company.com',    'QA',         'QA Engineer',           700000.00),
('Ananya',  'Nair',    'ananya@company.com',  'Management', 'Project Manager',       1200000.00);

-- Confirm seed
SELECT CONCAT('✅ Database initialized. Total employees: ', COUNT(*)) AS status FROM employees;
