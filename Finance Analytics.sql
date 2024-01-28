# Finance Analytics
# Requirement :
-- To generate a report of individual product sales - aggregated on monthly basis at product code level for croma india for FY 2021 .

-- a.create a function 'get_fiscal_year' to get fiscal year by passing the date
/*
    CREATE DEFINER=`root`@`localhost` FUNCTION `get_fiscal_year`(calendar_date DATE) RETURNS int
    DETERMINISTIC
BEGIN
        	DECLARE fiscal_year INT;
        	SET fiscal_year = YEAR(DATE_ADD(calendar_date, INTERVAL 4 MONTH));
        	RETURN fiscal_year;
	END
*/

-- b.using created function to create report
	SELECT * FROM fact_sales_monthly 
	WHERE 
            customer_code=90002002 AND
            get_fiscal_year(date)=2021 
	ORDER BY date asc
	LIMIT 100000;
    
-- further upgrading this query for  user-friendly and effortless use
-- creating a function that can give us customer code from cutomer name
-- create a function 'get_customer_code' to get customer_code from customer name that can be directly used in query with ease
	/*
	CREATE DEFINER=`root`@`localhost` FUNCTION `get_customer_code`(customer_name varchar(255)) RETURNS int
		DETERMINISTIC
	BEGIN
		declare code INT;
		SELECT customer_code INTO code
		FROM dim_customer
		WHERE customer LIKE CONCAT('%', customer_name, '%');
	RETURN code;
	END
	*/
-- new query 
	SELECT * FROM fact_sales_monthly 
	WHERE 
            customer_code=get_customer_code("croma") AND
            get_fiscal_year(date)=2021 
	ORDER BY date asc
	LIMIT 100000;
    
    


# Requirement :
-- Gross Sales Report: Monthly Product Transactions
-- Solution : 
		SELECT 
    	    s.date, 
            s.product_code, 
            p.product, 
            p.variant, 
            s.sold_quantity, 
            g.gross_price,
            ROUND(s.sold_quantity*g.gross_price,2) as gross_price_total
	FROM fact_sales_monthly s
	JOIN dim_product p
            ON s.product_code=p.product_code
	JOIN fact_gross_price g
            ON g.fiscal_year=get_fiscal_year(s.date)
    	AND g.product_code=s.product_code
	WHERE 
    	    customer_code=get_customer_code("croma") AND 
            get_fiscal_year(s.date)=2021     
	LIMIT 1000000;
    


#Gross Sales Report: Total Sales Amount

-- Generate monthly gross sales report for Croma India for all the years
	SELECT 
            s.date, 
    	    SUM(ROUND(s.sold_quantity*g.gross_price,2)) as monthly_sales
	FROM fact_sales_monthly s
	JOIN fact_gross_price g
        ON g.fiscal_year=get_fiscal_year(s.date) AND g.product_code=s.product_code
	WHERE 
             customer_code=get_customer_code("croma")
	GROUP BY date;


# Requirement :
# Generate monthly gross sales report for any customer using stored procedure
# solution : Creating a store procedure which can give this report by entering just the customer name
# Stored Procedures: Monthly Gross Sales Report
	/*
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_monthly_gross_sales_for_customer`(
        	in_customer_name TEXT
	)
BEGIN
        	SELECT 
                    s.date, 
                    SUM(ROUND(s.sold_quantity*g.gross_price,2)) as monthly_sales
        	FROM fact_sales_monthly s
        	JOIN fact_gross_price g
               	    ON g.fiscal_year=get_fiscal_year(s.date)
                    AND g.product_code=s.product_code
        	WHERE 
                    FIND_IN_SET(s.customer_code,get_customer_code(in_customer_name)) > 0
        	GROUP BY s.date
        	ORDER BY s.date DESC;
	END
	*/



#Stored Procedure: Market Badge

--  Write a stored proc that can retrieve market badge. i.e. if total sold quantity > 5 million that market is considered "Gold" else "Silver"
	/*
    CREATE PROCEDURE `get_market_badge`(
        	IN in_market VARCHAR(45),
        	IN in_fiscal_year YEAR,
        	OUT out_level VARCHAR(45)
	)
	BEGIN
             DECLARE qty INT DEFAULT 0;
    
    	     # Default market is India
    	     IF in_market = "" THEN
                  SET in_market="India";
             END IF;
    
    	     # Retrieve total sold quantity for a given market in a given year
             SELECT 
                  SUM(s.sold_quantity) INTO qty
             FROM fact_sales_monthly s
             JOIN dim_customer c
             ON s.customer_code=c.customer_code
             WHERE 
                  get_fiscal_year(s.date)=in_fiscal_year AND
                  c.market=in_market;
        
             # Determine Gold vs Silver status
             IF qty > 5000000 THEN
                  SET out_level = 'Gold';
             ELSE
                  SET out_level = 'Silver';
             END IF;
	END
	*/















































