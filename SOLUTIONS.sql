-- 1. Tariff-Based Customer Queries

-- 1.1 List the customers who are subscribed to the 'Kobiye Destek' tariff.
-- Retrieves the list of customers subscribed to the 'Kobiye Destek' tariff by joining customer and tariff data.
SELECT c.CUSTOMER_ID, c.NAME AS CUSTOMER_NAME, t.NAME AS TARIFF_NAME
FROM CUSTOMERS c
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE t.NAME = 'Kobiye Destek';

-- 1.2 Find the newest customer who subscribed to this tariff.
-- Identifies the most recent subscriber to the 'Kobiye Destek' tariff by ordering the joined data by signup date and fetching the top row.
SELECT c.CUSTOMER_ID, c.NAME, c.SIGNUP_DATE
FROM CUSTOMERS c
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE t.NAME = 'Kobiye Destek'
ORDER BY c.SIGNUP_DATE DESC
FETCH FIRST 1 ROWS ONLY;


-- 2. Tariff Distribution

-- 2.1 Find the distribution of tariffs among the customers.
-- Calculates the total number of customers assigned to each tariff by grouping the joined records by tariff name.
SELECT t.NAME AS TARIFF_NAME, COUNT(c.CUSTOMER_ID) AS TOTAL_CUSTOMERS
FROM TARIFFS t
LEFT JOIN CUSTOMERS c ON t.TARIFF_ID = c.TARIFF_ID
GROUP BY t.NAME
ORDER BY TOTAL_CUSTOMERS DESC;


-- 3. Customer Signup Analysis

-- 3.1 Identify the earliest customers to sign up.
-- Retrieves the foundational customers of the system by filtering records against a subquery that finds the absolute minimum signup date.
SELECT CUSTOMER_ID, NAME, SIGNUP_DATE, CITY
FROM CUSTOMERS
WHERE SIGNUP_DATE = (SELECT MIN(SIGNUP_DATE) FROM CUSTOMERS);

-- 3.2 Find the distribution of these earliest customers across different cities.
-- Determines the geographic distribution of the earliest adopters by grouping the customers with the minimum signup date by their respective cities.
SELECT CITY, COUNT(*) AS CUSTOMER_COUNT
FROM CUSTOMERS
WHERE SIGNUP_DATE = (SELECT MIN(SIGNUP_DATE) FROM CUSTOMERS)
GROUP BY CITY;


-- 4. Missing Monthly Records

-- 4.1 Identify the IDs of these missing customers.
-- Detects customers missing from the monthly usage statistics by performing a left join and filtering for null usage IDs.
SELECT c.CUSTOMER_ID, c.NAME
FROM CUSTOMERS c
LEFT JOIN MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID
WHERE m.ID IS NULL;

-- 4.2 Find the distribution of these missing customers across different cities.
-- Analyzes if the missing monthly usage records are concentrated in specific areas by grouping the affected customers by city.
SELECT c.CITY, COUNT(*) AS MISSING_RECORD_COUNT
FROM CUSTOMERS c
LEFT JOIN MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID
WHERE m.ID IS NULL
GROUP BY c.CITY;


-- 5. Usage Analysis

-- 5.1 Find the customers who have used at least 75% of their data limit.
-- Flags heavy data consumers by joining tariff limits with monthly statistics and filtering for those exceeding 75% of their allocated data allowance.
SELECT c.CUSTOMER_ID, c.NAME, m.DATA_USAGE, t.DATA_LIMIT
FROM CUSTOMERS c
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
JOIN MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID
WHERE m.DATA_USAGE >= (t.DATA_LIMIT * 0.75);

-- 5.2 Identify the customers who have completely exhausted all of their package limits.
-- Identifies users who have completely depleted their packages by strictly checking if data, minute, and SMS usages meet or exceed their respective tariff limits.
SELECT c.CUSTOMER_ID, c.NAME
FROM CUSTOMERS c
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
JOIN MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID
WHERE m.DATA_USAGE >= t.DATA_LIMIT 
  AND m.MINUTE_USAGE >= t.MINUTE_LIMIT 
  AND m.SMS_USAGE >= t.SMS_LIMIT;


-- 6. Payment Analysis

-- 6.1 Find the customers who have unpaid fees.
-- Tracks down customers with outstanding debts by filtering the monthly statistics for payment statuses other than 'PAID'.
SELECT c.CUSTOMER_ID, c.NAME, m.PAYMENT_STATUS
FROM CUSTOMERS c
JOIN MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID
WHERE m.PAYMENT_STATUS <> 'PAID';

-- 6.2 Find the distribution of all payment statuses across the different tariffs.
-- Provides a comprehensive view of payment habits per package by grouping the joined data by both tariff names and payment statuses.
SELECT t.NAME AS TARIFF_NAME, m.PAYMENT_STATUS, COUNT(*) AS STATUS_COUNT
FROM TARIFFS t
JOIN CUSTOMERS c ON t.TARIFF_ID = c.TARIFF_ID
JOIN MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID
GROUP BY t.NAME, m.PAYMENT_STATUS
ORDER BY t.NAME, m.PAYMENT_STATUS;