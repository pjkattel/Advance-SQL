
--Query Transcripts for the Course in LinkedIN Learning
-- SQL for Statistics


SELECT * FROM store_sales LIMIT 10;

--Total number of entries in the data
SELECT COUNT(*) FROM store_sales

-- Number of entries for each months
SELECT month_of_year, COUNT(*) FROM store_sales GROUP BY month_of_year

-- MAX in employee_shifts 
SELECT 
	MAX(employee_shifts)
FROM 
	store_sales

--MIN in employee shifts
SELECT 
	MIN(employee_shifts) 
FROM 
	store_sales

--MAX and MIN combined 
SELECT 
	MAX(employee_shifts),
	MIN(employee_shifts) 
FROM 
	store_sales


-- MAX and MIN employee shifts for each month of the year
SELECT
	month_of_year,
	MIN(employee_shifts),
	MAX(employee_shifts)
FROM
	store_sales
GROUP BY
	month_of_year

-- some statistical functions 
SELECT 
	* 
FROM 
	store_sales 
LIMIT 10

--SUM 
SELECT 
	SUM(units_sold) 
FROM 
	store_sales

--SUM and GROUP BY


--multiple aggregrate statistical function
SELECT 
	month_of_year, 
	SUM(units_sold), 
	AVG(units_sold)
FROM
	store_sales
GROUP BY 
	month_of_year
ORDER BY month_of_year

---variance and Standard Deviation
SELECT
	month_of_year,
	SUM(units_sold),
	round(AVG(units_sold),2) as round_AVG,
	round(VAR_POP(units_sold),2) as round_var,
	round(STDDEV_POP(units_sold),2) as round_std
FROM 
	store_sales
GROUP BY
	month_of_year


--Bucketing the data into percentiles 
-- Percentiles are One hundred equal GROUPs;
-- Percentiles help us understand the distribution of the data across the GROUP

--Discrete Percentile
--Discrete percentile returns the value that exists in the column

--Continuous Percentile
-- INterpolates the boundry value between percentiles 
-- these are useful when we want to know the values between the two percentiles buckets 

SELECT * FROM store_sales LIMIT 5

--sort data by revenue
SELECT
	*
FROM 
	store_sales
ORDER BY 
	revenue DESC

--avarage revenue
SELECT AVG(revenue) FROM store_sales

--DESCrete percentile to help us find the distribution of data 
SELECT
	percentile_disc(0.50) Within GROUP(ORDER BY revenue) as pct_50_rev
FROM 
	store_sales


--lets look at the 50th, 60th, 70th, 80th, 90th and 95th percentiles
SELECT
	percentile_disc(0.50) Within GROUP(ORDER BY revenue) as pct_50_rev,
	percentile_disc(0.60) Within GROUP(ORDER BY revenue) as pct_60_rev,
	percentile_disc(0.70) Within GROUP(ORDER BY revenue) as pct_70_rev,
	percentile_disc(0.80) Within GROUP(ORDER BY revenue) as pct_80_rev,
	percentile_disc(0.90) Within GROUP(ORDER BY revenue) as pct_90_rev,
	percentile_disc(0.95) Within GROUP(ORDER BY revenue) as pct_95_rev
FROM 
	store_sales

-- we can see that top 5 percent of sales have really good revenue 

--Continuous Percentile 
--gives the boundries (it is not necessary that the values must be in data)

SELECT 
	percentile_cont(0.95) within GROUP (ORDER BY revenue) as pct_95_cont_rev,
	percentile_disc(0.95) within GROUP (ORDER BY revenue) as pct_95_disc_rev
FROM 
	store_sales

--Corelation 
-- How two variable are ralated 
-- positively corelated and negatively corelated

SELECT 
	CORR(units_sold, revenue)
FROM 
	store_sales 

-- employee and units_sold
SELECT 
	CORR(units_sold, employee_shifts)
FROM 
	store_sales

-- units_sold and month_of_year
SELECT 
	CORR(units_sold, month_of_year)
FROM 
	store_sales

--this measure gives how the two variable behave if some changes occur in one of the column

--ROwWNUMBER
--(window functions)
SELECT 
sale_date,
month_of_year,
units_sold,
ROW_NUMBER() over(ORDER BY units_sold)as rank_unit_sold
FROM 
store_sales
ORDER BY sale_date


--mode function (most frequently occuring value)
-- most common number of employee shift in any given month
SELECT
month_of_year,
MODE() WITHIN GROUP (ORDER BY employee_shifts) as emp_moode
FROM
store_sales
GROUP BY
month_of_year

--Estamating Values 
--Linear Regression 
-- we need 3 things to perform regression
--1. Values to predict (what do you want to predict)
--2. Relationship within the variables ( how the variable are related)
--3. And the data (historical data)

-- MINimizing Error (RMSE) >> ROOT MEAN SQUARED ERROR
--computing intercept for linear regression line
-- we want to find the intercept for employee_shifts and units_sold
SELECT
	REGR_INTERCEPT(employee_shifts, units_sold)
FROM 
	store_sales

--This gives the basis for the linear line.  

--slope REGR_SLOPE(Y-axis, X-axis)
SELECT 
	REGR_SLOPE(employee_shifts, units_sold)
FROM 
	store_sales

-- we have slop and intercept , and let make some prediction for number of 
--required to handle 1500 sales 

SELECT 
	REGR_SLOPE(employee_shifts, units_sold)* 1500 + 
		REGR_INTERCEPT(employee_shifts, units_sold) as pv
FROM 
	store_sales

--- Learned In this Course
--DESCriptive statistics (mean, median, standard dev)
--Percentiles
--Relation within and between rows
--Linear Regression