SELECT gender, COUNT(*) AS Count_gender
FROM customers
GROUP BY gender;

-- Age bucketing


-- countery wise customer count
SELECT 
    continent,country,state,city, 
    COUNT(CustomerKey) AS customer_count
FROM 
    CUSTOMERS
GROUP BY 
    continent,country,state,city
ORDER BY 
    customer_count DESC
    

;
select age_bucket,COUNT(*) AS count
FROM (
    SELECT 
        c.CustomerKey,
        CASE
            WHEN YEAR(s.OrderDate) - YEAR(c.Birthday) <= 18 THEN '<=18'
            WHEN YEAR(s.OrderDate) - YEAR(c.Birthday) BETWEEN 18 AND 25 THEN '18-25'
            WHEN YEAR(s.OrderDate) - YEAR(c.Birthday) BETWEEN 25 AND 35 THEN '25-35'
            WHEN YEAR(s.OrderDate) - YEAR(c.Birthday) BETWEEN 35 AND 45 THEN '35-45'
            WHEN YEAR(s.OrderDate) - YEAR(c.Birthday) BETWEEN 45 AND 55 THEN '45-55'
            WHEN YEAR(s.OrderDate) - YEAR(c.Birthday) BETWEEN 55 AND 65 THEN '55-65'
            ELSE '>65'
        END AS age_bucket
    FROM 
        customers c
    JOIN 
        sales s ON c.CustomerKey = s.CustomerKey
) AS age_groups
GROUP BY 
    age_bucket
LIMIT 1000;


SALES ANALYSIS
#OVERALL SALES PERFORMANCE
SELECT 
    YEAR(OrderDate) AS Year,
    MONTH(OrderDate) AS Month,
    SUM(s.Quantity * p.UnitPriceUSD) AS Total_Sales
FROM 
    sales s
JOIN 
    products p ON s.ProductKey = p.ProductKey
GROUP BY 
    YEAR(OrderDate), MONTH(OrderDate)
ORDER BY 
    Year, Month;


#Sales by Product
SELECT 
    p.ProductName,
    SUM(s.Quantity) AS Total_Quantity_Sold,
    SUM(s.Quantity * p.UnitPriceUSD) AS Total_Revenue
FROM 
    sales s
JOIN 
    products p ON s.ProductKey = p.ProductKey
GROUP BY 
    p.ProductName
ORDER BY 
    Total_Revenue DESC
LIMIT 10;


#Sales by Store
SELECT 
    st.StoreKey,
    st.Country,
    st.State,
    SUM(s.Quantity * p.UnitPriceUSD) AS Store_Sales
FROM 
    sales s
JOIN 
    stores st ON s.StoreKey = st.StoreKey
JOIN 
    products p ON s.ProductKey = p.ProductKey
GROUP BY 
    st.StoreKey, st.Country, st.State
ORDER BY 
    Store_Sales DESC;



#Sales by Currency
SELECT 
    s.CurrencyCode,
    SUM(s.Quantity * p.UnitPriceUSD) AS Sales_in_Local_Currency
FROM 
    sales s
JOIN 
    products p ON s.ProductKey = p.ProductKey
GROUP BY 
    s.CurrencyCode
ORDER BY 
    Sales_in_Local_Currency DESC;


#5. Monthly Sales Trend

SELECT 
    DATE_FORMAT(OrderDate, '%Y-%m') AS YearMonth,
    SUM(s.Quantity * p.UnitPriceUSD) AS Total_Monthly_Sales
FROM 
    sales s
JOIN 
    products p ON s.ProductKey = p.ProductKey
GROUP BY 
    YearMonth
ORDER BY 
    YearMonth;

#Average Order Value (AOV)

SELECT 
    OrderNumber,
    SUM(s.Quantity * p.UnitPriceUSD) AS Order_Value
FROM 
    sales s
JOIN 
    products p ON s.ProductKey = p.ProductKey
GROUP BY 
    s.OrderNumber;

#7. Sales Growth Over Time

SELECT 
    YEAR(OrderDate) AS Year,
    MONTH(OrderDate) AS Month,
    SUM(s.Quantity * p.UnitPriceUSD) AS Monthly_Sales,
    LAG(SUM(s.Quantity * p.UnitPriceUSD)) OVER (ORDER BY YEAR(OrderDate), MONTH(OrderDate)) AS Previous_Month_Sales,
    ((SUM(s.Quantity * p.UnitPriceUSD) - LAG(SUM(s.Quantity * p.UnitPriceUSD)) OVER (ORDER BY YEAR(OrderDate), MONTH(OrderDate))) / LAG(SUM(s.Quantity * p.UnitPriceUSD)) OVER (ORDER BY YEAR(OrderDate), MONTH(OrderDate))) * 100 AS Monthly_Growth
FROM 
    sales s
