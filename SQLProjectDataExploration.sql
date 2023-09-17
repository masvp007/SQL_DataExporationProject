--ZomatoDataExplorationProject

--Create golduser_signup Table
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 
--Insert data into golduser_signup Table
INSERT INTO goldusers_signup(userid,gold_signup_date) 
VALUES (1,'09-22-2017'),
	(3,'04-21-2017'),
	(6,'08-17-2018'),
	(10,'11-25-2020'),
	(12, '09-15-2020'),
	(15, '06-30-2020'),
    (18, '09-11-2021'),
    (22, '08-05-2023'),
    (25, '04-20-2023');

--Create users Table
CREATE TABLE users(userid integer,signup_date date); 

--Insert data into Users Table

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
	(2,'01-15-2015'),
	(3,'04-11-2014'),
    (4, '07-23-2017'),
    (5, '11-08-2017'),
    (6, '03-17-2018'),
    (7, '08-29-2018'),
    (8, '12-14-2019'),
    (9, '04-05-2020'),
    (10, '09-18-2020'),
    (11, '01-25-2020'),
    (12, '05-07-2020'),
    (13, '09-02-2020'),
    (14, '01-16-2020'),
    (15, '05-03-2020'),
    (16, '09-09-2020'),
    (17, '01-21-2021'),
	(18, '05-11-2021'),
    (19, '09-22-2021'),
    (20, '01-02-2022'),
    (21, '05-06-2022'),
    (22, '09-17-2022'),
    (23, '01-31-2023'),
    (24, '05-20-2023'),
    (25, '09-08-2023');
  
--Create sales Table
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

-- Insert data into sales Table

INSERT INTO sales (userid, created_date, product_id)
VALUES (1,'06-05-2017',2),(1,'06-05-2017',3),(2, '06-05-2017', 3),
    (3, '08-17-2017', 1),
    (4, '10-29-2017', 2),
    (2, '12-10-2017', 3),
    (6, '02-22-2018', 1),
    (6, '04-05-2018', 2),
    (5, '06-17-2018', 3),
    (4, '08-29-2018', 1),
    (7, '11-10-2018', 2),
    (8, '01-23-2019', 3),
    (1, '04-07-2019', 1),
    (3, '06-19-2019', 2),
    (5, '08-31-2019', 3),
    (6, '11-12-2019', 1),
    (9, '01-25-2020', 2),
    (9, '04-08-2020', 3),
    (10, '06-20-2020', 1),
    (19, '08-31-2020', 2),
    (25, '11-12-2020', 3),
    (16, '01-25-2021', 1),
    (16, '04-09-2021', 2),
    (18, '06-22-2021', 3),
    (19, '08-04-2021', 1),
    (14, '10-17-2021', 2),
    (11, '12-30-2021', 3),
    (12, '03-14-2022', 1),
    (13, '05-26-2022', 2),
    (14, '08-07-2022', 3),
    (15, '10-19-2022', 1),
	(21, '12-30-2023', 3),
    (22, '03-14-2023', 1),
    (23, '05-26-2023', 2),
    (24, '08-07-2023', 3),
    (25, '10-19-2023', 1),(1,'06-05-2018',1),(1,'06-05-2019',1),(3,'06-05-2018',2),
	(4,'06-05-2018',1),(4,'06-05-2018',1),(3, '08-08-2017', 3),(6, '08-11-2019', 3),(25, '08-08-2023', 2),
	(6,'06-05-2022',2),(6,'06-05-2021',1),(3,'06-05-2022',2);

--Create table product
CREATE TABLE product(product_id integer,product_name text,price integer); 

--insert into table product

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'Biriyani',200),
(2,'Burger',150),
(3,'Sandwich',100);



SELECT * FROM sales;
SELECT * FROM product;
SELECT * FROM goldusers_signup;
SELECT * FROM users;


--1)What is the total amount each customers spent?
SELECT s.userid AS Users,SUM(p.price) AS Total_Amount
FROM sales s INNER JOIN product p ON s.product_id = p.product_id 
GROUP BY s.userid


--2)How many days each customers purchased?
SELECT s.userid AS Users,COUNT(DISTINCT s.created_date) Days
FROM sales s 
GROUP BY s.userid;

--3)What was the first product purchased by each customers?
SELECT * FROM
(SELECT *,RANK() OVER(PARTITION BY userid ORDER BY created_date) AS Orders FROM sales)A WHERE Orders = 1;

--4) a)What is the most purchased item on the Menu , b)How many times it was purchased by all customers?
--a)
SELECT TOP 1 product_id,COUNT(product_id) purchase_count FROM sales GROUP BY product_id ORDER BY product_id DESC
--b)
SELECT userid,COUNT(product_id) purchase_count  FROM sales 
WHERE product_id = (SELECT TOP 1 product_id FROM sales GROUP BY product_id ORDER BY product_id DESC)
GROUP BY userid;

