USE NammaYatri;

select * from trips;

select * from trips_details;

select * from loc;

select * from duration;

select * from payment;

-- total trips

SELECT COUNT(DISTINCT(tripid)) AS Total_Trips FROM trips_details;
-- 2161 trips in a single day  

-- total drivers

SELECT COUNT(DISTINCT(driverid)) AS Total_Drivers FROM trips;

-- 30 drivers  

-- total earnings

SELECT SUM(fare) AS Total_Earnings FROM trips;

-- 7,51,343 Rupees

-- Total Completed trips

SELECT COUNT(DISTINCT(tripid)) AS Total_Completed_Trips FROM trips_details
WHERE end_ride = 1;

-- Total succesful trips in a single day: 983 

SELECT SUM(end_ride) AS total_completed_trips FROM trips_details;

-- total searches
SELECT SUM(searches) FROM trips_details;

-- Total searches made : 2161

-- Total searches which got estimate

SELECT SUM(searches_got_estimate) AS Estimate_Searches FROM trips_details;
-- total searches that got estimate : 1758

-- total searches for quotes

SELECT SUM(searches_for_quotes) AS Quote_Searches FROM trips_details;
-- Total searches for quotes: 1455

-- total searches which got quotes
SELECT SUM(searches_got_quotes) got_quotes FROM trips_details;
-- 1277

-- total OTPs entered
SELECT SUM(otp_entered) AS OTP_Entered FROM trips_details;
-- 983

-- total rides which ended succesfully
SELECT SUM(end_ride) AS Total_end_rides FROM trips_details;
-- 983

-- Cancelled bookings by driver

SELECT COUNT(driver_not_cancelled) AS cancelled_by_driver FROM trips_details
WHERE customer_not_cancelled = 1 AND driver_not_cancelled = 0;
-- 137 trips were cancelled by drivers

-- cancelled bookings by customer

SELECT COUNT(customer_not_cancelled) AS Cancelled_by_Cust FROM trips_details
WHERE customer_not_cancelled = 0;
-- 1041 trips where cancelled by customers

-- Average Distance per trip

SELECT SUM(distance) AS Avg_Distance_per_Trip FROM trips;
-- Average distance per trip is 14.3 km

-- Average fare per trip

SELECT AVG(fare) AS Avg_Fare FROM trips;
-- Average fare per trip is 764Rs

-- Total Distance travelled

SELECT SUM(distance) AS Avg_Distance FROM trips;
-- Total Distance travelled through the trips : 14148 KM

-- which is the most used payment method

SELECT p.method AS Payment_Method, COUNT(tripid) times_used FROM trips AS t
JOIN payment AS p ON p.id = t.faremethod
GROUP BY Payment_Method
ORDER BY times_used DESC
LIMIT 1;
-- Credit Card was the most used payment method

-- The highest payment was made through which instrument

WITH CTE AS(
SELECT p.method AS Payment_Method, MAX(t.fare) AS highest_payment, DENSE_RANK() OVER(ORDER BY MAX(t.fare) DESC) AS rk FROM trips AS t
JOIN payment AS p ON p.id = t.faremethod 
GROUP BY Payment_Method
ORDER BY highest_payment DESC)
SELECT Payment_Method, highest_payment FROM CTE
WHERE rk =1;

-- the highest payment was 1500Rs, Instruments which where used to make such payments were credit card and cash

-- Which two locations had the most trips
WITH CTE AS(
SELECT CONCAT(l.assembly1,"-",l1.assembly1) AS Route, COUNT(tripid) AS Num_of_Trips, DENSE_RANK() OVER(ORDER BY COUNT(tripid) DESC) AS rk FROM trips AS t
JOIN loc AS l ON l.id = t.loc_from
JOIN loc AS l1 ON l1.id = t.loc_to
GROUP BY route
ORDER BY num_of_trips DESC)
SELECT Route, Num_of_Trips FROM CTE
WHERE rk = 1;

-- The routes Gandhi Nagar - Yelahanka and Ramanagaram - Shanti Nagar are joint highest with 5 trips each.

-- Top 5 drivers with highest total earnings

SELECT driverid,SUM(fare) AS Total_Fare FROM trips
GROUP BY driverid
ORDER BY Total_Fare DESC
LIMIT 5;

-- which duration had more trips

SELECT * FROM duration;
SELECT * FROM trips;

WITH CTE AS
(SELECT d.duration AS Duration, COUNT(DISTINCT(tripid)) AS Num_of_Trips, DENSE_RANK() OVER(ORDER BY COUNT(DISTINCT(tripid)) DESC) AS pos FROM trips AS t
JOIN duration AS d ON d.id = t.duration
GROUP BY Duration)
SELECT Duration,Num_of_Trips FROM CTE
WHERE pos = 1;