JOIN 
    products p ON s.ProductKey = p.ProductKey
GROUP BY 
    Year, Month
ORDER BY 
    Year, Month;

SELECT 
    AVG(Order_Value) AS Average_Order_Value
FROM 
    (SELECT OrderNumber, SUM(s.Quantity * p.UnitPriceUSD) AS Order_Value FROM sales s JOIN products p ON s.ProductKey = p.ProductKey GROUP BY s.OrderNumber) AS Orders;

#Sales Contribution by Category

SELECT 
    p.Category,
    SUM(s.Quantity * p.UnitPriceUSD) AS Category_Sales
FROM 
    sales s
JOIN 
    products p ON s.ProductKey = p.ProductKey
GROUP BY 
    p.Category
ORDER BY 
    Category_Sales DESC;


PRODUCT ANALYSIS

1. Product Popularity
   SELECT 
    p.ProductName,
    SUM(s.Quantity) AS Total_Quantity_Sold
FROM 
    sales s
JOIN 
    products p ON s.ProductKey = p.ProductKey
GROUP BY 
    p.ProductName
ORDER BY 
    Total_Quantity_Sold DESC;

2. Profitability Analysis

SELECT 
    p.ProductName,
    SUM(s.Quantity * (p.UnitPriceUSD - p.UnitCostUSD)) AS Total_Profit,
    ROUND((SUM(s.Quantity * (p.UnitPriceUSD - p.UnitCostUSD)) / SUM(s.Quantity * p.UnitPriceUSD)) * 100, 2) AS Profit_Margin_Percentage
FROM 
    sales s
JOIN 
    products p ON s.ProductKey = p.ProductKey
GROUP BY 
    p.ProductName
ORDER BY 
    Total_Profit DESC;

3. Category Analysis

SELECT 
    p.Category,
    p.Subcategory,
    SUM(s.Quantity * p.UnitPriceUSD) AS Total_Category_Sales,
    SUM(s.Quantity) AS Total_Units_Sold
FROM 
    sales s
JOIN 
    products p ON s.ProductKey = p.ProductKey
GROUP BY 
    p.Category, p.Subcategory
ORDER BY 
    Total_Category_Sales DESC;


STORES ANALYSIS

1. store Performance

SELECT 
    s.StoreKey,  -- Replace with the correct store identifier column
    SUM(sales.Quantity * products.UnitPriceUSD) AS Total_Sales,
    COUNT(DISTINCT sales.CustomerKey) AS Unique_Customers,
    COUNT(sales.OrderNumber) AS Total_Orders
FROM 
    sales
JOIN 
    stores s ON sales.StoreKey = s.StoreKey  -- Make sure the join condition is correct
JOIN 
    products ON sales.ProductKey = products.ProductKey
GROUP BY 
    s.StoreKey  -- Replace with the correct store identifier
ORDER BY 
    Total_Sales DESC
LIMIT 0, 1000;

#Geographical Analysis of Sales by Store Location

SELECT 
    s.Country, 
    s.State, 
    SUM(sales.Quantity * products.UnitPriceUSD) AS Total_Sales,
    COUNT(sales.OrderNumber) AS Total_Orders
FROM 
    sales
JOIN 
    stores s ON sales.StoreKey = s.StoreKey
JOIN 
    products ON sales.ProductKey = products.ProductKey
GROUP BY 
    s.Country, s.State
ORDER BY 
    Total_Sales DESC;


#Total Sales by Store:
SELECT 
    s.StoreKey,
    SUM(sales.Quantity * products.UnitPriceUSD) AS Total_Sales,
    COUNT(DISTINCT sales.CustomerKey) AS Unique_Customers,
    COUNT(sales.OrderNumber) AS Total_Orders
FROM 
    sales
JOIN 
    stores s ON sales.StoreKey = s.StoreKey
JOIN 
    products ON sales.ProductKey = products.ProductKey
GROUP BY 
    s.StoreKey
ORDER BY 
    Total_Sales DESC
LIMIT 0, 1000;

#Sales by Store and Product:
SELECT 
    s.StoreKey,
    products.ProductName,
    SUM(sales.Quantity) AS Total_Quantity_Sold,
    SUM(sales.Quantity * products.UnitPriceUSD) AS Total_Sales
FROM 
    sales
JOIN 
    stores s ON sales.StoreKey = s.StoreKey
JOIN 
    products ON sales.ProductKey = products.ProductKey
GROUP BY 
    s.StoreKey, products.ProductName
ORDER BY 
    Total_Sales DESC;

#Count of Orders by Store:

SELECT 
    s.StoreKey,
    COUNT(sales.OrderNumber) AS Total_Orders
FROM 
    sales
    
JOIN 
    stores s ON sales.StoreKey = s.StoreKey
GROUP BY 
    s.StoreKey
ORDER BY 