--5)Which item is most popular for each customer?
SELECT * FROM
(SELECT *,RANK() OVER(PARTITION BY userid ORDER BY counts DESC) 
Ranks FROM 
(SELECT userid,product_id,COUNT(product_id) AS counts 
FROM sales 
GROUP BY userid,product_id)a)b 
WHERE Ranks = 1;

--6)Which item was purchased after they become a members?

SELECT * FROM (SELECT *,RANK() OVER (PARTITION BY userid ORDER BY created_date) rnk 
FROM (SELECT s.userid,s.created_date,s.product_id,g.gold_signup_date 
FROM sales s INNER JOIN goldusers_signup g ON s.userid = g.userid AND created_date>=gold_signup_date)a)b WHERE rnk =1;

--7)Which item was purchased just brfore the customer become a member

SELECT * FROM (SELECT *,RANK() OVER (PARTITION BY userid ORDER BY created_date DESC) rnk 
FROM (SELECT s.userid,s.created_date,s.product_id,g.gold_signup_date 
FROM sales s INNER JOIN goldusers_signup g ON s.userid = g.userid AND created_date<gold_signup_date)a)b WHERE rnk =1;

--8)What is the total orders and amount spent for each member before they become a gold member?

SELECT userid,COUNT(created_date) AS total_orders,SUM(price) AS total_amount FROM(
SELECT a.*,	p.price FROM(
SELECT s.userid,s.created_date,s.product_id,g.gold_signup_date 
FROM sales s INNER JOIN goldusers_signup g ON s.userid = g.userid AND created_date<gold_signup_date)a INNER JOIN product p ON a.product_id = p.product_id) b 
GROUP BY userid;

 
--9)if buying each product generates points for eg 5rs=2 zomato point and each product has different purchasing points 
--for eg for Biriyani 5rs = 1 zomato point, for Burger  10rs=5 zomato points and Sandwich 5rs = 1 zomato point,
--A)CALCULATE POINTS COLLECTED BY EACH CUSTOMERS AND B)FOR WHICH PRODUCT MOST POINTS HAVE BEEN GIVEN TILL NOW.
--A)
SELECT d.userid,SUM(total_points)*2.5 AS total_cashback_earned FROM ( 
SELECT c.*,total_amt/points total_points FROM(
SELECT b.*,CASE WHEN product_id = 1 THEN 5 WHEN product_id = 2 THEN 2 WHEN product_id = 3 THEN 5 ELSE 0 END AS points FROM(  
SELECT a.userid,a.product_id,SUM(a.price) total_amt FROM( 
SELECT s.userid,s.product_id,p.price FROM sales s INNER JOIN product p ON s.product_id = p.product_id)a
GROUP BY a.userid,a.product_id)b)c)d GROUP BY userid;

--B)
SELECT f.* FROM(
SELECT e.*,RANK() OVER(ORDER BY total_points_earned DESC) rnk FROM(
SELECT d.product_id,SUM(total_points) AS total_points_earned FROM ( 
SELECT c.*,total_amt/points total_points FROM(
SELECT b.*,CASE WHEN product_id = 1 THEN 5 WHEN product_id = 2 THEN 2 WHEN product_id = 3 THEN 5 ELSE 0 END AS points FROM(  
SELECT a.userid,a.product_id,SUM(a.price) total_amt FROM( 
SELECT s.userid,s.product_id,p.price FROM sales s INNER JOIN product p ON s.product_id = p.product_id)a
GROUP BY a.userid,a.product_id)b)c)d GROUP BY product_id)e)f WHERE rnk = 1;



--10) in the first one year after a customer joins the gold program (including their join date) irrespective of what the customer has purchased they earn 5
--zomato points for every 10rs spent who earned more and what was their points earning in their first year?

SELECT a.*,p.price,p.price*0.5 total_points_earned from(
SELECT s.userid,s.created_date,s.product_id,g.gold_signup_date 
FROM sales s INNER JOIN goldusers_signup g ON s.userid = g.userid AND 
created_date>=gold_signup_date AND created_date <= DATEADD(year,1,gold_signup_date))a inner join product p on a.product_id = p.product_id;


--11) Rank all the transaction of the customers

SELECT *,RANK() OVER (PARTITION BY userid ORDER BY created_date) Ranking FROM sales;


--12) Rank all the transaction for each member whenever they are a zomato gold member for every non gold member transaction mark as na


SELECT *,CASE WHEN rnk = 0 THEN 'NA' ELSE rnk END AS RANKS 
FROM (SELECT *,CAST(CASE WHEN gold_signup_date IS NULL THEN 0 ELSE RANK() OVER (PARTITION BY userid ORDER BY created_date DESC) END AS VARCHAR) AS rnk
FROM (SELECT s.userid, s.created_date, g.gold_signup_date, s.product_id FROM sales s LEFT JOIN goldusers_signup g 
ON s.userid = g.userid AND created_date >= gold_signup_date)a)b;

