CREATE DATABASE DeliveryPerformanceDB;
USE DeliveryPerformanceDB;
GO

SELECT COLUMN_NAME,DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Orders'
ORDER BY ORDINAL_POSITION;

SELECT TOP 10 *
FROM Orders;

SELECT COUNT(*) AS TotalOrders
FROM Orders;



SELECT 'Orders' AS TableName, COUNT(*) AS TotalRows
FROM Orders

UNION ALL

SELECT 'OrderItems', COUNT(*)
FROM OrderItems


UNION ALL

SELECT 'Products', COUNT(*)
FROM Products

UNION ALL

SELECT 'Customers', COUNT(*)
FROM Customers

UNION ALL

SELECT 'Sellers', COUNT(*)
FROM Sellers

UNION ALL

SELECT 'Geolocation', COUNT(*)
FROM Geolocation

UNION ALL

SELECT 'OrderPayments', COUNT(*)
FROM OrderPayments

UNION ALL

SELECT 'OrderReviews', COUNT(*)
FROM OrderReviews

UNION ALL

SELECT 'CategoryTranslation', COUNT(*)
FROM CategoryTranslation;

--Check missing values
SELECT
    COUNT(*) AS TotalOrders,

    SUM(CASE
        WHEN order_id IS NULL THEN 1
        ELSE 0
    END) AS MissingOrderID,

    SUM(CASE
        WHEN customer_id IS NULL THEN 1
        ELSE 0
    END) AS MissingCustomerID,

    SUM(CASE
        WHEN order_purchase_timestamp IS NULL THEN 1
        ELSE 0
    END) AS MissingPurchaseDate,

    SUM(CASE
        WHEN order_estimated_delivery_date IS NULL THEN 1
        ELSE 0
    END) AS MissingEstimatedDate,

    SUM(CASE
        WHEN order_delivered_customer_date IS NULL THEN 1
        ELSE 0
    END) AS MissingActualDeliveryDate

FROM Orders;

--Check duplicate orders
SELECT
    order_id,
    COUNT(*) AS DuplicateCount
FROM Orders
GROUP BY order_id
HAVING COUNT(*) > 1;

--Check order statuses
SELECT
    order_status,
    COUNT(*) AS TotalOrders
FROM Orders
GROUP BY order_status
ORDER BY TotalOrders DESC;

--Calculate Delivery Performance

--1.Calculate Total Delivered Orders
SELECT COUNT(*) AS TotalDeliveredOrders
FROM Orders
WHERE order_status = 'delivered';
--2.Calculate On-Time Deliveries
SELECT COUNT(*) AS OnTimeDeliveries
FROM Orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
  AND order_delivered_customer_date
      <= order_estimated_delivery_date;
--3.Calculate Late Deliveries
SELECT COUNT(*) AS LateDeliveries
FROM Orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
  AND order_delivered_customer_date
      > order_estimated_delivery_date;
--4.Calculate the Late Delivery Percentage
SELECT
    COUNT(*) AS TotalDeliveredOrders,

    SUM(
        CASE
            WHEN order_delivered_customer_date
                 > order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS LateDeliveries,

    CAST(
        100.0 * SUM(
            CASE
                WHEN order_delivered_customer_date
                     > order_estimated_delivery_date
                THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)
    ) AS LateDeliveryPercentage

FROM Orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;
--5.Calculate Average Delivery Time
SELECT
    CAST(
        AVG(
            CAST(
                DATEDIFF(
                    DAY,
                    order_purchase_timestamp,
                    order_delivered_customer_date
                ) AS DECIMAL(10,2)
            )
        ) AS DECIMAL(10,2)
    ) AS AverageDeliveryDays
FROM Orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;