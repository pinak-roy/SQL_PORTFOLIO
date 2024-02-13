--- creating final table view for the ease of query
CREATE VIEW final_table AS
SELECT
    fe.*,
    dc.campaign_name,
    dc.start_date,
    dc.end_date,
    dp.product_name,
    dp.category,
    ds.city,
    CAST(fe.base_price AS bigint) AS base_price_new
    CAST(fe.quantity_sold_before_promo AS bigint) AS quantity_sold_before_promo_new
    CAST(fe.quantity_sold_after_promo) AS quantity_sold_after_promo_new
FROM
    fact_events fe
JOIN dim_campaigns dc ON fe.campaign_id = dc.campaign_id
JOIN dim_products dp ON fe.product_code = dp.product_code
JOIN dim_stores ds ON fe.store_id = ds.store_id;




/*    List of products with a base price greater than 500 and featured in 'BOGOF' promotions:*/
SELECT *
FROM final_table
WHERE base_price_new > 500
  AND promo_type = 'BOGOF';
/*Overview of the number of stores in each city, sorted in descending order of store counts:*/
SELECT city, COUNT(DISTINCT store_id) AS store_count
FROM final_table
GROUP BY city
ORDER BY store_count DESC;
/*Report displaying each campaign along with total revenue before and after the campaign (values in millions):*/
SELECT
    campaign_name,
    SUM(base_price_new * quantity_sold_before_promo_new) / 1000000 AS total_revenue_before_promotion,
    SUM(base_price_new * quantity_sold_after_promo_new) / 1000000 AS total_revenue_after_promotion
FROM final_table
GROUP BY campaign_name;
/*Report calculating Incremental Sold Quantity (ISU%) for each category during the Diwali campaign, with rankings:*/
WITH DiwaliCampaign AS (
    SELECT *
    FROM final_table
    WHERE campaign_name = 'Diwali'
)
SELECT
    category,
    ((SUM(quantity_sold_after_promo_new) - SUM(quantity_sold_before_promo_new)) / SUM(quantity_sold_before_promo_new)) * 100 AS isu_percentage,
    RANK() OVER (ORDER BY ((SUM(quantity_sold_after_promo_new) - SUM(quantity_sold_before_promo_new)) / SUM(quantity_sold_before_promo_new)) DESC) AS rank_order
FROM DiwaliCampaign
GROUP BY category;
/*Report featuring the Top 5 products, ranked by Incremental Revenue Percentage (IR%), across all campaigns:*/
WITH TopProducts AS (
    SELECT
        product_name,
        category,
        ((SUM(base_price_new * quantity_sold_after_promo_new) - SUM(base_price_new * quantity_sold_before_promo_new)) / SUM(base_price_new * quantity_sold_before_promo_new)) * 100 AS ir_percentage,
        RANK() OVER (ORDER BY ((SUM(base_price_new * quantity_sold_after_promo_new) - SUM(base_price_new * quantity_sold_before_promo_new)) / SUM(base_price_new * quantity_sold_before_promo_new)) DESC) AS rank_order
    FROM final_table
    GROUP BY product_name, category
)
SELECT *
FROM TopProducts
WHERE rank_order <= 5;

