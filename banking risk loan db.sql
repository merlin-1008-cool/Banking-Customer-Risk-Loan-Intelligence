CREATE DATABASE banking_risk_loan_db;
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
    loan_type VARCHAR(30),
    loan_amount DECIMAL(15,2),
    interest_rate DECIMAL(5,2),
    loan_date DATE,
    loan_status VARCHAR(20),
    outstanding_amount DECIMAL(15,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);


CREATE TABLE transactions (
    transaction_id VARCHAR(10) PRIMARY KEY,
    account_id VARCHAR(10),
    transaction_date DATE,
    transaction_type VARCHAR(20),
    amount DECIMAL(15,2),
    balance_after_transaction DECIMAL(15,2),
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);
SELECT COUNT(*) AS customer_count FROM customers;

SELECT COUNT(*) AS account_count FROM accounts;

SELECT COUNT(*) AS loan_count FROM loans;

SELECT COUNT(*) AS transaction_count FROM transactions;

#Which customers currently have loans, and what is their outstanding loan amount?

SELECT
    c.customer_id,
    c.age,
    c.gender,
    c.city,
    c.occupation,
    l.loan_id,
    l.loan_type,
    l.loan_amount,
    l.interest_rate,
    l.loan_status,
    l.outstanding_amount
FROM customers c
INNER JOIN loans l
    ON c.customer_id = l.customer_id
LIMIT 10;

#How much money has the bank lent, and how much is still outstanding?
SELECT
    COUNT(*) AS total_loans,
    SUM(loan_amount) AS total_loan_amount,
    SUM(outstanding_amount) AS total_outstanding_amount,
    AVG(interest_rate) AS average_interest_rate
FROM loans;


#Which loan types are the biggest?
SELECT
    loan_type,
    COUNT(*) AS total_loans,
    SUM(loan_amount) AS total_loan_amount,
    SUM(outstanding_amount) AS total_outstanding_amount,
    AVG(interest_rate) AS average_interest_rate
FROM loans
GROUP BY loan_type
ORDER BY total_loan_amount DESC;

#tells us how many loans are Active, Closed, etc., and how much money is still outstanding in each status?
SELECT
    loan_status,
    COUNT(*) AS total_loans,
    SUM(loan_amount) AS total_loan_amount,
    SUM(outstanding_amount) AS total_outstanding_amount
FROM loans
GROUP BY loan_status
ORDER BY total_outstanding_amount DESC;

#Identify high-value outstanding loans?
SELECT
    l.loan_id,
    l.customer_id,
    c.city,
    c.occupation,
    l.loan_type,
    l.loan_amount,
    l.interest_rate,
    l.loan_status,
    l.outstanding_amount
FROM loans l
JOIN customers c
    ON l.customer_id = c.customer_id
ORDER BY l.outstanding_amount DESC
LIMIT 10;


#Which cities have the highest outstanding loan exposure?
SELECT
    c.city,
    COUNT(l.loan_id) AS total_loans,
    SUM(l.loan_amount) AS total_loan_amount,
    SUM(l.outstanding_amount) AS total_outstanding_amount
FROM customers c
JOIN loans l
    ON c.customer_id = l.customer_id
GROUP BY c.city
ORDER BY total_outstanding_amount DESC;

#Combining customers + loans to identify customers carrying significant outstanding debt.
SELECT
    c.customer_id,
    c.age,
    c.city,
    c.occupation,
    COUNT(l.loan_id) AS total_loans,
    SUM(l.loan_amount) AS total_borrowed,
    SUM(l.outstanding_amount) AS total_outstanding
FROM customers c
JOIN loans l
    ON c.customer_id = l.customer_id
GROUP BY
    c.customer_id,
    c.age,
    c.city,
    c.occupation
HAVING SUM(l.outstanding_amount) > 2000000
ORDER BY total_outstanding DESC;


