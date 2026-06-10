-- ============================================================
-- Layer 5: Executive Dashboard Views
-- Bank Customer Churn Analysis
-- ============================================================
-- Two permanent views that wrap the project's core findings
-- into reusable, queryable objects for reporting and BI tools.
-- ============================================================


-- ------------------------------------------------------------
-- VIEW 1: vw_churn_executive_summary
-- Single-row executive overview for leadership reporting.
-- Answers: what is the total financial exposure from churn?
-- Usage: SELECT * FROM vw_churn_executive_summary;
-- ------------------------------------------------------------

CREATE VIEW vw_churn_executive_summary AS
WITH totals AS (
    SELECT
        COUNT(*)                                                                AS total_customers,
        COUNT(CASE WHEN exited THEN 1 END)                                      AS churned_customers,
        ROUND(COUNT(CASE WHEN exited THEN 1 END) * 100.0 / COUNT(*), 2)         AS churn_rate_pct,
        ROUND(SUM(balance), 2)                                                  AS total_bank_balance,
        ROUND(SUM(CASE WHEN exited THEN balance END), 2)                        AS total_balance_lost,
        ROUND(SUM(CASE WHEN exited THEN balance END) * 100.0 / SUM(balance), 2) AS balance_lost_pct,
        ROUND(AVG(CASE WHEN exited THEN balance END), 2)                        AS avg_churned_balance
    FROM customer_churn
),
worst_market AS (
    SELECT
        geography,
        ROUND(COUNT(CASE WHEN exited THEN 1 END) * 100.0 / COUNT(*), 2) AS geo_churn_rate
    FROM customer_churn
    GROUP BY geography
    ORDER BY geo_churn_rate DESC
    LIMIT 1
)
SELECT
    t.total_customers,
    t.churned_customers,
    t.churn_rate_pct,
    t.total_bank_balance,
    t.total_balance_lost,
    t.balance_lost_pct,
    t.avg_churned_balance,
    w.geography AS highest_churn_market,
    w.geo_churn_rate AS highest_churn_market_rate_pct
FROM totals t
CROSS JOIN worst_market w;


SELECT * FROM vw_churn_executive_summary;


-- ------------------------------------------------------------
-- VIEW 2: vw_high_risk_customers
-- Composite risk score for every non-churned customer.
-- Scores 0–100 based on five evidence-backed risk factors.
-- Usage: SELECT * FROM vw_high_risk_customers WHERE risk_score >= 70 ORDER BY risk_score DESC;
--        SELECT * FROM vw_high_risk_customers ORDER BY risk_score DESC LIMIT 500;
-- ------------------------------------------------------------

CREATE VIEW vw_high_risk_customers AS
WITH country_avg AS (
    SELECT
        geography,
        ROUND(AVG(balance)) AS avg_balance
    FROM customer_churn
    GROUP BY geography
)
SELECT
    c.customer_id,
    c.surname,
    c.geography,
    c.age,
    ROUND(c.balance, 2)     AS balance,
    c.num_of_products,
    c.is_active_member,
    c.credit_score,
    c.satisfaction_score,
    (
        CASE WHEN c.age BETWEEN 40 AND 59      THEN 30 ELSE 0 END +  -- High-churn age band
        CASE WHEN c.geography = 'Germany'      THEN 25 ELSE 0 END +  -- High-churn market
        CASE WHEN c.num_of_products = 1        THEN 20 ELSE 0 END +  -- Single-product risk
        CASE WHEN c.num_of_products >= 3       THEN 20 ELSE 0 END +  -- Over-product risk
        CASE WHEN c.is_active_member = false   THEN 15 ELSE 0 END +  -- Disengaged
        CASE WHEN c.balance > ca.avg_balance   THEN 10 ELSE 0 END    -- High value at risk
    ) AS risk_score
FROM customer_churn c
JOIN country_avg ca ON c.geography = ca.geography
WHERE c.exited = FALSE;