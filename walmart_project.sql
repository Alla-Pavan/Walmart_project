SELECT * FROM walmart;
SELECT COUNT(*) FROM walmart;

--- for distinct payment methods

SELECT DISTINCT(payment_method) FROM walmart;

--- FOR DIFFERENT CATEGORIES

SELECT DISTINCT(category) FROM walmart;

SELECT payment_method,COUNT(*) FROM walmart GROUP BY payment_method;

SELECT category,COUNT(*) FROM walmart GROUP BY category;

SELECT COUNT(DISTINCT(branch)) FROM walmart;

SELECT COUNT(DISTINCT(CITY)) FROM walmart;

SELECT MAX(quantity) FROM walmart;
SELECT MIN(quantity) FROM walmart;

--- Business problems

	-- Q1: Find different payment methods, number of transactions, and quantity sold by payment method

	SELECT 
		payment_method,
		COUNT(*) AS no_transcations,
		SUM(quantity) AS no_qty_sold
	FROM walmart 
	GROUP BY payment_method;

	-- Project Question #2: Identify the highest-rated category in each branch Display the branch, category, and avg rating

	SELECT branch,category,avg_rating 
	FROM
	(
		SELECT 
			branch,
			category,
			AVG(rating) AS avg_rating,
			RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS c_rank 
			FROM walmart
		GROUP BY branch,category
	)AS RANKED
	WHERE c_rank = 1 ;

	-- Q3: Identify the busiest day for each branch based on the number of transactions
	SELECT * FROM
	(
		SELECT 
			branch,
			DAYNAME(STR_TO_DATE(date, '%d/%m/%Y')) AS day_name,
			COUNT(*) AS no_transactions,
			RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS h_rank
		FROM walmart
		GROUP BY branch,day_name
		ORDER BY branch,no_transactions DESC
	) AS RANKED 
	WHERE h_rank =1;

	-- Q4: Calculate the total quantity of items sold per payment method
	SELECT 
		payment_method,
		SUM(quantity) AS total_quantity
		FROM walmart
	GROUP BY payment_method;

	-- Q5: Determine the average, minimum, and maximum rating of categories for each city

	SELECT 
		city,
		category,
		AVG(rating),
		MAX(rating),
		MIN(rating)
		FROM walmart
	GROUP BY city,category;

	-- Q6: Calculate the total profit for each category

	SELECT  
	category,
	SUM(total) AS total_revenue,
	SUM(total * profit_margin) AS category_profit
	FROM walmart
	GROUP BY category
	ORDER BY category_profit DESC;

	-- Q7: Determine the most common payment method for each branch
	 
	 
	 WITH cte
	 AS
	 (
		 SELECT 
			 branch,
			 payment_method,
			 COUNT(*) AS total_trans,
		 RANK() OVER (PARTITION BY branch ORDER BY count(*) DESC) AS b_rank
		 FROM walmart
		 GROUP BY branch, payment_method
	 )
	 SELECT * FROM cte WHERE b_rank=1;
	 
	 -- Q8: Categorize sales into Morning, Afternoon, and Evening shifts
	 
	SELECT 
	Branch,
		CASE 
			  WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
			WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
			ELSE 'Evening'
		END day_time,
		COUNT(*)
	FROM walmart
	GROUP BY branch , day_time
	ORDER BY branch, count(*) DESC; 

	-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)

	SELECT *,
	YEAR(STR_TO_DATE(date,'%d/%m/%Y')) AS formatted_date
	FROM walmart;

	-- 2023 revenue
	WITH revenue_2022 
	AS
	(
		SELECT 
			branch,
			SUM(total) AS revenue
			FROM walmart
			WHERE YEAR(STR_TO_DATE(date,'%d/%m/%Y')) =2022
			GROUP BY branch
	),
	revenue_2023  AS
	(
		SELECT 
			branch,
			SUM(total) AS revenue
			FROM walmart
			WHERE YEAR(STR_TO_DATE(date,'%d/%m/%Y')) =2023
			GROUP BY branch
	)
	SELECT 
		r2022.branch,
		r2022.revenue as last_year_revenue,
		r2023.revenue as current_year_revenue,
		ROUND(((r2022.revenue - r2023.revenue)/r2022.revenue)*100,2) AS revenue_decrease_ratio
		FROM revenue_2022 AS r2022
		JOIN revenue_2023 AS r2023 ON r2022.branch =r2023.branch
		WHERE r2022.revenue > r2023.revenue
		ORDER BY revenue_decrease_ratio DESC
		LIMIT 5;
