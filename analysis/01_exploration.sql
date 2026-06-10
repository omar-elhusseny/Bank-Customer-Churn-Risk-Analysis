
-- 1. Total Row Count
SELECT
    COUNT(*) AS row_num
FROM customer_churn;


-- 2. Check for NULL Values in All Columns
SELECT 
    COUNT(*) - COUNT(row_num) AS row_num_nulls,
    COUNT(*) - COUNT(customer_id) AS customer_id_nulls,
    COUNT(*) - COUNT(surname) AS surname_nulls,
    COUNT(*) - COUNT(credit_score) AS credit_score_nulls,
    COUNT(*) - COUNT(geography) AS geography_nulls,
    COUNT(*) - COUNT(gender) AS gender_nulls,
    COUNT(*) - COUNT(age) AS age_nulls,
    COUNT(*) - COUNT(tenure) AS tenure_nulls,
    COUNT(*) - COUNT(balance) AS balance_nulls,
    COUNT(*) - COUNT(num_of_products) AS num_of_products_nulls,
    COUNT(*) - COUNT(has_cr_card) AS has_cr_card_nulls,
    COUNT(*) - COUNT(is_active_member) AS is_active_member_nulls,
    COUNT(*) - COUNT(estimated_salary) AS estimated_salary_nulls,
    COUNT(*) - COUNT(exited) AS exited_nulls,
    COUNT(*) - COUNT(complain) AS complain_nulls,
    COUNT(*) - COUNT(satisfaction_score) AS satisfaction_score_nulls,
    COUNT(*) - COUNT(card_type) AS card_type_nulls,
    COUNT(*) - COUNT(points_earned) AS points_earned_nulls
FROM customer_churn;



-- 3. Summary Statistics for Key Numeric Columns
SELECT 
    MIN(age) AS min_age, 
    MAX(age) AS max_age, 
    ROUND(AVG(age), 2) AS avg_age,
    
    MIN(balance) AS min_balance, 
    MAX(balance) AS max_balance, 
    ROUND(AVG(balance), 2) AS avg_balance,
    
    MIN(credit_score) AS min_credit_score, 
    MAX(credit_score) AS max_credit_score, 
    ROUND(AVG(credit_score), 2) AS avg_credit_score,

    MIN(num_of_products) AS min_num_of_products, 
    MAX(num_of_products) AS max_num_of_products, 
    
    MIN(estimated_salary) AS min_salary, 
    MAX(estimated_salary) AS max_salary, 
    ROUND(AVG(estimated_salary), 2) AS avg_salary
FROM customer_churn;


-- 4. How many customers churned vs didn't (just a count and %)
SELECT
    COUNT(*) AS number_clients,
    CASE
        WHEN exited = TRUE THEN 'churned'
        ELSE 'stayed'
    END AS status,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM customer_churn
GROUP BY status;


