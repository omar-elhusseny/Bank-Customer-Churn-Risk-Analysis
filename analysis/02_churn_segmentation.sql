SELECT * FROM customer_churn;


/*
    Churn rate by geography: Count of churned/total and churn % per country.
    Order by churn rate descending.
*/
SELECT
    geography,
    COUNT(*) AS total_customers,
    COUNT(CASE WHEN exited = TRUE THEN 1 END) AS churned_customers,
    ROUND(COUNT(CASE WHEN exited = TRUE THEN 1 END) * 100.0 / COUNT(*), 2) AS churn_rate_percentage
FROM customer_churn
GROUP BY 1;


/*
    Churn rate by age group
    Bucket customers into age bands using CASE WHEN: 18–29, 30–39, 40–49, 50–59, 60+.
    Show churn rate per band. Order by age band.
*/
SELECT
    CASE
        WHEN age BETWEEN 18 AND 29 THEN '18-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        WHEN age BETWEEN 50 AND 59 THEN '50-59'
        WHEN age >= 60 THEN '60+'
    END AS age_band,
    COUNT(*) AS total_customers,
    COUNT(CASE WHEN exited = TRUE THEN 1 END) AS churned_customers,
    ROUND(COUNT(CASE WHEN exited = TRUE THEN 1 END) * 100.0 / COUNT(*), 2) AS churn_rate_percentage
FROM customer_churn
GROUP BY 1
ORDER BY age_band;


/*
    Churn rate by number of products
    Customers can hold 1, 2, 3, or 4 products. 
    Show churn rate for each. This one often surprises people — look at the results carefully.
*/
SELECT
    num_of_products,
    COUNT(*) AS total_customers,
    COUNT(CASE WHEN exited = TRUE THEN 1 END) AS churned_customers,
    ROUND(COUNT(CASE WHEN exited = TRUE THEN 1 END) * 100.0 / COUNT(*), 2) AS churn_rate_percentage
FROM customer_churn
GROUP BY num_of_products
ORDER BY num_of_products;


/*
    Churn rate by activity status AND geography
    A cross-tab: is_active_member × geography.
    I want to see churn rate for every combination.
    This tells us if inactive customers are a universal problem or concentrated in one market.
*/
SELECT
    CASE 
        WHEN is_active_member = TRUE THEN 'Active' ELSE 'Inactive'
    END AS is_active_member,
    geography,
    COUNT(*) AS total_customers,
    COUNT(CASE WHEN exited = TRUE THEN 1 END) AS churned_customers,
    ROUND(COUNT(CASE WHEN exited = TRUE THEN 1 END) * 100.0 / COUNT(*), 2) AS churn_rate_percentage
FROM customer_churn
GROUP BY geography, is_active_member
ORDER BY geography;