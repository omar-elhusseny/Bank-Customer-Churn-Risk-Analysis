
CREATE TABLE customer_churn (
    row_num INT,
    customer_id INT PRIMARY KEY,
    surname VARCHAR(100),
    credit_score INT,
    geography VARCHAR(50),
    gender VARCHAR(15),
    age SMALLINT,
    tenure SMALLINT,
    balance NUMERIC(15, 2),
    num_of_products SMALLINT,
    has_cr_card BOOLEAN,
    is_active_member BOOLEAN,
    estimated_salary NUMERIC(15, 2),
    exited BOOLEAN,
    complain BOOLEAN,
    satisfaction_score SMALLINT,
    card_type VARCHAR(20),
    points_earned SMALLINT
);


-- Load data from CSV file to database
-- Copy the code below and paste it inside PSQL Tool at pg-admin
-- \copy customer_churn FROM '/Users/omarwalid/Desktop/bank-churn-analysis/data/Customer-Churn-Records.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');


-- Test the data
SELECT * FROM customer_churn;