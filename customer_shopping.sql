-- Base dataset used for all analysis
WITH base_data AS (
    SELECT
        customer_id,
        gender,
        category,
        purchase_amount_usd,
        discount_applied,
        frequency_of_purchases,
        shipping_type,
        review_rating,
        season
    FROM customer
)
SELECT * FROM base_data;


-- Overall revenue and average order value
SELECT
    ROUND(SUM(purchase_amount_usd), 2) AS total_revenue,
    ROUND(AVG(purchase_amount_usd), 2) AS avg_order_value,
    COUNT(*) AS total_orders
FROM customer;


-- Revenue Contribution by Gender 
WITH gender_revenue AS (
    SELECT
        gender,
        SUM(purchase_amount_usd) AS revenue
    FROM customer
    GROUP BY gender
)
SELECT
    gender,
    revenue,
    ROUND(100.0 * revenue / SUM(revenue) OVER (), 2) AS revenue_share_pct
FROM gender_revenue
ORDER BY revenue DESC;


-- CUSTOMER VALUE SEGMENTATION

WITH customer_value AS (
    SELECT
        customer_id,
        SUM(purchase_amount_usd) AS total_spend
    FROM customer
    GROUP BY customer_id
)
SELECT
    customer_id,
    total_spend,
    NTILE(4) OVER (ORDER BY total_spend DESC) AS value_segment
FROM customer_value;



-- PARETO ANALYSIS (TOP 20% CUSTOMERS)
WITH customer_value AS (
    SELECT
        customer_id,
        SUM(purchase_amount_usd) AS total_spend
    FROM customer
    GROUP BY customer_id
),
ranked_customers AS (
    SELECT
        customer_id,
        total_spend,
        PERCENT_RANK() OVER (ORDER BY total_spend DESC) AS spend_rank
    FROM customer_value
)
SELECT
    ROUND(SUM(total_spend), 2) AS top_20pct_revenue
FROM ranked_customers
WHERE spend_rank <= 0.2;


-- Discount Effectiveness
SELECT
    discount_applied,
    COUNT(*) AS total_orders,
    ROUND(AVG(purchase_amount_usd), 2) AS avg_order_value,
    ROUND(SUM(purchase_amount_usd), 2) AS total_revenue
FROM customer
GROUP BY discount_applied;


-- Perchase frequence behavior
SELECT
    frequency_of_purchases,
    COUNT(*) AS total_orders,
    ROUND(AVG(purchase_amount_usd), 2) AS avg_order_value,
    ROUND(SUM(purchase_amount_usd), 2) AS total_revenue
FROM customer
GROUP BY frequency_of_purchases
ORDER BY total_revenue DESC;


-- Product category performance
SELECT
    category,
    COUNT(*) AS total_orders,
    ROUND(SUM(purchase_amount_usd), 2) AS revenue,
    ROUND(AVG(review_rating)::numeric, 2) AS avg_rating
FROM customer
GROUP BY category
ORDER BY revenue DESC;


-- Shipping type and customer experience
SELECT
    shipping_type,
    COUNT(*) AS total_orders,
    ROUND(AVG(purchase_amount_usd), 2) AS avg_order_value,
    ROUND(AVG(review_rating)::numeric, 2) AS avg_rating
FROM customer
GROUP BY shipping_type;


-- Seasonal revenue trends
SELECT
    season,
    ROUND(SUM(purchase_amount_usd), 2) AS total_revenue,
    COUNT(*) AS total_orders
FROM customer
GROUP BY season
ORDER BY total_revenue DESC;









