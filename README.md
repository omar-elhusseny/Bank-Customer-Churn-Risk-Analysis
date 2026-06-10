# Bank Customer Churn & Risk Analysis
### End-to-End SQL Analysis in PostgreSQL

A retail bank is losing **1 in 5 customers**. This project uses pure SQL to identify who is churning, why, what it costs, and who is most at risk of leaving next — built as a real-world data analyst portfolio project.

---

## The Business Problem

The Head of Retail Banking flagged rising churn heading into the quarter. The CFO wants to know the financial exposure. The retention team needs a prioritised call list. This analysis answers all three questions using a single dataset and PostgreSQL — no Python, no BI tool, no shortcuts.

---

## The Headline Number

> The bank has lost **$185.7 million in customer balances to churn** — **24.3% of total assets under management**.
> The average churned customer held **$91,109**.

---

## Dataset

| Property | Detail |
|----------|--------|
| Source | [Bank Customer Churn — Kaggle](https://www.kaggle.com/datasets/radheshyamkollipara/bank-customer-churn) |
| Rows | 10,000 customers |
| NULL values | 0 — clean dataset |
| Markets | France, Germany, Spain |
| Key fields | Geography, Age, Balance, Products Held, Activity Status, Exited |

---

## Repository Structure

```
bank-churn-analysis/
├── README.md
├── data/
│   └── schema.sql                 # CREATE TABLE with correct types and constraints
├── analysis/
│   ├── 01_exploration.sql         # Row counts, NULL audit, summary statistics
│   ├── 02_churn_segmentation.sql  # Churn by geography, age band, product count, activity
│   ├── 03_financial_impact.sql    # Balance lost, avg balance, cost by segment
│   ├── 04_risk_scoring.sql        # NTILE quartiles, RANK, window functions, composite scoring
│   └── 05_dashboard_views.sql     # Executive summary VIEW + high-risk customer VIEW
└── insights/
    └── findings.md                # Business narrative and recommendations
```

---

## Key Findings

### Germany is a structural problem
Germany churns at **32.4%** — double France (16.2%) and Spain (16.7%). Even *active* German customers churn at 23.7%, worse than *inactive* customers in any other market. Germany accounts for **$97.9M of the $185.7M total balance lost** despite being 25% of the customer base.

### Age is the strongest predictor
Churn climbs steadily: 10.9% in the 30s → 30.8% in the 40s → **56.0% in the 50s**. More than 1 in 2 customers aged 50–59 has left the bank.

### Product count is non-linear — and counterintuitive
| Products | Churn Rate |
|----------|-----------|
| 1 | 27.7% |
| 2 | **7.6%** ← loyalty sweet spot |
| 3 | 82.7% |
| 4 | **100.0%** — every single customer left |

Cross-selling past two products is driving churn, not loyalty.

### The bank is losing its wealthier customers
Churned customers hold higher average balances than retained ones in every market. The upper-middle balance tier (not the wealthiest) has the highest churn rate at 26.3%.

---

## Showcase Query — Composite Risk Scoring

The centrepiece query scores every non-churned customer on five risk factors derived from the segmentation analysis. Points are assigned based on evidence from the data — not assumptions.

```sql
WITH country_avg AS (
    SELECT geography, ROUND(AVG(balance)) AS avg_balance
    FROM customer_churn
    GROUP BY geography
)
SELECT
    c.customer_id,
    c.surname,
    c.geography,
    c.age,
    ROUND(c.balance, 2)    AS balance,
    c.num_of_products,
    (
        CASE WHEN c.age BETWEEN 40 AND 59    THEN 30 ELSE 0 END +  -- High-churn age band
        CASE WHEN c.geography = 'Germany'    THEN 25 ELSE 0 END +  -- High-churn market
        CASE WHEN c.num_of_products = 1      THEN 20 ELSE 0 END +  -- Single-product risk
        CASE WHEN c.num_of_products >= 3     THEN 20 ELSE 0 END +  -- Over-product risk
        CASE WHEN c.is_active_member = false THEN 15 ELSE 0 END +  -- Disengaged
        CASE WHEN c.balance > ca.avg_balance THEN 10 ELSE 0 END    -- High value at risk
    ) AS risk_score
FROM customer_churn c
JOIN country_avg ca ON c.geography = ca.geography
WHERE c.exited = FALSE
ORDER BY risk_score DESC
LIMIT 20;
```

Or use the pre-built view:
```sql
-- Top 500 highest-risk customers
SELECT * FROM vw_high_risk_customers
ORDER BY risk_score DESC
LIMIT 500;

-- Only maximum-risk customers
SELECT * FROM vw_high_risk_customers
WHERE risk_score = 100
ORDER BY balance DESC;
```

---

## Executive Summary View

One query. Everything the CFO needs.

```sql
SELECT * FROM vw_churn_executive_summary;
```

| Metric | Value |
|--------|-------|
| Total customers | 10,000 |
| Churned customers | 2,038 |
| Churn rate | 20.38% |
| Total bank balance | $764,858,893 |
| Balance lost to churn | $185,681,112 |
| Balance lost % | 24.28% |
| Avg churned customer balance | $91,109 |
| Highest churn market | Germany at 32.44% |

---

## SQL Skills Demonstrated

| Concept | Where Used |
|---------|-----------|
| `GROUP BY`, `HAVING`, `CASE WHEN` | All layers |
| Conditional aggregation | Layers 2, 3 |
| Window functions (`NTILE`, `RANK`, `AVG OVER`, `SUM OVER`) | Layer 4 |
| CTEs (`WITH`) | Layers 3, 4, 5 |
| `JOIN` | Layers 4, 5 |
| `CREATE VIEW` | Layer 5 |
| Subqueries | Layers 3, 4 |
| Data type design (`SMALLINT`, `NUMERIC`, `BOOLEAN`) | Layer 1 |

---

## How to Replicate

**Requirements:** PostgreSQL 13+

```bash
# 1. Create the table
psql -d your_database -f data/schema.sql

# 2. Load the data (update the path)
psql -d your_database -c "\copy customer_churn FROM '/path/to/Customer-Churn-Records.csv' WITH (FORMAT csv, HEADER true)"

# 3. Run analysis in order
psql -d your_database -f analysis/01_exploration.sql
psql -d your_database -f analysis/02_churn_segmentation.sql
psql -d your_database -f analysis/03_financial_impact.sql
psql -d your_database -f analysis/04_risk_scoring.sql
psql -d your_database -f analysis/05_dashboard_views.sql
```

---

## Author

Built as a portfolio project by [Omar Walid](https://www.linkedin.com/in/omar-walid-904236228/) practicing PostgreSQL through real-world business problems. See `insights/findings.md` for the full business narrative and recommendations.
