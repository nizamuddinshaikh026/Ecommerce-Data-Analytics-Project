# 1. Average Order Value
SELECT
    round(AVG(total_order_value),2) AS average_order_value
FROM
    (SELECT
        order_id,
        sum(payment_value) AS total_order_value
    FROM
        olist_order_payments_dataset
    GROUP BY
        order_id) AS order_values;
        
# 2. Orders By Customer States
SELECT
    t1.customer_state,
    COUNT(t2.order_id) AS orders_count
FROM
    olist_customers_dataset AS t1
JOIN
    olist_orders_dataset AS t2 ON t1.customer_id = t2.customer_id
GROUP BY
    t1.customer_state
ORDER BY
    orders_count DESC;

# 3. Top 5 Most Selling Product Categories
SELECT
    t3.product_category_name_english,
    COUNT(t1.order_item_id) AS total_items_sold
FROM
    olist_order_items_dataset AS t1
JOIN
    olist_products_dataset AS t2 ON t1.product_id = t2.product_id
JOIN
    product_category_name_translation AS t3 ON t2.product_category_name = t3.product_category_name
GROUP BY
    t3.product_category_name_english
ORDER BY
    total_items_sold DESC
LIMIT 5;

# 4. Order Status Distribution
SELECT
    order_status,
    COUNT(order_id) AS order_count
FROM
    olist_orders_dataset
GROUP BY
    order_status
ORDER BY
    order_count DESC;
    
# 5. Top 5 Sellers Order_Id by thier Total Revenue
SELECT 
    t1.seller_id,
    round(SUM(t1.price)) AS total_revenue
FROM olist_order_items_dataset AS t1
JOIN olist_products_dataset AS t2 
    ON t1.product_id = t2.product_id
GROUP BY t1.seller_id
ORDER BY total_revenue DESC
LIMIT 5;

# 6. calculates the percentage of total payment value for both weekdays and weekends.
SELECT
    'Weekday' AS day_type,
    CONCAT(ROUND((SUM(CASE WHEN DAYOFWEEK(t2.order_purchase_timestamp) IN (2, 3, 4, 5, 6) THEN t1.payment_value ELSE 0 END) / SUM(t1.payment_value)) * 100, 2), '%') AS percentage
FROM
    olist_order_payments_dataset AS t1
JOIN
    olist_orders_dataset AS t2 ON t1.order_id = t2.order_id

UNION ALL

SELECT
    'Weekend' AS day_type,
    CONCAT(ROUND((SUM(CASE WHEN DAYOFWEEK(t2.order_purchase_timestamp) IN (1, 7) THEN t1.payment_value ELSE 0 END) / SUM(t1.payment_value)) * 100, 2), '%') AS percentage
FROM
    olist_order_payments_dataset AS t1
JOIN
    olist_orders_dataset AS t2 ON t1.order_id = t2.order_id;


														-- Stored Procdure --

# 7. Total Items Sold By order_Id (Dynamic)
CALL GetTopSellingProducts(100);

# 8. Timely Update Order Status
set sql_safe_updates=0;
CALL UpdateOrderStatus('47770eb9100c2d0c44946d9cf07ec65d', 'Delayed');

SELECT order_id,order_status
FROM olist_orders_dataset;

  

select * from olist_orders_dataset;

													-- Triggers --
                                                    
# 9. Validate for payment value as Positive ( Not accept negative value)                                                    

DELIMITER //

CREATE TRIGGER before_payment_insert_validate
BEFORE INSERT ON olist_order_payments_dataset
FOR EACH ROW
BEGIN
    IF NEW.payment_value <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Payment value must be a positive number.';
    END IF;
END //

DELIMITER ;


INSERT INTO olist_order_payments_dataset (order_id, payment_sequential, payment_type, payment_installments, payment_value)
VALUES ('ervfget23fd244vff12345', 1, 'credit_card', 1, 100.50);

INSERT INTO olist_order_payments_dataset (order_id, payment_sequential, payment_type, payment_installments, payment_value)
VALUES ('df4tyerw4edsdfdgd354321', 1, 'credit_card', 1, -10.00);


