CREATE DATABASE banking_risk_loan_sql_project;
USE banking_risk_loan_sql_project;
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    age INT,
    gender VARCHAR(10),
    income DECIMAL(12,2),
    employment_type VARCHAR(30),
    credit_score INT,
    existing_loans INT,
    loan_amount DECIMAL(12,2),
    loan_term_months INT,
    interest_rate DECIMAL(5,2),
    loan_status VARCHAR(20)
);

CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    customer_id INT,
    transaction_date DATE,
    transaction_type VARCHAR(30),
    amount DECIMAL(12,2),
    transaction_status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE loans (
    loan_id INT PRIMARY KEY,
    customer_id INT,
    loan_type VARCHAR(30),
    loan_amount DECIMAL(12,2),
    interest_rate DECIMAL(5,2),
    loan_term_months INT,
    application_date DATE,
    loan_status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE loan_payments (
    payment_id INT PRIMARY KEY,
    loan_id INT,
    payment_date DATE,
    payment_amount DECIMAL(12,2),
    payment_status VARCHAR(20),
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
);

CREATE TABLE customer_risk (
    risk_id INT PRIMARY KEY,
    customer_id INT,
    risk_score DECIMAL(5,2),
    risk_category VARCHAR(20),
    risk_reason VARCHAR(255),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);


DROP TABLE IF EXISTS customers;


DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS loans;
DROP TABLE IF EXISTS loan_payments;
DROP TABLE IF EXISTS loans;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS customer_risk;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    age INT,
    gender VARCHAR(10),
    city VARCHAR(50),
    occupation VARCHAR(50),
    annual_income DECIMAL(15,2),
    customer_since DATE
);

CREATE TABLE accounts (
    account_id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(10),
    account_type VARCHAR(20),
    balance DECIMAL(15,2),
    account_opening_date DATE,
    status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE loans (
    loan_id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(10),
    account_id VARCHAR(10),
    loan_type VARCHAR(30),
    loan_amount DECIMAL(15,2),
    interest_rate DECIMAL(5,2),
    loan_start_date DATE,
    loan_status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

SELECT COUNT(*) FROM loans;
SET GLOBAL local_infile = 1;
LOAD DATA LOCAL INFILE '/Users/bensonmartin/Desktop/AI/Banking-Customer-Risk-Loan-Intelligence/data/Loans.csv'
INTO TABLE loans
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(loan_id, customer_id, account_id, loan_type, loan_amount, interest_rate, loan_start_date, loan_status);

