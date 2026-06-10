# Findings: Bank Customer Churn Analysis

## Executive Summary

A retail bank with 10,000 customers is losing 20.38% of its base to churn — approximately 2,038 customers. These departures have cost the bank an estimated **$185.7 million in customer balances**, representing 24.3% of total assets under management. The average churned customer held $91,109, meaning the bank is disproportionately losing mid-to-high value customers rather than low-balance ones.

This analysis identifies the specific segments, geographies, and behavioural patterns driving this exposure. It concludes with a composite risk model that scores every remaining customer and surfaces a prioritised list for the retention team.

The dataset contains 10,000 records with zero NULL values across all 18 columns. All analysis was performed in PostgreSQL.

---

## The Data

The dataset covers retail banking customers across three European markets: France (5,014 customers), Germany (2,509 customers), and Spain (2,477 customers). Each record includes demographic information — age, gender, geography — alongside account features such as balance, credit score, number of products held, and estimated salary. Behavioural indicators include activity status, tenure, satisfaction score, and credit card ownership. The target variable is a binary churn flag indicating whether the customer has left the bank.

Key baseline statistics: average customer age is 38.9 years (range: 18–92), average balance is $76,486 (range: $0–$250,898), and average credit score is 651 (range: 350–850). A notable data point is that minimum balance is $0.00 — a meaningful segment of customers hold no balance at all, which influences the financial impact calculations.

---

## Key Findings

### 1. Germany is a structural market problem, not a targeting problem

France and Spain sit at comparable churn rates of 16.2% and 16.7% respectively. Germany's rate is **32.4%** — double its peers from a market of similar size. The critical insight is that this cannot be solved by standard re-engagement campaigns. Even *active* German customers churn at 23.7%, which is higher than *inactive* customers in either France or Spain. Germany's problem is systemic and requires a market-level investigation: product fit, pricing, competitive dynamics, or service delivery in that geography are all candidate explanations that fall outside the scope of this dataset.

Germany also concentrates the majority of financial damage. Of the $185.7 million in total balance lost to churn, **$97.9 million — 52.7% — comes from Germany alone**, despite Germany representing only 25% of the customer base. Inactive German customers represent the single highest-risk segment in the entire analysis at 41.1% churn.

### 2. The 50–59 age band is the highest-risk demographic

Churn climbs sharply and consistently with age. Customers in their 30s churn at 10.9%. That figure triples to 30.8% in the 40s, then reaches **56.0% among customers aged 50–59**. More than one in two customers in this decade is leaving. The rate moderates to 28.0% for customers aged 60 and over, suggesting that customers who remain through the pre-retirement period tend to stabilise. The 40–59 window is where retention investment will generate the highest return per dollar spent.

### 3. Product count has a non-linear and counterintuitive relationship with churn

| Products Held | Churn Rate |
|---------------|-----------|
| 1 product     | 27.7%     |
| 2 products    | **7.6%**  |
| 3 products    | 82.7%     |
| 4 products    | **100.0%**|

Two-product customers are the bank's most loyal segment. One-product customers are moderately at risk. Customers holding three or four products are leaving at near-certain rates — including every single four-product customer in the dataset (60 out of 60). Cross-selling beyond two products is not deepening loyalty; it is overwhelming customers and accelerating departure. The bank should treat two products as the relationship optimum and introduce a mandatory retention checkpoint before any third product is added.

It is worth noting that despite the extreme churn rates at 3–4 products, these customers are not the largest source of financial loss. Single-product churners account for **$129.7 million — 69.8% of total balance lost** — simply because of volume: 1,409 single-product customers churned versus 280 across the three and four product tiers combined. Both problems are real, but they require different interventions.

### 4. The bank is losing its wealthier customers

In every market, churned customers carry a higher average balance than customers who stayed.

| Market  | Churned Avg Balance | Retained Avg Balance | Gap       |
|---------|--------------------|--------------------|-----------|
| France  | $71,220            | $60,332            | +$10,888  |
| Spain   | $72,513            | $59,678            | +$12,835  |
| Germany | $120,361           | $119,427           | +$934     |

France and Spain are losing wealthier customers at a meaningful premium. Germany presents a distinct challenge: the gap between churned and retained average balance is less than $1,000. The entire German customer base carries high balances, which means the bank has no wealth-based signal to identify at-risk German customers. Every high-value German customer is a potential churner.

### 5. The balance–churn relationship is not what you'd expect

Splitting customers into four balance quartiles reveals that upper-middle balance customers (25th–50th percentile by balance) churn at the *highest* rate (26.3%), ahead of the wealthiest tier (23.7%). The bottom 25% — composed entirely of zero-balance customers — churn at the lowest rate (14.4%). This suggests the bank's most exposed customers are not at the extremes but in the upper-middle wealth band.

---

## High-Risk Customer Profile

The analysis converges on a consistent risk profile. The customer most likely to churn next is **based in Germany, aged 40–59, holds only one product, is not actively engaged with the bank, and carries a balance above the German market average of $119,730**. A composite risk model built from these five factors (see `04_risk_scoring.sql`) identifies customers scoring 100/100 who simultaneously trigger every risk signal. The bank can query this model at any time via the `vw_high_risk_customers` view.

---

## Recommendations

**Immediate (0–30 days):** Prioritise outbound contact for inactive German customers aged 40–59 with single-product relationships and above-average balances. This segment combines the highest churn probability with the highest financial exposure per customer.

**Short-term (1–3 months):** Introduce a relationship review gate for any customer being cross-sold beyond a second product. The 100% churn rate among four-product customers indicates these arrangements are not working. A brief retention touchpoint before product three is added could prevent a predictable loss.

**Strategic (3–12 months):** Commission a qualitative study of churned German customers. The 32% churn rate — persistent even among active customers — signals a structural issue that quantitative analysis alone cannot resolve. Understanding *why* German customers leave requires direct customer feedback.