#customers with multiple loans
SELECT
    c.customer_id,
    c.age,
    c.city,
    c.occupation,
    COUNT(l.loan_id) AS total_loans,
    SUM(l.loan_amount) AS total_borrowed,
    SUM(l.outstanding_amount) AS total_outstanding
FROM customers c
JOIN loans l
    ON c.customer_id = l.customer_id
GROUP BY
    c.customer_id,
    c.age,
    c.city,
    c.occupation
HAVING COUNT(l.loan_id) > 1
ORDER BY total_outstanding DESC
LIMIT 10;

#Which loan types have the highest outstanding amount relative to the amount originally lent?
SELECT
    loan_type,
    SUM(loan_amount) AS total_loan_amount,
    SUM(outstanding_amount) AS total_outstanding_amount,
    ROUND(
        (SUM(outstanding_amount) / SUM(loan_amount)) * 100,
        2
    ) AS outstanding_percentage
FROM loans
GROUP BY loan_type
ORDER BY outstanding_percentage DESC;


#Which customers have the highest total loan exposure compared with their annual income?
SELECT
    c.customer_id,
    c.city,
    c.annual_income,
    COUNT(l.loan_id) AS total_loans,
    SUM(l.loan_amount) AS total_loan_amount,
    SUM(l.outstanding_amount) AS total_outstanding_amount,
    ROUND(
        (SUM(l.outstanding_amount) / c.annual_income) * 100,
        2
    ) AS outstanding_to_income_pct
FROM customers c
JOIN loans l
    ON c.customer_id = l.customer_id
GROUP BY
    c.customer_id,
    c.city,
    c.annual_income
ORDER BY outstanding_to_income_pct DESC
LIMIT 20;

 #Loan Status & Customer Risk-Which customers have active loans with a high outstanding balance?
 SELECT
    c.customer_id,
    c.city,
    c.occupation,
    COUNT(l.loan_id) AS active_loans,
    SUM(l.loan_amount) AS total_active_loan_amount,
    SUM(l.outstanding_amount) AS total_active_outstanding
FROM customers c
JOIN loans l
    ON c.customer_id = l.customer_id
WHERE l.loan_status = 'Active'
GROUP BY
    c.customer_id,
    c.city,
    c.occupation
ORDER BY total_active_outstanding DESC
LIMIT 20;

 #Loan Default Risk-Which loan types have the highest number of defaulted loans?
SELECT
    loan_type,
    COUNT(*) AS total_loans,
    SUM(CASE
        WHEN loan_status = 'Default' THEN 1
        ELSE 0
    END) AS defaulted_loans,
    ROUND(
        SUM(CASE
            WHEN loan_status = 'Default' THEN 1
            ELSE 0
        END) * 100.0 / COUNT(*),
        2
    ) AS default_rate_pct
FROM loans
GROUP BY loan_type
ORDER BY default_rate_pct DESC;

#Which cities have the highest loan default rates?
SELECT
    c.city,
    COUNT(l.loan_id) AS total_loans,
    SUM(CASE
        WHEN l.loan_status = 'Default' THEN 1
        ELSE 0
    END) AS defaulted_loans,
    ROUND(
        SUM(CASE
            WHEN l.loan_status = 'Default' THEN 1
            ELSE 0
        END) * 100.0 / COUNT(l.loan_id),
        2
    ) AS default_rate_pct
FROM customers c
JOIN loans l
    ON c.customer_id = l.customer_id
GROUP BY c.city
ORDER BY default_rate_pct DESC;


#Which customers have the highest number of active loans and the highest outstanding amount?
SELECT
    c.customer_id,
    c.city,
    c.occupation,
    COUNT(l.loan_id) AS active_loan_count,
    SUM(l.outstanding_amount) AS total_outstanding_amount
FROM customers c
JOIN loans l
    ON c.customer_id = l.customer_id
WHERE l.loan_status = 'Active'
GROUP BY
    c.customer_id,
    c.city,
    c.occupation
