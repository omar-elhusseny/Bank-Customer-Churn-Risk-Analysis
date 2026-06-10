/*
    3a. Average balance: churned vs retained, Simple but important.
    Are we losing wealthy customers or not?
    Break it down by geography as well — churned vs retained avg balance per country.
*/
SELECT
    geography,
    CASE
        WHEN exited = TRUE THEN 'Churned'
        ELSE 'Stayed'
    END AS customer_status,
    COUNT(*) AS total_customers,
    ROUND(SUM(balance), 2) AS total_balance,
    ROUND(AVG(balance), 2) AS avg_balance
FROM customer_churn
GROUP BY geography, exited
ORDER BY geography, customer_status;



/*
    3b. Total balance lost to churn Sum of balance for all churned customers, grouped by geography.
    This is the CFO's number.
*/
SELECT
    geography,
    COUNT(*) AS churned_customers,
    ROUND(SUM(balance), 2) AS total_balance_lost
FROM customer_churn
WHERE exited = TRUE
GROUP BY geography
ORDER BY total_balance_lost DESC;



/*
    3c. Churn financial impact by product count We know 3–4 product customers churn the most.
    But are they high or low balance?
    Show avg balance + total balance lost for churned customers per num_of_products.
*/
WITH churn_impact AS (
    SELECT
        num_of_products,
        COUNT(*) AS churned_customers,
        AVG(balance) AS avg_balance,
        SUM(balance) AS total_balance_lost
    FROM customer_churn
    WHERE exited = TRUE
    GROUP BY num_of_products
)
SELECT
    num_of_products,
    churned_customers,
    ROUND(avg_balance, 2) AS avg_balance,
    ROUND(total_balance_lost, 2) AS total_balance_lost,
    ROUND(100.0 * total_balance_lost / SUM(total_balance_lost) OVER (), 2) AS pct_of_total_balance_lost
FROM churn_impact
ORDER BY total_balance_lost DESC;




/*
    3d. The full cost breakdown — one CTE query.
    I want a single query using WITH that calculates:
    - Total customers ✅
    - Total churned customers ✅
    - Total balance in the bank ✅
    - Total balance lost to churn ✅
    - Balance lost as % of total balance ✅
    - Average balance of a churned customer ✅
*/
WITH over_view AS (
    SELECT
        COUNT(*) AS total_customers,
        COUNT(CASE WHEN exited = TRUE THEN 1 END) AS total_churned_customers,
        SUM(balance) AS total_balance,
        SUM(CASE WHEN exited = TRUE THEN balance END) AS total_balance_lost,
        AVG(CASE WHEN exited = TRUE THEN balance END) AS avg_churned_balance
    FROM customer_churn
)

SELECT
    total_customers,
    total_churned_customers,
    ROUND(total_balance, 2) AS total_balance,
    ROUND(total_balance_lost, 2) AS total_balance_lost,
    ROUND(100.0 * total_balance_lost / total_balance, 2) AS balance_lost_pct,
    ROUND(avg_churned_balance, 2) AS avg_churned_balance
FROM over_view;




























3a.
"geography","customer_status","total_customers_per_country","avg_balance","total_balance_per_country"
"France","Churned","811","71219.71","311332479.49"
"France","Stayed","4203","60331.50","311332479.49"
"Germany","Churned","814","120361.08","300402861.38"
"Germany","Stayed","1695","119427.11","300402861.38"
"Spain","Churned","413","72513.35","153123552.01"
"Spain","Stayed","2064","59678.07","153123552.01"





3b.
"geography","churned_customers","total_balance_lost"
"Germany","814","97973915.53"
"France","811","57759182.01"
"Spain","413","29948014.56"



3c.
"num_of_products","churned_customers","avg_balance","total_balance_lost","pct_of_total_balance_lost"
1,"1409","92028.82","129668607.08","69.83"
2,"349","90260.28","31500837.76","16.97"
3,"220","85853.09","18887679.16","10.17"
4,"60","93733.14","5623988.10","3.03"



3d.
"total_customers","total_churned_customers","total_balance","total_balance_lost","balance_lost_pct","avg_churned_balance"
"10000","2038","764858892.88","185681112.10","24.28","91109.48"
