-- ========================================
-- Zepto Inventory SQL Data Analysis Project
-- Author: Santhosh S
-- Description: Data exploration, cleaning, 
-- and business insights from product data
-- ========================================

-- ----------------------------------------
-- 🛠️ TABLE CREATION
-- ----------------------------------------

CREATE TABLE zepto (
  sku_id INT AUTO_INCREMENT PRIMARY KEY,               -- Unique product identifier
  category VARCHAR(120),                               -- Product category (e.g., Beverages, Snacks)
  name VARCHAR(150) NOT NULL,                          -- Product name
  mrp DECIMAL(8,2),                                    -- Maximum Retail Price (in paise initially)
  discountPercent DECIMAL(5,2),                        -- Discount percentage
  availableQuantity INT,                               -- Quantity available for sale
  discountedSellingPrice DECIMAL(8,2),                 -- Price after discount (in paise initially)
  weightInGms INT,                                     -- Weight of the product in grams
  outOfStock BOOLEAN,                                  -- TRUE if out of stock
  quantity INT                                         -- Ordered quantity
);

-- ----------------------------------------
-- 🔍 DATA EXPLORATION
-- ----------------------------------------

-- 1. Total number of rows in the dataset
SELECT COUNT(*) FROM zepto;

-- 2. View first 10 rows
SELECT * FROM zepto LIMIT 10;

-- 3. Check for NULL values across all columns
SELECT * FROM zepto
WHERE Category IS NULL
  OR name IS NULL
  OR mrp IS NULL
  OR discountPercent IS NULL
  OR availableQuantity IS NULL
  OR discountedSellingPrice IS NULL
  OR weightInGms IS NULL
  OR outOfStock IS NULL
  OR quantity IS NULL;

-- 4. List all unique product categories
SELECT DISTINCT Category FROM zepto ORDER BY Category;

-- 5. Count of in-stock vs out-of-stock products
SELECT outOfStock, COUNT(sku_id) AS stock_count
FROM zepto
GROUP BY outOfStock;

-- 6. Identify product names repeated multiple times
SELECT name, COUNT(sku_id) AS NUMBER_OF_STOCK
FROM zepto
GROUP BY name
HAVING COUNT(sku_id) > 1
ORDER BY COUNT(sku_id) DESC;

-- ----------------------------------------
-- 🧹 DATA CLEANING
-- ----------------------------------------

-- 1. Find rows with zero price (invalid data)
SELECT * FROM zepto WHERE discountedSellingPrice = 0 OR mrp = 0;

-- 2. Delete rows with zero price
DELETE FROM zepto WHERE discountedSellingPrice = 0 OR mrp = 0;

-- 3. Convert mrp and discountedSellingPrice from paise to rupees
UPDATE zepto
SET mrp = mrp / 100,
    discountedSellingPrice = discountedSellingPrice / 100;

-- ----------------------------------------
-- 📊 BUSINESS INSIGHTS
-- ----------------------------------------

-- 1. Top 10 best value products based on discount %
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;

-- 2. High-MRP products that are out of stock
SELECT DISTINCT name, mrp
FROM zepto
WHERE outOfStock = TRUE AND mrp > 200
ORDER BY mrp DESC;

-- 3. Estimated revenue for each category
SELECT Category,
       SUM(availableQuantity * discountedSellingPrice) AS EST_REVENUE
FROM zepto
GROUP BY Category
ORDER BY EST_REVENUE DESC;

-- 4. Products with high MRP but low discount
SELECT *
FROM zepto
WHERE mrp > 500 AND discountPercent < 10;

-- 5. Top 5 categories offering the highest average discount %
SELECT Category, 
       AVG(discountPercent) AS DISCOUNT_PERCENT
FROM zepto
GROUP BY Category
ORDER BY DISCOUNT_PERCENT DESC
LIMIT 5;

-- 6. Price per gram for products above 100g (best value first)
SELECT name, weightInGms, discountedSellingPrice,
       ROUND(discountedSellingPrice / weightInGms, 2) AS PRICE_PER_GRAM
FROM zepto
WHERE weightInGms > 100
ORDER BY PRICE_PER_GRAM ASC;

-- 7. Categorize products based on weight
SELECT name, weightInGms,
  CASE 
    WHEN weightInGms < 1000 THEN 'LOW'
    WHEN weightInGms < 3000 THEN 'MEDIUM'
    ELSE 'BULK'
  END AS WEIGHT_CATEGORY
FROM zepto;

-- 8. Total inventory weight per category
SELECT Category,
       SUM(weightInGms * availableQuantity) AS CATEGORY_WEIGHT
FROM zepto
GROUP BY Category
ORDER BY CATEGORY_WEIGHT DESC;

