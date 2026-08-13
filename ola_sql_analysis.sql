/* =====================================================================
   OLA RIDE BOOKING DATA ANALYTICS — SQL ANALYSIS SCRIPT
   -----------------------------------------------------------------
   Written for MySQL 8+ / PostgreSQL 13+ (minor date-function syntax
   differences are noted inline where relevant).
   Source file: ola_bookings_cleaned.csv (output of the Excel cleaning
   stage — see Ola_Data_Cleaning.xlsx).
   ===================================================================== */


/* ---------------------------------------------------------------------
   0. DATABASE & TABLE SETUP
   --------------------------------------------------------------------- */
CREATE DATABASE IF NOT EXISTS ola_analytics;
USE ola_analytics;

DROP TABLE IF EXISTS ola_bookings;

CREATE TABLE ola_bookings (
    booking_id          VARCHAR(15)     PRIMARY KEY,
    booking_date        DATE            NOT NULL,
    booking_time        TIME            NOT NULL,
    customer_id         VARCHAR(15)     NOT NULL,
    driver_id           VARCHAR(20),
    vehicle_type        VARCHAR(20)     NOT NULL,
    pickup_location      VARCHAR(50)     NOT NULL,
    drop_location        VARCHAR(50)     NOT NULL,
    ride_distance_km     DECIMAL(6,1),
    booking_status       VARCHAR(30)     NOT NULL,
    cancellation_reason  VARCHAR(60),
    payment_method       VARCHAR(20),
    booking_value_inr    DECIMAL(10,2),
    driver_rating        DECIMAL(2,1),
    customer_rating      DECIMAL(2,1),
    ride_duration_min    DECIMAL(6,1),
    booking_day          VARCHAR(10),
    booking_month        VARCHAR(10),
    booking_week         INT,
    is_weekend           VARCHAR(3),
    booking_hour         INT,
    is_cancelled         VARCHAR(3),
    revenue_per_km        DECIMAL(8,2),
    validation_flag       VARCHAR(10)
);

/* ---------------------------------------------------------------------
   Bulk-load the cleaned CSV (adjust path / use your DB client's
   "Import Wizard" if loading manually in MySQL Workbench).
   MySQL:
   --------------------------------------------------------------------- */
-- LOAD DATA LOCAL INFILE '/path/to/ola_bookings_cleaned.csv'
-- INTO TABLE ola_bookings
-- FIELDS TERMINATED BY ',' ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS;

-- PostgreSQL equivalent:
-- \copy ola_bookings FROM 'ola_bookings_cleaned.csv' WITH (FORMAT csv, HEADER true);


/* =====================================================================
   1. OVERALL BOOKING VOLUME
   ===================================================================== */

-- 1.1 Total bookings received
SELECT COUNT(*) AS total_bookings
FROM ola_bookings;

-- 1.2 Successful bookings (completed rides)
SELECT COUNT(*) AS successful_bookings
FROM ola_bookings
WHERE booking_status = 'Success';

-- 1.3 Cancelled bookings (customer + driver cancellations + driver not found)
SELECT COUNT(*) AS cancelled_bookings
FROM ola_bookings
WHERE is_cancelled = 'Yes';

