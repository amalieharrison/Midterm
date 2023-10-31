
### CREATE a warehouse with 4 dimension columns

# DROP database `sakila_dw`;

CREATE DATABASE `sakila_dw` /*!40100 DEFAULT CHARACTER SET latin1 */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE sakila_dw;

CREATE TABLE `dim_customer` (
  `customer_id` smallint unsigned NOT NULL AUTO_INCREMENT,
  `store_id` tinyint unsigned NOT NULL,
  `first_name` varchar(45) NOT NULL,
  `last_name` varchar(45) NOT NULL,
  `email` varchar(50) DEFAULT NULL,
  `address_id` smallint unsigned NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `create_date` datetime NOT NULL,
  `last_update` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`customer_id`),
  KEY `idx_fk_store_id` (`store_id`),
  KEY `idx_fk_address_id` (`address_id`),
  KEY `idx_last_name` (`last_name`)
 )ENGINE=InnoDB AUTO_INCREMENT=600 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
 
 CREATE TABLE `dim_inventory` (
  `inventory_id` mediumint unsigned NOT NULL AUTO_INCREMENT,
  `film_id` smallint unsigned NOT NULL,
  `store_id` tinyint unsigned NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`inventory_id`),
  KEY `idx_fk_film_id` (`film_id`),
  KEY `idx_store_id_film_id` (`store_id`,`film_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4582 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `dim_staff` (
  `staff_id` tinyint unsigned NOT NULL AUTO_INCREMENT,
  `first_name` varchar(45) NOT NULL,
  `last_name` varchar(45) NOT NULL,
  `address_id` smallint unsigned NOT NULL,
  `picture` blob,
  `email` varchar(50) DEFAULT NULL,
  `store_id` tinyint unsigned NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `username` varchar(16) NOT NULL,
  `password` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`staff_id`),
  KEY `idx_fk_store_id` (`store_id`),
  KEY `idx_fk_address_id` (`address_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `dim_rental` (
  `rental_id` int NOT NULL AUTO_INCREMENT,
  `rental_date` datetime NOT NULL,
  `inventory_id` mediumint unsigned NOT NULL,
  `customer_id` smallint unsigned NOT NULL,
  `return_date` datetime DEFAULT NULL,
  `staff_id` tinyint unsigned NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`rental_id`),
  UNIQUE KEY `rental_date` (`rental_date`,`inventory_id`,`customer_id`),
  KEY `idx_fk_inventory_id` (`inventory_id`),
  KEY `idx_fk_customer_id` (`customer_id`),
  KEY `idx_fk_staff_id` (`staff_id`)
) ENGINE=InnoDB AUTO_INCREMENT=16050 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

### Combine film, film_actor, film_category, and film_text

