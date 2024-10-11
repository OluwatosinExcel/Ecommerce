SELECT *
FROM Superstore

-- Number of Rows --9994
SELECT COUNT(*) AS num_rows
FROM Superstore;

--Number of Columns  --21
SELECT COUNT(*) AS num_columns
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Superstore';

--Checks for NULL Values across the entire columns(no null value)
SELECT *
FROM Superstore
WHERE Row_ID IS NULL OR Order_ID IS NULL OR Order_Date IS NULL OR Ship_Date IS NULL OR Ship_Mode IS NULL OR Customer_ID IS NULL 
OR Customer_Name IS NULL OR Segment IS NULL OR Country_Region IS NULL OR City IS NULL OR State IS NULL OR Postal_Code IS NULL 
OR Region IS NULL OR Product_ID IS NULL OR Category IS NULL OR Sub_Category IS NULL OR Product_Name IS NULL OR Sales IS NULL 
OR Quantity IS NULL OR Discount IS NULL OR Profit IS NULL;  --Postal code column is null and one column in the profit  column


--Checks for replacement for missing values
SELECT *
FROM Superstore
WHERE State = 'Vermont'

-- Vermont State has no postal code in the dataset, I checked google and realized the Postal_Code is 05401, so I will replace the null values with this value.
--Updating null values for Burlington Vermont.
UPDATE Superstore
SET postal_code = '05401'
WHERE state = 'Vermont' AND city = 'Burlington' AND postal_code IS NULL;

--Postal_code updated as '5401' instead of '05401' stated. So I checked for the data type of the postal_code column and updated it
--Integer values cannot start with 0 basically so we change to varchar(10)
ALTER TABLE Superstore
ALTER COLUMN postal_code VARCHAR(10); -- Assume postal codes are 10 characters long


--Adding leading zero to existing values
UPDATE Superstore
SET postal_code = RIGHT('00000' + postal_code, 5)
WHERE state = 'Vermont' AND city = 'Burlington' AND postal_code IS NOT NULL;

--I noticed that there are some incorrect postal_code in my data without leading zeros and having just 4 digits
--Checked for the Postal_code with 4 digits instead of 5 and checked google for confirmation
SELECT *
FROM Superstore
WHERE LEN(postal_code) = 4 AND postal_code IS NOT NULL;

--Updating the 4 digits with leading zeros to make it 5 digits.
UPDATE Superstore
SET postal_code = RIGHT('0000' + postal_code, 5)
WHERE LEN(postal_code) = 4 AND postal_code IS NOT NULL;


UPDATE Superstore
SET Profit = 0
WHERE Row_ID = 7345 AND Profit IS NULL;

--Extracting only the date portion from the Order_Date
SELECT CONVERT(date, order_date) AS order_date_only
FROM Superstore;

--Checks for the data type of the order_date column

SELECT DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Superstore' AND COLUMN_NAME = 'order_date';

UPDATE Superstore
SET order_date = CONVERT(DATE, order_date);

--Changed the datatype for Order_date column from datetime(2) to date.
ALTER TABLE Superstore
ALTER COLUMN order_date DATE;

SELECT *
FROM Superstore

--return rows where the "Customer_Name" column contains leading or trailing spaces.
SELECT Customer_Name
FROM Superstore
WHERE LEN(Customer_Name) > LEN(LTRIM(Customer_Name)) OR LEN(Customer_Name) > LEN(RTRIM(Customer_Name));

--Identify duplicate records in the Superstore table where all column values are identical
SELECT *
FROM Superstore
WHERE Row_ID NOT IN (
    SELECT MIN(Row_ID)
    FROM Superstore
    GROUP BY Row_ID, Order_ID, Order_Date, Ship_Date, Ship_Mode, Customer_ID, Customer_Name, Segment, Country_Region, City, State, Postal_Code, Region, Product_ID, Category, Sub_Category, Product_Name, Sales, Quantity, Discount, Profit
);

-- From my dataset, i noticed that the difference between Order date and Ship date is incorrect. Order is made before shipping and from the dataset we have Ship_date 2years before order date in most cases.
-- Update Ship_date by adding 2 years to the existing values
UPDATE Superstore
SET Ship_date = DATEADD(year, 2, Ship_date);

--Seperates the Order_date column into day, month, year and specifies what day of the week it is.
SELECT 
    DATEPART(day, order_date) AS order_day,
    DATENAME(month, order_date) AS order_month,
    DATEPART(year, order_date) AS order_year,
    DATENAME(weekday, order_date) AS order_day_of_week
FROM Superstore;

ALTER TABLE Superstore
ADD order_day_of_week VARCHAR(50)

UPDATE Superstore
SET order_day_of_week = DATENAME(weekday, order_date)




-- Calculate total sales for each month from 2020-2023
WITH MonthlySales AS (
    SELECT 
        DATEPART(year, order_date) AS order_year,
        DATENAME(month, order_date) AS order_month,
        DATEPART(month, order_date) AS month_number,
        SUM(sales) AS total_sales
    FROM Superstore
    GROUP BY DATEPART(year, order_date), DATENAME(month, order_date), DATEPART(month, order_date)
)
-- Calculate percentage sales for each month
SELECT 
    order_year,
    order_month,
    total_sales,
    total_sales * 100.0 / SUM(total_sales) OVER () AS percentage_sales
FROM MonthlySales
ORDER BY order_year, month_number;


--What month of the year do we have the highest percentage_sales
WITH MonthlySales AS (
    SELECT 
        DATEPART(year, order_date) AS order_year,
        DATENAME(month, order_date) AS order_month,
        DATEPART(month, order_date) AS month_number,
        SUM(sales) AS total_sales
    FROM Superstore
    GROUP BY DATEPART(year, order_date), DATENAME(month, order_date), DATEPART(month, order_date)
)

SELECT 
    order_year,
    order_month,
    total_sales,
    total_sales * 100.0 / SUM(total_sales) OVER () AS percentage_sales
FROM MonthlySales
ORDER BY percentage_sales desc;
