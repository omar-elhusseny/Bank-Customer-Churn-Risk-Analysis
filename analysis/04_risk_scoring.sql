
/*
    4a. Balance quartiles
    Use NTILE(4) OVER(ORDER BY balance DESC) to split all customers into 4 tiers by balance.
    Label them: 'Top 25%', 'Upper Mid', 'Lower Mid', 'Bottom 25%'.
    Show how churn rate varies by tier. 
    This tells us if high-balance customers churn more.
*/
WITH tiered_customers AS (
    SELECT
        Balance,
        Exited,
        NTILE(4) OVER (ORDER BY Balance DESC) AS quartile
    FROM customer_churn
)
SELECT
    CASE
        WHEN quartile = 1 THEN 'Top 25%'
        WHEN quartile = 2 THEN 'Upper Mid'
        WHEN quartile = 3 THEN 'Lower Mid'
        WHEN quartile = 4 THEN 'Bottom 25%'
    END AS balance_tier,
    COUNT(*) AS total_customers,
    ROUND(SUM(balance), 2) AS total_balance_per_tier,
    -- Translates true to 1.0 and false to 0.0 to safely calculate the average rate
    ROUND(AVG(CASE WHEN exited THEN 1.0 ELSE 0.0 END) * 100, 2) AS churn_rate_percentage
FROM tiered_customers
GROUP BY quartile
ORDER BY quartile;



/*
    4b. Customer rank within their country
    Use RANK() OVER(PARTITION BY geography ORDER BY balance DESC) to rank every customer within their country.
    Then show the top 10 churned customers by balance in Germany specifically.
    These are the names the retention team calls first.
*/
WITH rank_customer AS (
    SELECT
        surname,
        balance,
        geography,
        exited,
        -- We rank by balance within each country
        RANK() OVER(PARTITION BY geography ORDER BY balance DESC) AS customer_rank
    FROM customer_churn
)
SELECT
    Surname,
    Balance,
    Geography,
    customer_rank
FROM rank_customer
WHERE Geography = 'Germany' AND Exited = true  -- Only include customers who actually churned
ORDER BY customer_rank ASC
LIMIT 10;



/*
    4c. Each churned customer vs their country average
    Use AVG(balance) OVER(PARTITION BY geography) to calculate the country average inline.
    For every churned customer show their:
    - balance
    - their country's average balance
    - a balance_vs_country_avg column showing the dollar difference.
    Order by that difference descending — richest relative to their market at the top.
*/
WITH country_avgs AS (
    SELECT 
        geography,
        ROUND(AVG(balance), 2) AS country_avg
    FROM customer_churn
    GROUP BY geography
)
SELECT
    c.surname,
    c.geography,
    c.balance,
    ca.country_avg,
    ROUND(c.balance - ca.country_avg, 2) AS balance_vs_country_avg
FROM customer_churn c
JOIN country_avgs ca ON c.geography = ca.geography
WHERE c.exited = TRUE
ORDER BY balance_vs_country_avg DESC;



/*
    4d. The composite risk score — the showcase query
    Build a risk score for every active, non-churned customer.
    Use a CTE to calculate country averages first,
    join it to the main table, then score each customer like this:
    
    Factor                          Points              Logic 
    Age 40–59                       +30                 High churn age group
    Germany                         +25                 High churn market
    1 product                       +20                 High churn product tier
    3+ products                     +20                 Very high churn product tier
    Inactive member                 +15                 Disengaged
    Balance above country avg       +10                 High value at risk

    Return the top 20 highest-risk customers with: 
    customer_id, surname, geography, age, balance, num_of_products, risk_score.
    Order by risk_score descending.
*/

WITH country_average AS (
    SELECT
        Geography,
        ROUND(AVG(Balance)) AS avg_balance
    FROM customer_churn
    GROUP BY Geography
)
SELECT
    c.customer_id,
    c.surname,
    c.geography,
    c.age,
    ROUND(c.balance, 2) AS balance,
    c.num_of_products,
    (
        CASE WHEN c.age BETWEEN 40 AND 59      THEN 30 ELSE 0 END +
        CASE WHEN c.geography = 'Germany'      THEN 25 ELSE 0 END +
        CASE WHEN c.num_of_products = 1        THEN 20 ELSE 0 END +
        CASE WHEN c.num_of_products >= 3       THEN 20 ELSE 0 END +
        CASE WHEN c.is_active_member = false   THEN 15 ELSE 0 END +
        CASE WHEN c.balance > ca.avg_balance   THEN 10 ELSE 0 END
    ) AS risk_score
FROM customer_churn c
JOIN country_average ca ON c.geography = ca.geography
WHERE c.exited = FALSE
ORDER BY risk_score DESC
LIMIT 20;