HAVING COUNT(l.loan_id) > 1
ORDER BY
    active_loan_count DESC,
    total_outstanding_amount DESC
LIMIT 20;

#How much money is currently outstanding from defaulted loans, and which loan types contribute the most?
SELECT
    loan_type,
    COUNT(*) AS defaulted_loans,
    SUM(loan_amount) AS total_defaulted_loan_amount,
    SUM(outstanding_amount) AS total_defaulted_outstanding
FROM loans
WHERE loan_status = 'Default'
GROUP BY loan_type
ORDER BY total_defaulted_outstanding DESC;

#Which individual loans have the highest percentage of their original loan amount still outstanding?
SELECT
    loan_id,
    customer_id,
    loan_type,
    loan_amount,
    outstanding_amount,
    ROUND(
        (outstanding_amount / loan_amount) * 100,
        2
    ) AS outstanding_percentage
FROM loans
WHERE loan_amount > 0
ORDER BY outstanding_percentage DESC
LIMIT 20;

#Which customers have defaulted loans with the highest outstanding amounts?
SELECT
    c.customer_id,
    c.city,
    c.occupation,
    COUNT(l.loan_id) AS defaulted_loans,
    SUM(l.outstanding_amount) AS total_defaulted_outstanding
FROM customers c
JOIN loans l
    ON c.customer_id = l.customer_id
WHERE l.loan_status = 'Default'
GROUP BY
    c.customer_id,
    c.city,
    c.occupation
ORDER BY total_defaulted_outstanding DESC
LIMIT 20;

#Which loan types have the highest average loan amount and highest average outstanding amount?
SELECT
    loan_type,
    COUNT(*) AS total_loans,
    ROUND(AVG(loan_amount), 2) AS average_loan_amount,
    ROUND(AVG(outstanding_amount), 2) AS average_outstanding_amount
FROM loans
GROUP BY loan_type
ORDER BY average_loan_amount DESC;

#Do customers with lower annual income have a higher loan default rate?
SELECT
    CASE
        WHEN c.annual_income < 100000 THEN 'Low Income'
        WHEN c.annual_income < 300000 THEN 'Lower-Middle Income'
        WHEN c.annual_income < 600000 THEN 'Middle Income'
        ELSE 'High Income'
    END AS income_group,
    COUNT(l.loan_id) AS total_loans,
    SUM(CASE
        WHEN l.loan_status = 'Default' THEN 1
        ELSE 0
    END) AS defaulted_loans,
    ROUND(
        SUM(CASE
            WHEN l.loan_status = 'Default' THEN 1
            ELSE 0
        END) * 100.0 / COUNT(l.loan_id),
        2
    ) AS default_rate_pct
FROM customers c
JOIN loans l
    ON c.customer_id = l.customer_id
GROUP BY
    CASE
        WHEN c.annual_income < 100000 THEN 'Low Income'
        WHEN c.annual_income < 300000 THEN 'Lower-Middle Income'
        WHEN c.annual_income < 600000 THEN 'Middle Income'
        ELSE 'High Income'
    END
ORDER BY default_rate_pct DESC;

#Which interest-rate ranges have the highest loan default rates?
SELECT
    CASE
        WHEN interest_rate < 8 THEN 'Below 8%'
        WHEN interest_rate < 10 THEN '8% - 9.99%'
        WHEN interest_rate < 12 THEN '10% - 11.99%'
        ELSE '12% and Above'
    END AS interest_rate_group,
    COUNT(*) AS total_loans,
    SUM(CASE
        WHEN loan_status = 'Default' THEN 1
        ELSE 0
    END) AS defaulted_loans,
    ROUND(
        SUM(CASE
            WHEN loan_status = 'Default' THEN 1
            ELSE 0
        END) * 100.0 / COUNT(*),
        2
    ) AS default_rate_pct