-- Comment : Duration 0-1 has the most number of trips with 0-1

-- Which driver , customer pair had more orders
WITH CTE AS 
(SELECT CONCAT(driverid,"-",custid) AS driver_cust_pair, COUNT(tripid) num_of_orders,
DENSE_RANK() OVER(ORDER BY COUNT(DISTINCT(tripid)) DESC) AS pos FROM trips
GROUP BY driver_cust_pair)
SELECT driver_cust_pair,num_of_orders FROM CTE
WHERE pos = 1;

-- The driver customer pir 17 - 96 and 28 - 15 have the joint highest number of trips

-- Search to estimate rate

SELECT SUM(searches_got_estimate)/COUNT(searches_got_estimate)*100 AS search_to_estimate_rate FROM trips_details;
-- search to estimate rate : 81.35

-- Estimate to search for quote rates

SELECT SUM(searches_for_quotes)/COUNT(searches_for_quotes)*100 AS search_for_quotes FROM trips_details;
-- estimate to search for quote rate : 67.32

-- Quote acceptance rate

SELECT SUM(searches_got_quotes)/COUNT(searches_got_quotes)*100 AS quote_acceptance_rate FROM trips_details;
-- Quote acceptance rate: 59.09

-- Booking cancellation rate

SELECT (SUM(CASE WHEN otp_entered = 1 THEN 0 ELSE 1 END)/COUNT(tripid))*100 AS booking_cancellation_rate FROM trips_details;
-- Booking Cancellation Rate :54.51%

-- Conversion Rate

SELECT SUM(end_ride)*100/COUNT(tripid) AS convertion_rate FROM trips_details;
-- Conversion Rate (number of succesful trips/ total number of trips) : 45.48%


-- Which area got highest trips in which duration

SELECT l.assembly1 AS Area, d.duration AS Duration, COUNT(DISTINCT(t.tripid)) AS Num_of_Trips FROM loc AS l
JOIN trips AS t ON t.loc_from = l.id
JOIN duration AS d ON d.id =  t.duration
GROUP BY Area, Duration
ORDER BY Num_of_Trips DESC;

WITH CTE AS
(SELECT d.duration AS Duration, loc_from, COUNT(tripid) AS num_of_trips, 
RANK() OVER(PARTITION BY duration ORDER BY COUNT(tripid) DESC) AS pos FROM duration AS d
JOIN trips AS t ON t.duration = d.id
GROUP BY duration, loc_from)
SELECT Duration,assembly1 AS Area_with_Max_trips, num_of_trips FROM CTE AS c
JOIN loc AS l on c.loc_from = l.id
WHERE pos =1;

-- Which area got the highest fares
-- highest total fare
SELECT assembly1 AS Area, SUM(Fare) AS total_fare FROM loc AS l
JOIN trips AS t ON t.loc_from = l.id
GROUP BY Area;
-- Comment: The highest Total fare is coming from the location Gandhi Nagar

-- highest Average fare
SELECT assembly1 AS Area, AVG(Fare) AS Avg_fare FROM loc AS l
JOIN trips AS t on t.loc_from = l.id
GROUP BY Area;
-- Comment: The highest average fare is coming from the location Gandhi Nagar

-- Which area got the highest cancellations
SELECT assembly1 AS Area, SUM(CASE WHEN otp_entered = 0 THEN 1 ELSE 0 END) AS Num_of_Cancellations FROM loc AS l
JOIN trips_details AS td ON td.loc_from = l.id
GROUP BY Area
ORDER BY Num_of_Cancellations DESC;
-- Mahadevapura region has the highest number of cancellations with 49 cancellations


-- Area which got highest trips
SELECT (assembly1) AS Area, COUNT(tripid) AS Num_of_trips FROM loc AS l
JOIN trips AS t ON t.loc_from = l.id
GROUP BY Area 
ORDER BY Num_of_trips DESC;
-- Area which got the highest number of trips is Ramanagaram

-- Which duration got the highest trips and fares

SELECT d.duration AS Duration,COUNT(tripid) AS Num_of_Trips FROM duration AS d
JOIN trips AS t ON t.Duration = d.id
GROUP BY Duration
ORDER BY Num_of_Trips DESC
LIMIT 1;
-- 0-1 duration has the highest number of trips

-- Which duration has the highest total fare
SELECT d.duration AS Duration, SUM(t.fare) AS Total_fare FROM duration AS d
JOIN trips AS t ON t.duration = d.id
GROUP BY Duration
ORDER BY Total_fare DESC
LIMIT 1;
-- 0-1 duration has the highest fare 45019