# DROP TABLE `fact_film`;
CREATE TABLE `fact_film` (
  `fact_film_key` smallint unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(128) NOT NULL,
  `description` text,
  `release_year` year DEFAULT NULL,
  `language_id` tinyint unsigned NOT NULL,
  `original_language_id` tinyint unsigned DEFAULT NULL,
  `rental_duration` tinyint unsigned NOT NULL DEFAULT '3',
  `rental_rate` decimal(4,2) NOT NULL DEFAULT '4.99',
  `length` smallint unsigned DEFAULT NULL,
  `replacement_cost` decimal(5,2) NOT NULL DEFAULT '19.99',
  `rating` enum('G','PG','PG-13','R','NC-17') DEFAULT 'G',
  `special_features` set('Trailers','Commentaries','Deleted Scenes','Behind the Scenes') DEFAULT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `category_id` tinyint unsigned DEFAULT NULL,
  `actor_id` smallint unsigned DEFAULT NULL,
  PRIMARY KEY (`fact_film_key`),
  KEY `idx_title` (`title`),
  KEY `idx_fk_language_id` (`language_id`),
  KEY `idx_fk_original_language_id` (`original_language_id`),
  # KEY `idx_fk_film_id` (`film_id`),
  KEY `fk_film_category_category` (`category_id`),
  KEY `fk_film_actor_actor` (`actor_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1001 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

'''
CREATE TABLE `film_actor` (
  `actor_id` smallint unsigned NOT NULL,
  `film_id` smallint unsigned NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`actor_id`,`film_id`),
  KEY `idx_fk_film_id` (`film_id`),
  CONSTRAINT `fk_film_actor_actor` FOREIGN KEY (`actor_id`) REFERENCES `actor` (`actor_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_film_actor_film` FOREIGN KEY (`film_id`) REFERENCES `film` (`film_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
'''


-- ----------------------------------------------
-- Populate dim_customer
-- ----------------------------------------------

INSERT INTO `sakila_dw`.`dim_customer`
(`customer_id`,
`store_id`,
`first_name`,
`last_name`,
`email`,
`address_id`,
`active`,
`create_date`,
`last_update`)
SELECT `customer`.`customer_id`,
    `customer`.`store_id`,
    `customer`.`first_name`,
    `customer`.`last_name`,
    `customer`.`email`,
    `customer`.`address_id`,
    `customer`.`active`,
    `customer`.`create_date`,
    `customer`.`last_update`
FROM `sakila`.`customer`;

SELECT * FROM sakila_dw.dim_customer;

-- ----------------------------------------------
-- Populate dim_inventory
-- ----------------------------------------------

INSERT INTO `sakila_dw`.`dim_inventory`
(`inventory_id`,
`film_id`,
`store_id`,
`last_update`)
SELECT `inventory`.`inventory_id`,
    `inventory`.`film_id`,
    `inventory`.`store_id`,
    `inventory`.`last_update`
FROM `sakila`.`inventory`;

SELECT * FROM dim_inventory;

-- ----------------------------------------------
-- Populate dim_staff
-- ----------------------------------------------

INSERT INTO `sakila_dw`.`dim_staff`
(`staff_id`,
`first_name`,
`last_name`,
`address_id`,
`picture`,
`email`,
`store_id`,
`active`,
`username`,
`password`,
`last_update`)
SELECT `staff`.`staff_id`,
    `staff`.`first_name`,
    `staff`.`last_name`,
    `staff`.`address_id`,
    `staff`.`picture`,
    `staff`.`email`,
    `staff`.`store_id`,
    `staff`.`active`,
    `staff`.`username`,
    `staff`.`password`,
    `staff`.`last_update`
FROM `sakila`.`staff`;

SELECT * FROM dim_staff;

-- ----------------------------------------------
-- Populate dim_rental
-- ----------------------------------------------

INSERT INTO `sakila_dw`.`dim_rental`
(`rental_id`,
`rental_date`,
`inventory_id`,
`customer_id`,
`return_date`,
`staff_id`,
`last_update`)
SELECT `rental`.`rental_id`,
    `rental`.`rental_date`,
    `rental`.`inventory_id`,
    `rental`.`customer_id`,
    `rental`.`return_date`,
    `rental`.`staff_id`,
    `rental`.`last_update`
FROM `sakila`.`rental`;

SELECT * FROM dim_rental;

-- ----------------------------------------------
-- Populate fact_film
-- ----------------------------------------------

INSERT INTO `sakila_dw`.`fact_film`
(`title`,
`description`,
`release_year`,
`language_id`,
`original_language_id`,
`rental_duration`,
`rental_rate`,
`length`,
`replacement_cost`,
`rating`,
`special_features`,
`last_update`,
`category_id`,
`actor_id`)
SELECT `film`.`title`,
    `film`.`description`,
    `film`.`release_year`,
    `film`.`language_id`,
    `film`.`original_language_id`,
    `film`.`rental_duration`,
    `film`.`rental_rate`,
    `film`.`length`,
    `film`.`replacement_cost`,
    `film`.`rating`,
    `film`.`special_features`,
    `film`.`last_update`,
    `film_category`.`category_id`,
    `film_actor`.`actor_id`
FROM `sakila`.`film`
INNER JOIN sakila.film_category
ON film.film_id = film_category.film_id
LEFT OUTER JOIN sakila.film_actor
ON film.film_id = film_actor.film_id;

SELECT * FROM sakila_dw.fact_film;





-- ----------------------------------------------
-- Populate Date Dimension
-- ----------------------------------------------

USE sakila_dw;

DROP TABLE IF EXISTS dim_date;
CREATE TABLE dim_date(
 date_key int NOT NULL,
 full_date date NULL,
 date_name char(11) NOT NULL,
 date_name_us char(11) NOT NULL,
 date_name_eu char(11) NOT NULL,
 day_of_week tinyint NOT NULL,
 day_name_of_week char(10) NOT NULL,
 day_of_month tinyint NOT NULL,
 day_of_year smallint NOT NULL,
 weekday_weekend char(10) NOT NULL,
 week_of_year tinyint NOT NULL,
 month_name char(10) NOT NULL,
 month_of_year tinyint NOT NULL,
 is_last_day_of_month char(1) NOT NULL,
 calendar_quarter tinyint NOT NULL,
 calendar_year smallint NOT NULL,
 calendar_year_month char(10) NOT NULL,
 calendar_year_qtr char(10) NOT NULL,
 fiscal_month_of_year tinyint NOT NULL,
 fiscal_quarter tinyint NOT NULL,
 fiscal_year int NOT NULL,
 fiscal_year_month char(10) NOT NULL,
 fiscal_year_qtr char(10) NOT NULL,
  PRIMARY KEY (`date_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

# Here is the PopulateDateDimension Stored Procedure: 
delimiter //

DROP PROCEDURE IF EXISTS PopulateDateDimension//
CREATE PROCEDURE PopulateDateDimension(BeginDate DATETIME, EndDate DATETIME)
BEGIN

	# =============================================
	# Description: http://arcanecode.com/2009/11/18/populating-a-kimball-date-dimension/
	# =============================================

	# A few notes, this code does nothing to the existing table, no deletes are triggered before hand.
    # Because the DateKey is uniquely indexed, it will simply produce errors if you attempt to insert duplicates.
	# You can however adjust the Begin/End dates and rerun to safely add new dates to the table every year.
	# If the begin date is after the end date, no errors occur but nothing happens as the while loop never executes.

	# Holds a flag so we can determine if the date is the last day of month
	DECLARE LastDayOfMon CHAR(1);

	# Number of months to add to the date to get the current Fiscal date
	DECLARE FiscalYearMonthsOffset INT;

	# These two counters are used in our loop.
	DECLARE DateCounter DATETIME;    #Current date in loop
	DECLARE FiscalCounter DATETIME;  #Fiscal Year Date in loop

	# Set this to the number of months to add to the current date to get the beginning of the Fiscal year.
    # For example, if the Fiscal year begins July 1, put a 6 there.
	# Negative values are also allowed, thus if your 2010 Fiscal year begins in July of 2009, put a -6.
	SET FiscalYearMonthsOffset = 6;

	# Start the counter at the begin date
	SET DateCounter = BeginDate;

	WHILE DateCounter <= EndDate DO
		# Calculate the current Fiscal date as an offset of the current date in the loop
		SET FiscalCounter = DATE_ADD(DateCounter, INTERVAL FiscalYearMonthsOffset MONTH);

		# Set value for IsLastDayOfMonth
		IF MONTH(DateCounter) = MONTH(DATE_ADD(DateCounter, INTERVAL 1 DAY)) THEN
			SET LastDayOfMon = 'N';
		ELSE
			SET LastDayOfMon = 'Y';
		END IF;

		# add a record into the date dimension table for this date
		INSERT INTO dim_date
			(date_key
			, full_date
			, date_name
			, date_name_us
			, date_name_eu
			, day_of_week
			, day_name_of_week
			, day_of_month
			, day_of_year
			, weekday_weekend
			, week_of_year
			, month_name
			, month_of_year
			, is_last_day_of_month
			, calendar_quarter
			, calendar_year
			, calendar_year_month
			, calendar_year_qtr
			, fiscal_month_of_year
			, fiscal_quarter
			, fiscal_year
			, fiscal_year_month
			, fiscal_year_qtr)
		VALUES  (
			( YEAR(DateCounter) * 10000 ) + ( MONTH(DateCounter) * 100 ) + DAY(DateCounter)  #DateKey
			, DateCounter #FullDate
			, CONCAT(CAST(YEAR(DateCounter) AS CHAR(4)),'/', DATE_FORMAT(DateCounter,'%m'),'/', DATE_FORMAT(DateCounter,'%d')) #DateName
			, CONCAT(DATE_FORMAT(DateCounter,'%m'),'/', DATE_FORMAT(DateCounter,'%d'),'/', CAST(YEAR(DateCounter) AS CHAR(4)))#DateNameUS
			, CONCAT(DATE_FORMAT(DateCounter,'%d'),'/', DATE_FORMAT(DateCounter,'%m'),'/', CAST(YEAR(DateCounter) AS CHAR(4)))#DateNameEU
			, DAYOFWEEK(DateCounter) #DayOfWeek
			, DAYNAME(DateCounter) #DayNameOfWeek
			, DAYOFMONTH(DateCounter) #DayOfMonth
			, DAYOFYEAR(DateCounter) #DayOfYear
			, CASE DAYNAME(DateCounter)
				WHEN 'Saturday' THEN 'Weekend'
				WHEN 'Sunday' THEN 'Weekend'
				ELSE 'Weekday'
			END #WeekdayWeekend
			, WEEKOFYEAR(DateCounter) #WeekOfYear
			, MONTHNAME(DateCounter) #MonthName
			, MONTH(DateCounter) #MonthOfYear
			, LastDayOfMon #IsLastDayOfMonth
			, QUARTER(DateCounter) #CalendarQuarter
			, YEAR(DateCounter) #CalendarYear
			, CONCAT(CAST(YEAR(DateCounter) AS CHAR(4)),'-',DATE_FORMAT(DateCounter,'%m')) #CalendarYearMonth
			, CONCAT(CAST(YEAR(DateCounter) AS CHAR(4)),'Q',QUARTER(DateCounter)) #CalendarYearQtr
			, MONTH(FiscalCounter) #[FiscalMonthOfYear]
			, QUARTER(FiscalCounter) #[FiscalQuarter]
			, YEAR(FiscalCounter) #[FiscalYear]
			, CONCAT(CAST(YEAR(FiscalCounter) AS CHAR(4)),'-',DATE_FORMAT(FiscalCounter,'%m')) #[FiscalYearMonth]
			, CONCAT(CAST(YEAR(FiscalCounter) AS CHAR(4)),'Q',QUARTER(FiscalCounter)) #[FiscalYearQtr]
		);
		# Increment the date counter for next pass thru the loop
		SET DateCounter = DATE_ADD(DateCounter, INTERVAL 1 DAY);
	END WHILE;
END//

CALL PopulateDateDimension('2000/01/01', '2010/12/31');

SELECT * FROM dim_date
LIMIT 20;

SELECT MIN(full_date) AS MinDate
		, MAX(full_date) AS MaxDate
FROM dim_date;

# ===================================================================================
# How to Integrate a Dimension table. In other words, how to look-up Foreign Key
# values FROM a dimension table and add them to new Fact table columns.
#
# First, go to Edit -> Preferences -> SQL Editor and disable 'Safe Edits'.
# Close SQL Workbench and Reconnect to the Server Instance.
# ===================================================================================

USE sakila_dw;

# ==============================================================
# Step 1: Add New Column(s)
# ==============================================================

#ALTER TABLE sakila_dw.dim_rental
#DROP COLUMN rental_date_key,
#DROP COLUMN return_date_key;

ALTER TABLE sakila_dw.dim_rental
ADD COLUMN rental_date_key int NOT NULL AFTER rental_date,
ADD COLUMN return_date_key int NOT NULL AFTER return_date;

# ==============================================================
# Step 2: Update New Column(s) with value from Dimension table
#         WHERE Business Keys in both tables match.
# ==============================================================

UPDATE sakila_dw.dim_rental AS sr
JOIN sakila_dw.dim_date AS sd
ON DATE(sr.rental_date) = sd.full_date
SET sr.rental_date_key = sd.date_key;

UPDATE sakila_dw.dim_rental AS sr
JOIN sakila_dw.dim_date AS sd
ON DATE(sr.return_date) = sd.full_date
SET sr.return_date_key = sd.date_key;

SELECT * FROM sakila_dw.dim_rental;

# ==============================================================
# Step 3: Validate that newly updated columns contain valid data
# ==============================================================
SELECT rental_date
	, rental_date_key
    , return_date
	, return_date_key
FROM sakila_dw.dim_rental
LIMIT 10;

# =============================================================
# Step 4: If values are correct then drop old column(s)
# =============================================================
ALTER TABLE northwind_dw.fact_orders
DROP COLUMN order_date,
DROP COLUMN shipped_date,
DROP COLUMN paid_date;

# =============================================================
# Step 5: Validate Finished Fact Table.
# =============================================================
SELECT * FROM northwind_dw.fact_orders
LIMIT 10;













 
 