-- 1.4 Cancellation rate (%) — key reliability KPI
SELECT
    ROUND(
        SUM(CASE WHEN is_cancelled = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS cancellation_rate_pct
FROM ola_bookings;

-- 1.5 Success rate (%) — complement of cancellation rate, easy KPI card
SELECT
    ROUND(
        SUM(CASE WHEN booking_status = 'Success' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS success_rate_pct
FROM ola_bookings;


/* =====================================================================
   2. REVENUE PERFORMANCE
   ===================================================================== */

-- 2.1 Total revenue generated (only successful rides carry a fare)
SELECT ROUND(SUM(booking_value_inr), 2) AS total_revenue
FROM ola_bookings
WHERE booking_status = 'Success';

-- 2.2 Average booking value per successful ride
SELECT ROUND(AVG(booking_value_inr), 2) AS avg_booking_value
FROM ola_bookings
WHERE booking_status = 'Success';

-- 2.3 Revenue by vehicle type — which segment drives the business
SELECT
    vehicle_type,
    COUNT(*)                         AS successful_rides,
    ROUND(SUM(booking_value_inr), 2) AS total_revenue,
    ROUND(AVG(booking_value_inr), 2) AS avg_booking_value
FROM ola_bookings
WHERE booking_status = 'Success'
GROUP BY vehicle_type
ORDER BY total_revenue DESC;

-- 2.4 Revenue efficiency: average revenue earned per km, by vehicle type
SELECT
    vehicle_type,
    ROUND(AVG(revenue_per_km), 2) AS avg_revenue_per_km
FROM ola_bookings
WHERE booking_status = 'Success'
GROUP BY vehicle_type
ORDER BY avg_revenue_per_km DESC;


/* =====================================================================
   3. RIDE DISTANCE & DURATION
   ===================================================================== */

-- 3.1 Average ride distance across all bookings
SELECT ROUND(AVG(ride_distance_km), 2) AS avg_ride_distance_km
FROM ola_bookings;

-- 3.2 Average ride duration (successful rides only — cancelled rides have 0)
SELECT ROUND(AVG(ride_duration_min), 2) AS avg_ride_duration_min
FROM ola_bookings
WHERE booking_status = 'Success';

-- 3.3 Distance distribution buckets — useful for understanding short vs long trips
SELECT
    CASE
        WHEN ride_distance_km < 3   THEN '0-3 km'
        WHEN ride_distance_km < 7   THEN '3-7 km'
        WHEN ride_distance_km < 12  THEN '7-12 km'
        WHEN ride_distance_km < 20  THEN '12-20 km'
        ELSE '20+ km'
    END AS distance_bucket,
    COUNT(*) AS rides
FROM ola_bookings
WHERE booking_status = 'Success'
GROUP BY distance_bucket
ORDER BY MIN(ride_distance_km);


/* =====================================================================
   4. VEHICLE TYPE ANALYSIS
   ===================================================================== */

-- 4.1 Most popular vehicle type by booking volume
SELECT
    vehicle_type,
    COUNT(*) AS total_bookings
FROM ola_bookings
GROUP BY vehicle_type
ORDER BY total_bookings DESC;

-- 4.2 Vehicle type performance: bookings, cancellation rate, revenue, ratings — one view
SELECT
    vehicle_type,
    COUNT(*)                                                         AS total_bookings,
    SUM(CASE WHEN booking_status='Success' THEN 1 ELSE 0 END)        AS successful_rides,
    ROUND(SUM(CASE WHEN is_cancelled='Yes' THEN 1 ELSE 0 END) * 100.0
          / COUNT(*), 2)                                             AS cancellation_rate_pct,
    ROUND(SUM(CASE WHEN booking_status='Success' THEN booking_value_inr
                    ELSE 0 END), 2)                                  AS total_revenue,
    ROUND(AVG(driver_rating), 2)                                     AS avg_driver_rating
FROM ola_bookings
GROUP BY vehicle_type
ORDER BY total_revenue DESC;


/* =====================================================================
   5. LOCATION ANALYSIS
   ===================================================================== */

-- 5.1 Most popular pickup locations
SELECT
    pickup_location,
    COUNT(*) AS total_bookings
FROM ola_bookings
GROUP BY pickup_location
ORDER BY total_bookings DESC
LIMIT 10;

-- 5.2 Most popular drop locations
SELECT
    drop_location,
    COUNT(*) AS total_bookings
FROM ola_bookings
GROUP BY drop_location
ORDER BY total_bookings DESC
LIMIT 10;

-- 5.3 Top-performing pickup locations by revenue generated
SELECT
    pickup_location,
    ROUND(SUM(booking_value_inr), 2) AS total_revenue,
    COUNT(*)                         AS successful_rides
FROM ola_bookings
WHERE booking_status = 'Success'
GROUP BY pickup_location
ORDER BY total_revenue DESC
LIMIT 10;

-- 5.4 Locations with high demand but low success (poor fulfillment — an operations risk area)
SELECT
    pickup_location,
    COUNT(*)                                                     AS total_bookings,
    SUM(CASE WHEN is_cancelled='Yes' THEN 1 ELSE 0 END)          AS cancelled_bookings,
    ROUND(SUM(CASE WHEN is_cancelled='Yes' THEN 1 ELSE 0 END) * 100.0
          / COUNT(*), 2)                                         AS cancellation_rate_pct
FROM ola_bookings
GROUP BY pickup_location
HAVING COUNT(*) >= 30                       -- only consider locations with meaningful volume
ORDER BY cancellation_rate_pct DESC
LIMIT 10;


/* =====================================================================
   6. PAYMENT METHOD ANALYSIS
   ===================================================================== */

-- 6.1 Payment method distribution (successful rides only — cancelled rides have no payment)
SELECT
    payment_method,
    COUNT(*)                                        AS rides,
    ROUND(COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM ola_bookings WHERE booking_status='Success'), 2) AS pct_of_rides,
    ROUND(SUM(booking_value_inr), 2)                AS total_revenue
FROM ola_bookings
WHERE booking_status = 'Success'
GROUP BY payment_method
ORDER BY rides DESC;


/* =====================================================================
   7. RATINGS ANALYSIS
   ===================================================================== */

-- 7.1 Overall average driver & customer rating
SELECT
    ROUND(AVG(driver_rating), 2)   AS avg_driver_rating,
    ROUND(AVG(customer_rating), 2) AS avg_customer_rating
FROM ola_bookings
WHERE booking_status = 'Success';

-- 7.2 Average ratings by vehicle type — spot service-quality gaps
SELECT
    vehicle_type,
    ROUND(AVG(driver_rating), 2)   AS avg_driver_rating,
    ROUND(AVG(customer_rating), 2) AS avg_customer_rating,
    COUNT(*)                       AS rated_rides
FROM ola_bookings
WHERE booking_status = 'Success'
GROUP BY vehicle_type
ORDER BY avg_driver_rating DESC;

-- 7.3 Low-rated rides worth investigating (driver rating below 3)
SELECT
    booking_id, vehicle_type, pickup_location, drop_location, driver_rating, customer_rating
FROM ola_bookings
WHERE booking_status = 'Success' AND driver_rating < 3
ORDER BY driver_rating ASC;


/* =====================================================================
   8. TIME-BASED TRENDS
   ===================================================================== */

-- 8.1 Daily booking trend
SELECT
    booking_date,
    COUNT(*) AS total_bookings,
    SUM(CASE WHEN booking_status='Success' THEN 1 ELSE 0 END) AS successful_bookings
FROM ola_bookings
GROUP BY booking_date
ORDER BY booking_date;

-- 8.2 Weekly booking trend
SELECT
    booking_week,
    COUNT(*) AS total_bookings,
    ROUND(SUM(CASE WHEN booking_status='Success' THEN booking_value_inr ELSE 0 END), 2) AS weekly_revenue
FROM ola_bookings
GROUP BY booking_week
ORDER BY booking_week;

-- 8.3 Monthly booking trend
SELECT
    booking_month,
    COUNT(*)                                                                             AS total_bookings,
    ROUND(SUM(CASE WHEN booking_status='Success' THEN booking_value_inr ELSE 0 END), 2)  AS monthly_revenue
FROM ola_bookings
GROUP BY booking_month
ORDER BY MIN(booking_date);

-- 8.4 Demand by day of week — where the weekly peaks are
SELECT
    booking_day,
    COUNT(*) AS total_bookings
FROM ola_bookings
GROUP BY booking_day
ORDER BY total_bookings DESC;

-- 8.5 Demand by hour of day — identifies rush-hour peaks for driver allocation
SELECT
    booking_hour,
    COUNT(*) AS total_bookings
FROM ola_bookings
GROUP BY booking_hour
ORDER BY booking_hour;

-- 8.6 Weekday vs weekend comparison
SELECT
    is_weekend,
    COUNT(*)                                                       AS total_bookings,
    ROUND(AVG(booking_value_inr), 2)                               AS avg_booking_value,
    ROUND(SUM(CASE WHEN is_cancelled='Yes' THEN 1 ELSE 0 END)*100.0
          / COUNT(*), 2)                                           AS cancellation_rate_pct
FROM ola_bookings
GROUP BY is_weekend;


/* =====================================================================
   9. CANCELLATION ANALYSIS
   ===================================================================== */

-- 9.1 Cancellation reasons ranked by frequency
SELECT
    cancellation_reason,
    COUNT(*) AS occurrences,
    ROUND(COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM ola_bookings WHERE is_cancelled='Yes'), 2) AS pct_of_cancellations
FROM ola_bookings
WHERE is_cancelled = 'Yes'
GROUP BY cancellation_reason
ORDER BY occurrences DESC;

-- 9.2 Cancellations by initiator: customer- vs driver- vs system-side (no driver found)
SELECT
    booking_status,
    COUNT(*) AS occurrences
FROM ola_bookings
WHERE is_cancelled = 'Yes'
GROUP BY booking_status
ORDER BY occurrences DESC;

-- 9.3 Cancellation rate by vehicle type (repeated here for the cancellation-focused report section)
SELECT
    vehicle_type,
    ROUND(SUM(CASE WHEN is_cancelled='Yes' THEN 1 ELSE 0 END) * 100.0
          / COUNT(*), 2) AS cancellation_rate_pct
FROM ola_bookings
GROUP BY vehicle_type
ORDER BY cancellation_rate_pct DESC;

-- 9.4 Cancellation rate by hour of day — surfaces operational stress windows
SELECT
    booking_hour,
    COUNT(*)                                                    AS total_bookings,
    ROUND(SUM(CASE WHEN is_cancelled='Yes' THEN 1 ELSE 0 END)*100.0
          / COUNT(*), 2)                                        AS cancellation_rate_pct
FROM ola_bookings
GROUP BY booking_hour
ORDER BY booking_hour;


/* =====================================================================
   10. CUSTOMER & DRIVER ANALYSIS
   ===================================================================== */

-- 10.1 Top 10 customers by number of rides booked
SELECT
    customer_id,
    COUNT(*)                                        AS total_bookings,
    ROUND(SUM(CASE WHEN booking_status='Success'
              THEN booking_value_inr ELSE 0 END), 2) AS total_spend
FROM ola_bookings
GROUP BY customer_id
ORDER BY total_bookings DESC
LIMIT 10;

-- 10.2 Top 10 drivers by number of completed rides
SELECT
    driver_id,
    COUNT(*)                          AS completed_rides,
    ROUND(AVG(driver_rating), 2)      AS avg_rating,
    ROUND(SUM(booking_value_inr), 2)  AS revenue_generated
FROM ola_bookings
WHERE booking_status = 'Success' AND driver_id <> 'Not Assigned'
GROUP BY driver_id
ORDER BY completed_rides DESC
LIMIT 10;

-- 10.3 Repeat customers vs one-time customers
SELECT
    CASE WHEN total_bookings = 1 THEN 'One-time customer' ELSE 'Repeat customer' END AS customer_type,
    COUNT(*) AS number_of_customers
FROM (
    SELECT customer_id, COUNT(*) AS total_bookings
    FROM ola_bookings
    GROUP BY customer_id
) t
GROUP BY customer_type;


/* =====================================================================
   11. EXECUTIVE SUMMARY VIEW
   (One query that mirrors the Power BI KPI cards — handy for a quick
    sanity check that SQL and the dashboard numbers match.)
   ===================================================================== */
SELECT
    COUNT(*)                                                         AS total_bookings,
    SUM(CASE WHEN booking_status='Success' THEN 1 ELSE 0 END)        AS successful_bookings,
    SUM(CASE WHEN is_cancelled='Yes' THEN 1 ELSE 0 END)               AS cancelled_bookings,
    ROUND(SUM(CASE WHEN is_cancelled='Yes' THEN 1 ELSE 0 END)*100.0
          / COUNT(*), 2)                                              AS cancellation_rate_pct,
    ROUND(SUM(CASE WHEN booking_status='Success'
              THEN booking_value_inr ELSE 0 END), 2)                  AS total_revenue,
    ROUND(AVG(CASE WHEN booking_status='Success'
              THEN booking_value_inr END), 2)                         AS avg_booking_value,
    ROUND(AVG(ride_distance_km), 2)                                   AS avg_ride_distance_km,
    ROUND(AVG(CASE WHEN booking_status='Success'
              THEN ride_duration_min END), 2)                         AS avg_ride_duration_min
FROM ola_bookings;

/* ===================================================================== 
   OPTIONAL: a reusable VIEW so Power BI / Excel can connect to one
   clean object instead of re-running logic every time.
   ===================================================================== */
CREATE OR REPLACE VIEW vw_ola_monthly_summary AS
SELECT
    booking_month,
    vehicle_type,
    COUNT(*)                                                        AS total_bookings,
    SUM(CASE WHEN booking_status='Success' THEN 1 ELSE 0 END)       AS successful_bookings,
    ROUND(SUM(CASE WHEN booking_status='Success'
              THEN booking_value_inr ELSE 0 END), 2)                AS total_revenue
FROM ola_bookings
GROUP BY booking_month, vehicle_type;