FROM loans
GROUP BY
    CASE
        WHEN interest_rate < 8 THEN 'Below 8%'
        WHEN interest_rate < 10 THEN '8% - 9.99%'
        WHEN interest_rate < 12 THEN '10% - 11.99%'
        ELSE '12% and Above'
    END
ORDER BY default_rate_pct DESC;


#Which customers have multiple accounts and outstanding loans?

SELECT
    c.customer_id,
    c.city,
    c.occupation,
    COUNT(DISTINCT a.account_id) AS total_accounts,
    COUNT(DISTINCT l.loan_id) AS total_loans,
    SUM(l.outstanding_amount) AS total_outstanding_amount
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
JOIN loans l
    ON c.customer_id = l.customer_id
GROUP BY
    c.customer_id,
    c.city,
    c.occupation
HAVING
    COUNT(DISTINCT a.account_id) > 1
    AND SUM(l.outstanding_amount) > 0
ORDER BY total_outstanding_amount DESC;


#Which customers have high outstanding loan amounts compared with their total account balance?
SELECT
    c.customer_id,
    c.city,
    c.occupation,
    SUM(DISTINCT l.outstanding_amount) AS total_outstanding_amount,
    SUM(a.balance) AS total_account_balance,
    ROUND(
        (SUM(DISTINCT l.outstanding_amount) / NULLIF(SUM(a.balance), 0)) * 100,
        2
    ) AS loan_to_balance_pct
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
JOIN loans l
    ON c.customer_id = l.customer_id
GROUP BY
    c.customer_id,
    c.city,
    c.occupation
HAVING SUM(a.balance) > 0
ORDER BY loan_to_balance_pct DESC
LIMIT 20;

#whether customers with defaulted loans also tend to have enough or insufficient account balances to cover their outstanding loan exposure.
SELECT
    l.customer_id,
    SUM(l.outstanding_amount) AS total_outstanding_loan,
    SUM(a.balance) AS total_account_balance,
    SUM(l.outstanding_amount) - SUM(a.balance) AS exposure_gap
FROM loans l
JOIN accounts a
    ON l.customer_id = a.customer_id
WHERE l.loan_status = 'Default'
GROUP BY l.customer_id
ORDER BY exposure_gap DESC;


#which loan types have the highest default rate?
SELECT
    loan_type,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN loan_status = 'Default' THEN 1 ELSE 0 END) AS defaulted_loans,
    ROUND(
        SUM(CASE WHEN loan_status = 'Default' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS default_rate_pct
FROM loans
GROUP BY loan_type
ORDER BY default_rate_pct DESC;


#how much money is currently outstanding across each loan type?
SELECT
    loan_type,
    COUNT(*) AS total_loans,
    ROUND(SUM(outstanding_amount), 2) AS total_outstanding,
    ROUND(
        SUM(CASE
            WHEN loan_status = 'Default' THEN outstanding_amount
            ELSE 0
        END), 2
    ) AS defaulted_outstanding
FROM loans
GROUP BY loan_type
ORDER BY defaulted_outstanding DESC;

#customers who have multiple loans and high total outstanding exposure?
SELECT
    customer_id,
    COUNT(*) AS total_loans,
    ROUND(SUM(loan_amount), 2) AS total_loan_amount,
    ROUND(SUM(outstanding_amount), 2) AS total_outstanding
FROM loans
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY total_outstanding DESC;


#Final Portfolio Risk Summary
SELECT
    COUNT(*) AS total_loans,
    ROUND(SUM(loan_amount), 2) AS total_loan_amount,
    ROUND(SUM(outstanding_amount), 2) AS total_outstanding_amount,
    SUM(CASE WHEN loan_status = 'Default' THEN 1 ELSE 0 END) AS defaulted_loans,
    ROUND(
        SUM(CASE
            WHEN loan_status = 'Default' THEN outstanding_amount
            ELSE 0
        END), 2
    ) AS defaulted_outstanding_amount,
    ROUND(
        SUM(CASE WHEN loan_status = 'Default' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS overall_default_rate_pct
FROM loans;













